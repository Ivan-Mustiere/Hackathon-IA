from flask import Flask, render_template, request, redirect, session, url_for, flash, jsonify
from db_config import get_db_connection
from flask import session
import secrets
import os
from dotenv import load_dotenv
from openai import OpenAI

app = Flask(__name__)

# from flask_bcrypt import Bcrypt  
load_dotenv()
app.secret_key = os.getenv("SECRET_KEY")
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


@app.route('/')
def index():
    if 'user_id' not in session:
        return redirect('/login')

    user_id = session['user_id']
    conn = get_db_connection()
    cursor = conn.cursor()

    # Récupérer les 5 types de personnalité enregistrés
    cursor.execute("""
        SELECT personality_type, value 
        FROM personalities 
        WHERE user_id = %s
    """, (user_id,))
    personnalites = {ptype: value for ptype, value in cursor.fetchall()}

    cursor.execute("SELECT age FROM users WHERE id = %s", (user_id,))
    age = cursor.fetchone()[0]

    cursor.close()
    conn.close()

    personnalites_remplies = [v for v in personnalites.values() if v and v.strip() != '']
    complet = len(personnalites_remplies) >= 2

    return render_template(
        'index.html',
        complet=complet,
        age=age,
        personnalites=personnalites
    )


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']

        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT id, username, password FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()

        if user and user[2] == password:
            session['user_id'] = user[0]
            session['username'] = user[1]
            cursor.close()
            conn.close()
            return redirect(url_for('profile'))
        else:
            cursor.close()
            conn.close()
            return "❌ Email ou mot de passe incorrect", 401

    return render_template('login.html')

@app.route('/profile', methods=['GET', 'POST'])
def profile():
    if 'user_id' not in session:
        return redirect('/login')

    user_id = session['user_id']
    conn = get_db_connection()
    cursor = conn.cursor()

    if request.method == 'POST':
        bio = request.form.get('bio')
        age = request.form.get('age')
        city = request.form.get('city')
        likes = request.form.get('likes')
        dislikes = request.form.get('dislikes')

        # Mise à jour de la table users avec les champs likes et dislikes
        cursor.execute("""
            UPDATE users 
            SET bio = %s, age = %s, city = %s, likes = %s, dislikes = %s 
            WHERE id = %s
        """, (bio, age, city, likes, dislikes, user_id))

        # Update des tests de personnalité comme avant
        personality_types = ['MBTI', 'Enneagramme', 'Big Five', 'DISC', 'Haut Potentiel']
        for ptype in personality_types:
            value = request.form.get(f'personality_{ptype}')
            if value:
                cursor.execute("""
                    INSERT INTO personalities (user_id, personality_type, value)
                    VALUES (%s, %s, %s)
                    ON CONFLICT (user_id, personality_type)
                    DO UPDATE SET value = EXCLUDED.value
                """, (user_id, ptype, value))

        conn.commit()

    # GET → afficher profil existant
    cursor.execute("SELECT username, bio, age, city, likes, dislikes FROM users WHERE id = %s", (user_id,))
    row = cursor.fetchone()
    user = {
        "username": row[0],
        "bio": row[1],
        "age": row[2],
        "city": row[3],
        "likes": row[4],
        "dislikes": row[5]
    }

    cursor.execute("SELECT personality_type, value FROM personalities WHERE user_id = %s", (user_id,))
    personalities = {ptype: value for ptype, value in cursor.fetchall()}

    cursor.close()
    conn.close()

    return render_template("profile.html", user=user, personalities=personalities)


@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        password = request.form['password']

        # 🔐 Partie hashage (à activer plus tard en prod)
        # hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')
        # password_to_store = hashed_password

        password_to_store = password  # Stocké en clair (⚠️ temporaire uniquement !)

        try:
            conn = get_db_connection()
            cursor = conn.cursor()

            cursor.execute("SELECT id FROM users WHERE username = %s OR email = %s", (username, email))
            existing_user = cursor.fetchone()

            if existing_user:
                return "⚠️ Utilisateur ou email déjà utilisé.", 409

            cursor.execute("""
                INSERT INTO users (username, email, password)
                VALUES (%s, %s, %s)
                RETURNING id
            """, (username, email, password_to_store))

            user_id = cursor.fetchone()[0]
            conn.commit()

            session['user_id'] = user_id
            session['username'] = username

            cursor.close()
            conn.close()

            return redirect(url_for('profile'))
        except Exception as e:
            print("Erreur d'inscription :", e)
            return "❌ Erreur serveur", 500

    return render_template('register.html')

@app.route('/chat', methods=['POST'])
def chat():
    if 'user_id' not in session:
        return jsonify({"reply": "Veuillez vous connecter pour utiliser le chat."}), 401

    data = request.get_json()
    user_message = data.get('message', '')

    user_id = session['user_id']
    conn = get_db_connection()
    cursor = conn.cursor()

    # Récupérer l'âge, les goûts, les aversions et la ville
    cursor.execute("SELECT age, likes, dislikes, city FROM users WHERE id = %s", (user_id,))
    row = cursor.fetchone()
    age = row[0]
    likes = row[1] or ''
    dislikes = row[2] or ''
    city = row[3] or 'une ville inconnue'  # Valeur par défaut si la ville est absente

    # Récupérer les personnalités
    cursor.execute("SELECT personality_type, value FROM personalities WHERE user_id = %s", (user_id,))
    personality_data = {ptype: value for ptype, value in cursor.fetchall()}

    cursor.close()
    conn.close()

    # Construire le prompt initial
    infos = f"L'utilisateur a {age} ans, il vit à {city}. Voici ses personnalités : " + ', '.join(
        f"{ptype} = {val}" for ptype, val in personality_data.items()
    )

    if likes:
        infos += f". Il aime : {likes}"
    else:
        infos += f". Il n'a pas de préférences particulières."

    if dislikes:
        infos += f". Il n'aime pas : {dislikes}"
    else:
        infos += f". Il n'a pas de dégoûts spécifiques."

    prompt = f"""
    Tu es une IA spécialisée dans les **activités écologiques personnalisées**. Voici ce que tu sais sur l’utilisateur :
    - Âge : {age} ans
    - Ville : {city}
    - Personnalités : {', '.join(f"{k} = {v}" for k, v in personality_data.items())}
    - Ce qu'il aime : {likes}
    - Ce qu'il n'aime pas : {dislikes}

    🎯 Propose une activité écologique unique et engageante dès le début de la conversation, en fonction de l’âge, des goûts et de la personnalité de l’utilisateur. L’IA ne doit pas répéter cette phrase dans chaque réponse.

    Si l'utilisateur demande des activités **locales**, recherche des événements ou des actions dans sa ville, et ajoute des **liens locaux cliquables**. Par exemple :
    - Des actions de nettoyage de la nature
    - Des événements de jardinage communautaire
    - Des ateliers de recyclage

    Réponds sous forme structurée en HTML :
    - Titre (<h4>) pour l'introduction
    - Liste (<ul><li>) pour les suggestions d'activités
    - Paragraphe (<p>) pour des explications détaillées si nécessaire

    Voici ce que l’utilisateur t’écrit : {user_message}
    """


    # Si un historique est présent dans la session, on l'ajoute au prompt
    if 'history' in session:
        conversation_history = session['history']
    else:
        conversation_history = []

    # Message initial de l'IA
    initial_message = {
        "role": "system",
        "content": f"Bienvenue ! Je suis là pour vous proposer des activités écologiques personnalisées. N'hésitez pas à me parler de vos préférences ou à poser des questions !"
    }

    # Ajouter le message initial à l'historique
    conversation_history.append(initial_message)

    # Ajouter le prompt à l'historique
    conversation_history.append({"role": "system", "content": prompt})

    # Ajouter le message de l'utilisateur (s'il y en a)
    conversation_history.append({"role": "user", "content": user_message})

    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=conversation_history,
            max_tokens=300
        )
        reply = response.choices[0].message.content.strip()

        # Mettre à jour l'historique avec la réponse de l'IA
        conversation_history.append({"role": "assistant", "content": reply})

        # Sauvegarder l'historique dans la session pour garder le contexte
        session['history'] = conversation_history

        return jsonify({"reply": reply})
    except Exception as e:
        print("Erreur OpenAI :", e)
        return jsonify({"reply": "❌ Erreur lors de la réponse IA."}), 500

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))


if __name__ == '__main__':
    app.run(debug=True)
