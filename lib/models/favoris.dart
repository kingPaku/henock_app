class Favoris {
  final String? id;
  final String userId;
  final String bienId;
  final DateTime dateAjout;

  Favoris({
    this.id,
    required this.userId,
    required this.bienId,
    DateTime? dateAjout,
  }) : dateAjout = dateAjout ?? DateTime.now();

  // Conversion vers Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bienId': bienId,
      'dateAjout': dateAjout.toIso8601String(),
    };
  }

  // Création depuis Map (Firestore)
  factory Favoris.fromMap(String id, Map<String, dynamic> map) {
    return Favoris(
      id: id,
      userId: map['userId'] ?? '',
      bienId: map['bienId'] ?? '',
      dateAjout: map['dateAjout'] != null
          ? DateTime.parse(map['dateAjout'])
          : DateTime.now(),
    );
  }
}
