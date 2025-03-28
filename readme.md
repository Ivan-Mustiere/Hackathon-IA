# Projet Hackathon - 28 Mars 2025

## Description

Ce projet a été réalisé dans le cadre de la **session Hackathon** du **28 mars 2025**. Il a pour objectif de **mettre en place une IA** capable d’aider les personnes à trouver des **activités écologiques** afin de contribuer à la préservation de la planète.

L'application permet à l'utilisateur de remplir un profil avec des informations sur ses goûts, son âge et sa personnalité, et reçoit ensuite des **suggestions d'activités personnalisées** pour l'aider à s'engager dans des actions écologiques adaptées à son mode de vie.

## Technologies utilisées

- **Django** : Utilisé pour gérer la structure backend et la gestion des utilisateurs.
- **Flask** : Framework Python utilisé pour la gestion du chat avec l'IA.
- **PostgreSQL** : Base de données pour stocker les informations des utilisateurs, leurs tests de personnalité et les activités proposées.
- **ChatGPT (OpenAI)** : Utilisé pour générer des réponses personnalisées et proposer des activités en fonction des informations de l'utilisateur.

## Objectifs

- Proposer des **activités écologiques** adaptées aux préférences de l'utilisateur (par exemple, activités pour se reconnecter à la nature, réduire l'empreinte écologique, etc.).
- Intégrer un chat qui **commence la conversation** en proposant une activité valorisante, puis répond aux questions de l'utilisateur.
- Aider à sensibiliser à l'**écologie** en mettant en valeur des actions concrètes et accessibles.

## Fonctionnalités principales

- **Profil utilisateur** : Permet à l'utilisateur de remplir ses informations personnelles, ses tests de personnalité et de recevoir des recommandations.
- **Chat IA** : L'IA prend l'initiative dès la première connexion pour proposer une activité écologiquement responsable, puis répond aux questions de l'utilisateur.
- **Suggestions écologiques personnalisées** : L'IA prend en compte l'âge, la personnalité, les préférences et la sensibilité écologique de l'utilisateur pour proposer des activités qui l'aideront à réduire son impact environnemental.

## Installation

1. Clonez le projet :

    ```bash
    git clone https://github.com/ton-compte/nom-du-projet.git
    cd nom-du-projet
    ```

2. Installez les dépendances :

    ```bash
    pip install -r requirements.txt
    ```

3. Configurez votre base de données PostgreSQL et connectez-la à l'application.

4. Assurez-vous que votre clé API **OpenAI** est bien configurée pour utiliser ChatGPT. Ajoutez-la dans un fichier `.env` :

    ```
    OPENAI_API_KEY=your-api-key-here
    ```

5. Démarrez l'application :

    ```bash
    python app.py
    ```

## Auteur

Ce projet a été réalisé par **Ivan MUSTIERE** dans le cadre du hackathon du 28 mars 2025.