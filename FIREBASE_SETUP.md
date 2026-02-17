# Guide de Configuration Firebase
<!-- cspell:language fr -->

## Étapes de Configuration

### 1. Créer un Projet Firebase

1. Allez sur https://console.firebase.google.com/
2. Cliquez sur "Ajouter un projet"
3. Entrez le nom du projet (ex: "gestion-immobiliere")
4. Suivez les étapes de configuration

### 2. Activer Authentication

1. Dans le menu de gauche, cliquez sur "Authentication"
2. Cliquez sur "Commencer"
3. Activez les méthodes suivantes :
   - **Email/Password** : Activez cette méthode
   - **Google** : Activez cette méthode et configurez l'écran de consentement OAuth

### 3. Activer Cloud Firestore

1. Dans le menu de gauche, cliquez sur "Firestore Database"
2. Cliquez sur "Créer une base de données"
3. Choisissez le mode "Production" ou "Test" (pour le développement)
4. Sélectionnez une région (ex: europe-west)
5. Configurez les règles de sécurité (voir ci-dessous)

### 4. Configuration Android

1. Dans Firebase Console, cliquez sur l'icône Android
2. Entrez le nom du package : `com.example.gestion_immobiliere` (ou votre package)
3. Téléchargez `google-services.json`
4. Placez-le dans `android/app/google-services.json`
5. Modifiez `android/build.gradle` :
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```
6. Modifiez `android/app/build.gradle` :
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 5. Configuration iOS

1. Dans Firebase Console, cliquez sur l'icône iOS
2. Entrez le Bundle ID de votre application
3. Téléchargez `GoogleService-Info.plist`
4. Placez-le dans `ios/Runner/GoogleService-Info.plist`
5. Ouvrez `ios/Runner.xcworkspace` dans Xcode
6. Ajoutez le fichier au projet Runner

### 6. Règles de Sécurité Firestore

Allez dans Firestore Database > Règles et utilisez :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Collection des biens immobiliers
    match /biens/{bienId} {
      // Tout le monde peut lire les biens disponibles
      allow read: if true;
      // Seuls les utilisateurs authentifiés peuvent créer
      allow create: if request.auth != null;
      // Seul le propriétaire peut modifier/supprimer
      allow update, delete: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.uid == request.resource.data.userId);
    }
    
    // Collection des favoris
    match /favoris/{favorisId} {
      // Seuls les utilisateurs authentifiés peuvent lire/écrire leurs propres favoris
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Collection des utilisateurs (optionnel)
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 7. Configuration Google Sign-In

Pour Android :
- Aucune configuration supplémentaire nécessaire si vous utilisez le SHA-1 par défaut

Pour iOS :
- Configurez l'URL de redirection dans Firebase Console > Authentication > Settings > Authorized domains

### 8. Tester la Configuration

1. Lancez l'application : `flutter run`
2. Testez l'inscription avec email/mot de passe
3. Testez la connexion avec Google
4. Vérifiez que les données sont bien sauvegardées dans Firestore

## Notes Importantes

- ⚠️ Ne commitez JAMAIS les fichiers `google-services.json` et `GoogleService-Info.plist` dans Git
- ⚠️ Ces fichiers contiennent des informations sensibles
- ✅ Ils sont déjà dans `.gitignore`
- 📝 Chaque développeur doit télécharger ses propres fichiers de configuration
