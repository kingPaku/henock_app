# Application de Gestion Immobilière

Application Flutter pour la consultation et la mise en vente de biens immobiliers.

## Fonctionnalités

- ✅ Affichage des biens immobiliers
- ✅ Filtre par prix et lieu
- ✅ Détails du bien
- ✅ Ajout de biens
- ✅ Gestion des favoris
- ✅ Authentification Firebase (Email/Mot de passe + Google)
- ✅ Base de données Firestore en temps réel
- ✅ Architecture MVC
- ✅ Gestion d'état avec Provider
- ✅ Intégration API REST externe (géocodage)

## Architecture

L'application suit strictement le pattern MVC :

```
lib/
├── models/          # Classes de données
│   ├── bien_immobilier.dart
│   ├── user_model.dart
│   └── favoris.dart
├── views/           # Interface utilisateur
│   ├── auth/
│   │   └── login_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   └── biens/
│       ├── bien_list_screen.dart
│       ├── bien_detail_screen.dart
│       ├── add_bien_screen.dart
│       ├── favoris_screen.dart
│       └── filter_screen.dart
├── controllers/     # Logique métier
│   ├── auth_controller.dart
│   └── bien_controller.dart
├── services/        # Appels API et Firebase
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── api_service.dart
└── utils/           # Utilitaires
    └── constants.dart
```

## Configuration Firebase

### 1. Créer un projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Créez un nouveau projet
3. Activez Authentication et Cloud Firestore

### 2. Configuration Android

1. Dans Firebase Console, ajoutez une application Android
2. Téléchargez `google-services.json`
3. Placez-le dans `android/app/google-services.json`
4. Ajoutez dans `android/build.gradle` :
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```
5. Ajoutez dans `android/app/build.gradle` :
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 3. Configuration iOS

1. Dans Firebase Console, ajoutez une application iOS
2. Téléchargez `GoogleService-Info.plist`
3. Placez-le dans `ios/Runner/GoogleService-Info.plist`
4. Ouvrez `ios/Runner.xcworkspace` dans Xcode
5. Ajoutez le fichier au projet

### 4. Configuration Authentication

Dans Firebase Console > Authentication :
1. Activez "Email/Password"
2. Activez "Google" comme provider supplémentaire
3. Configurez l'écran de consentement OAuth pour Google

### 5. Configuration Firestore

Dans Firebase Console > Firestore Database :
1. Créez une base de données en mode production ou test
2. Configurez les règles de sécurité (exemple ci-dessous)

### Règles Firestore (exemple)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Biens immobiliers
    match /biens/{bienId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.uid == request.resource.data.userId);
    }
    
    // Favoris
    match /favoris/{favorisId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

## Installation

1. Clonez le dépôt
2. Installez les dépendances :
```bash
flutter pub get
```

3. Configurez Firebase (voir ci-dessus)

4. Lancez l'application :
```bash
flutter run
```

## Dépendances principales

- `firebase_core` : Core Firebase
- `firebase_auth` : Authentification
- `cloud_firestore` : Base de données Firestore
- `google_sign_in` : Connexion Google
- `provider` : Gestion d'état
- `http` : Appels API REST
- `cached_network_image` : Cache des images
- `intl` : Formatage des données

## API Externe

L'application utilise l'API Nominatim (OpenStreetMap) pour le géocodage des adresses :
- Récupération des coordonnées GPS à partir d'une adresse
- Enrichissement des données de localisation

## Structure des données Firestore

### Collection `biens`
```json
{
  "titre": "string",
  "description": "string",
  "prix": number,
  "adresse": "string",
  "ville": "string",
  "codePostal": "string",
  "type": "string",
  "superficie": number,
  "nombrePieces": number,
  "images": ["string"],
  "userId": "string",
  "dateCreation": "timestamp",
  "disponible": boolean
}
```

### Collection `favoris`
```json
{
  "userId": "string",
  "bienId": "string",
  "dateAjout": "timestamp"
}
```

## Contribution

Ce projet utilise Git pour la collaboration. Chaque membre doit :
- Créer des branches pour les fonctionnalités
- Faire des commits réguliers avec des messages clairs
- Créer des pull requests pour les modifications

## Notes

- L'application nécessite une connexion Internet pour fonctionner
- Les images doivent être accessibles via URL publique
- Les filtres fonctionnent en temps réel grâce à Firestore
