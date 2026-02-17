import 'package:firebase_auth/firebase_auth.dart';
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
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  // Vérifier si l'utilisateur est connecté
  bool get isAuthenticated => _auth.currentUser != null;
}
