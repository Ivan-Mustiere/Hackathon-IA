import psycopg2

def get_db_connection():
    try:
        return psycopg2.connect(
            host="localhost",
            database="personality_app",
            user="api_user",
            password="hD$y!DPzMpfrne65"
        )
    except Exception as e:
        print("Erreur de connexion à la base de données :", e)
        raise
