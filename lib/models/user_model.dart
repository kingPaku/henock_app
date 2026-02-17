class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final DateTime? dateCreation;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.dateCreation,
  });

  // Conversion vers Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'dateCreation': dateCreation?.toIso8601String(),
    };
  }

  // Création depuis Map (Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      dateCreation: map['dateCreation'] != null
          ? DateTime.parse(map['dateCreation'])
          : null,
    );
  }
}
