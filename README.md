# Projet Flutter Todo – Master M1 2024-2025

## Auteur
Projet réalisé par **Harouna MBAYE** dans le cadre du Master M1 2024-2025  
Encadré par **Professeur Moustapha DIOUF FALL**

## Description
Ce projet est une application **Todo List** développée avec **Flutter** (front-end mobile) et une **API REST en PHP/MySQL** (back-end).

L’application permet de :

- Gérer une liste de tâches (ajouter, afficher, modifier, supprimer)
- Authentification avec création de compte
- Persistance des données dans MySQL via une API PHP

## Fonctionnalités additionnelles
- **Photo de profil** : possibilité de choisir et sauvegarder une photo de profil, persistante même après déconnexion
- **Géolocalisation** : affichage de la position actuelle de l’utilisateur
- **Météo** : récupération et affichage de la température en fonction de la localisation (API utilisée : Open-Meteo)

## Technologies utilisées
- **Frontend** : Flutter / Dart
- **Backend** : PHP 7+, MySQL, PDO
- **Serveur local** : XAMPP / Laragon
- **Gestion de versions** : Git & GitHub

## Contenu du dépôt
- `todo_master_m1/` → Code source Flutter (application mobile)  
- `todo/` → API PHP/MySQL (fichiers backend)   
- `Guide.txt` → Guide d’installation et d’utilisation  
- `Rapport.pdf` → Rapport du projet  

## Installation et utilisation

### 1. Backend (API PHP/MySQL)
1. Copier le dossier `todo/` dans `C:\laragon\www\` ou `C:\xampp\htdocs\`
2. Importer la base de données dans MySQL :

```sql
CREATE DATABASE todo_db;
