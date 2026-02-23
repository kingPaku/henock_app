import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bien_immobilier.dart';
import '../models/favoris.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection des biens immobiliers
  CollectionReference get _biensCollection =>
      _firestore.collection('biens');

  // Collection des favoris
  CollectionReference get _favorisCollection =>
      _firestore.collection('favoris');

  // CREATE - Ajouter un bien
  Future<String> ajouterBien(BienImmobilier bien) async {
    try {
      DocumentReference docRef =
          await _biensCollection.add(bien.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du bien: $e');
    }
  }

  // READ - Récupérer tous les biens
  Stream<List<BienImmobilier>> getBiens() {
    return _biensCollection
        .where('disponible', isEqualTo: true)
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BienImmobilier.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // READ - Récupérer un bien par ID
  Future<BienImmobilier?> getBienById(String id) async {
    try {
      DocumentSnapshot doc = await _biensCollection.doc(id).get();
      if (doc.exists) {
        return BienImmobilier.fromMap(
            doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du bien: $e');
    }
  }

  // READ - Filtrer par prix
  Stream<List<BienImmobilier>> getBiensByPrix({
    double? prixMin,
    double? prixMax,
  }) {
    Query query = _biensCollection.where('disponible', isEqualTo: true);

    if (prixMin != null) {
      query = query.where('prix', isGreaterThanOrEqualTo: prixMin);
    }
    if (prixMax != null) {
      query = query.where('prix', isLessThanOrEqualTo: prixMax);
    }

    return query
        .orderBy('prix')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BienImmobilier.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // READ - Filtrer par lieu (ville)
  Stream<List<BienImmobilier>> getBiensByLieu(String ville) {
    return _biensCollection
        .where('disponible', isEqualTo: true)
        .where('ville', isEqualTo: ville)
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BienImmobilier.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // READ - Filtrer par prix et lieu
  Stream<List<BienImmobilier>> getBiensByPrixEtLieu({
    required String ville,
    double? prixMin,
    double? prixMax,
  }) {
    Query query = _biensCollection
        .where('disponible', isEqualTo: true)
        .where('ville', isEqualTo: ville);

    if (prixMin != null) {
      query = query.where('prix', isGreaterThanOrEqualTo: prixMin);
    }
    if (prixMax != null) {
      query = query.where('prix', isLessThanOrEqualTo: prixMax);
    }

    return query
        .orderBy('prix')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BienImmobilier.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // UPDATE - Modifier un bien
  Future<void> modifierBien(String id, BienImmobilier bien) async {
    try {
      await _biensCollection.doc(id).update(bien.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la modification du bien: $e');
    }
  }

  // DELETE - Supprimer un bien
  Future<void> supprimerBien(String id) async {
    try {
      await _biensCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du bien: $e');
    }
  }

  // FAVORIS - Ajouter aux favoris
  Future<void> ajouterFavoris(String userId, String bienId) async {
    try {
      // Vérifier si déjà en favoris
      QuerySnapshot snapshot = await _favorisCollection
          .where('userId', isEqualTo: userId)
          .where('bienId', isEqualTo: bienId)
          .get();

      if (snapshot.docs.isEmpty) {
        await _favorisCollection.add(
          Favoris(userId: userId, bienId: bienId).toMap(),
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout aux favoris: $e');
    }
  }

  // FAVORIS - Retirer des favoris
  Future<void> retirerFavoris(String userId, String bienId) async {
    try {
      QuerySnapshot snapshot = await _favorisCollection
          .where('userId', isEqualTo: userId)
          .where('bienId', isEqualTo: bienId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Erreur lors du retrait des favoris: $e');
    }
  }

  // FAVORIS - Vérifier si en favoris
  Future<bool> estFavoris(String userId, String bienId) async {
    try {
      QuerySnapshot snapshot = await _favorisCollection
          .where('userId', isEqualTo: userId)
          .where('bienId', isEqualTo: bienId)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // FAVORIS - Récupérer tous les favoris d'un utilisateur
  Stream<List<String>> getFavorisIds(String userId) {
    return _favorisCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => (doc.data() as Map<String, dynamic>)['bienId'] as String)
            .toList());
  }

  // FAVORIS - Récupérer les biens favoris
  Future<List<BienImmobilier>> getBiensFavoris(String userId) async {
    try {
      List<String> favorisIds = [];
      QuerySnapshot favorisSnapshot =
          await _favorisCollection.where('userId', isEqualTo: userId).get();
      favorisIds = favorisSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['bienId'] as String)
          .toList();

      if (favorisIds.isEmpty) return [];

      List<BienImmobilier> biens = [];
      for (String bienId in favorisIds) {
        BienImmobilier? bien = await getBienById(bienId);
        if (bien != null) {
          biens.add(bien);
        }
      }
      return biens;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des favoris: $e');
    }
  }
}
