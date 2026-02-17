class BienImmobilier {
  final String? id;
  final String titre;
  final String description;
  final double prix;
  final String adresse;
  final String ville;
  final String codePostal;
  final String type; // Appartement, Maison, Studio, etc.
  final int superficie;
  final int nombrePieces;
  final List<String> images;
  final String? userId; // Propriétaire du bien
  final DateTime dateCreation;
  final bool disponible;

  BienImmobilier({
    this.id,
    required this.titre,
    required this.description,
    required this.prix,
    required this.adresse,
    required this.ville,
    required this.codePostal,
    required this.type,
    required this.superficie,
    required this.nombrePieces,
    this.images = const [],
    this.userId,
    DateTime? dateCreation,
    this.disponible = true,
  }) : dateCreation = dateCreation ?? DateTime.now();

  // Conversion vers Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'description': description,
      'prix': prix,
      'adresse': adresse,
      'ville': ville,
      'codePostal': codePostal,
      'type': type,
      'superficie': superficie,
      'nombrePieces': nombrePieces,
      'images': images,
      'userId': userId,
      'dateCreation': dateCreation.toIso8601String(),
      'disponible': disponible,
    };
  }

  // Création depuis Map (Firestore)
  factory BienImmobilier.fromMap(String id, Map<String, dynamic> map) {
    return BienImmobilier(
      id: id,
      titre: map['titre'] ?? '',
      description: map['description'] ?? '',
      prix: (map['prix'] ?? 0).toDouble(),
      adresse: map['adresse'] ?? '',
      ville: map['ville'] ?? '',
      codePostal: map['codePostal'] ?? '',
      type: map['type'] ?? '',
      superficie: map['superficie'] ?? 0,
      nombrePieces: map['nombrePieces'] ?? 0,
      images: List<String>.from(map['images'] ?? []),
      userId: map['userId'],
      dateCreation: map['dateCreation'] != null
          ? DateTime.parse(map['dateCreation'])
          : DateTime.now(),
      disponible: map['disponible'] ?? true,
    );
  }

  // Copie avec modifications
  BienImmobilier copyWith({
    String? id,
    String? titre,
    String? description,
    double? prix,
    String? adresse,
    String? ville,
    String? codePostal,
    String? type,
    int? superficie,
    int? nombrePieces,
    List<String>? images,
    String? userId,
    DateTime? dateCreation,
    bool? disponible,
  }) {
    return BienImmobilier(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      prix: prix ?? this.prix,
      adresse: adresse ?? this.adresse,
      ville: ville ?? this.ville,
      codePostal: codePostal ?? this.codePostal,
      type: type ?? this.type,
      superficie: superficie ?? this.superficie,
      nombrePieces: nombrePieces ?? this.nombrePieces,
      images: images ?? this.images,
      userId: userId ?? this.userId,
      dateCreation: dateCreation ?? this.dateCreation,
      disponible: disponible ?? this.disponible,
    );
  }
}
