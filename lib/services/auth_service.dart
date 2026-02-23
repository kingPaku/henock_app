import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream de l'utilisateur actuel
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Inscription avec email/mot de passe
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Mise à jour du nom d'affichage
        if (displayName != null) {
          await result.user!.updateDisplayName(displayName);
          await result.user!.reload();
        }

        // Créer le profil utilisateur dans Firestore
        UserModel userModel = UserModel(
          uid: result.user!.uid,
          email: result.user!.email,
          displayName: displayName ?? result.user!.displayName,
          photoURL: result.user!.photoURL,
          dateCreation: DateTime.now(),
        );

        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  // Connexion avec email/mot de passe
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        return UserModel(
          uid: result.user!.uid,
          email: result.user!.email,
          displayName: result.user!.displayName,
          photoURL: result.user!.photoURL,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  // Connexion avec Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result =
          await _auth.signInWithCredential(credential);

      if (result.user != null) {
        return UserModel(
          uid: result.user!.uid,
          email: result.user!.email,
          displayName: result.user!.displayName,
          photoURL: result.user!.photoURL,
          dateCreation: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la connexion Google: $e');
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      if (kIsWeb) {
        // Sur web, FirebaseAuth.signOut suffit pour déconnecter l'utilisateur
        // de l'application sans dépendre de l'état GoogleSignIn JS.
        await _auth.signOut();
        return;
      }

      final User? user = _auth.currentUser;
      final bool hasGoogleProvider = user?.providerData
              .any((provider) => provider.providerId == 'google.com') ??
          false;

      if (hasGoogleProvider) {
        try {
          // Sur web, disconnect/signOut peut lever une assertion si GoogleSignIn
          // n'a pas été initialisé via le flux JS attendu. On ignore cet échec
          // pour garantir la déconnexion Firebase.
          if (!kIsWeb) {
            try {
              await _googleSignIn.disconnect();
            } catch (_) {}
          }
          await _googleSignIn.signOut();
        } catch (e) {
          debugPrint('Google sign-out warning: $e');
        }
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  // Vérifier si l'utilisateur est connecté
  bool get isAuthenticated => _auth.currentUser != null;
}
