import 'package:flutter/foundation.dart';
import '../models/bien_immobilier.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';

class BienController with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final ApiService _apiService = ApiService();

  List<BienImmobilier> _biens = [];
  List<BienImmobilier> _biensFavoris = [];
  BienImmobilier? _bienSelectionne;
  bool _isLoading = false;
  String? _errorMessage;

  // Filtres
  String? _villeFiltre;
  double? _prixMinFiltre;
  double? _prixMaxFiltre;

  List<BienImmobilier> get biens => _biens;
  List<BienImmobilier> get biensFavoris => _biensFavoris;
  BienImmobilier? get bienSelectionne => _bienSelectionne;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Stream pour écouter les changements en temps réel
  Stream<List<BienImmobilier>> getBiensStream() {
    if (_villeFiltre != null && _villeFiltre!.isNotEmpty) {
      if (_prixMinFiltre != null || _prixMaxFiltre != null) {
        return _firestoreService.getBiensByPrixEtLieu(
          ville: _villeFiltre!,
          prixMin: _prixMinFiltre,
          prixMax: _prixMaxFiltre,
        );
      }
      return _firestoreService.getBiensByLieu(_villeFiltre!);
    } else if (_prixMinFiltre != null || _prixMaxFiltre != null) {
      return _firestoreService.getBiensByPrix(
        prixMin: _prixMinFiltre,
        prixMax: _prixMaxFiltre,
      );
    }
    return _firestoreService.getBiens();
  }

  // Charger les biens
  Future<void> chargerBiens() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Les biens seront chargés via le stream
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger un bien par ID
  Future<void> chargerBienParId(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _bienSelectionne = await _firestoreService.getBienById(id);

      // Enrichir avec les données de l'API externe
      if (_bienSelectionne != null) {
        Map<String, double>? coordinates = await _apiService
            .getCoordinatesFromAddress(
          adresse: _bienSelectionne!.adresse,
          ville: _bienSelectionne!.ville,
          codePostal: _bienSelectionne!.codePostal,
        );
        // Les coordonnées pourraient être stockées dans le modèle si nécessaire
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter un bien
  Future<bool> ajouterBien(BienImmobilier bien) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Enrichir avec les données de l'API externe avant l'ajout
      Map<String, double>? coordinates = await _apiService
          .getCoordinatesFromAddress(
        adresse: bien.adresse,
        ville: bien.ville,
        codePostal: bien.codePostal,
      );

      String id = await _firestoreService.ajouterBien(bien);
      _isLoading = false;
      notifyListeners();
      return id.isNotEmpty;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Modifier un bien
  Future<bool> modifierBien(String id, BienImmobilier bien) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.modifierBien(id, bien);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Supprimer un bien
  Future<bool> supprimerBien(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.supprimerBien(id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Appliquer les filtres
  void appliquerFiltres({
    String? ville,
    double? prixMin,
    double? prixMax,
  }) {
    _villeFiltre = ville;
    _prixMinFiltre = prixMin;
    _prixMaxFiltre = prixMax;
    notifyListeners();
  }

  // Réinitialiser les filtres
  void reinitialiserFiltres() {
    _villeFiltre = null;
    _prixMinFiltre = null;
    _prixMaxFiltre = null;
    notifyListeners();
  }

  // Charger les favoris
  Future<void> chargerFavoris(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _biensFavoris = await _firestoreService.getBiensFavoris(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter aux favoris
  Future<bool> ajouterFavoris(String userId, String bienId) async {
    try {
      await _firestoreService.ajouterFavoris(userId, bienId);
      await chargerFavoris(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Retirer des favoris
  Future<bool> retirerFavoris(String userId, String bienId) async {
    try {
      await _firestoreService.retirerFavoris(userId, bienId);
      await chargerFavoris(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Vérifier si favoris
  Future<bool> estFavoris(String userId, String bienId) async {
    return await _firestoreService.estFavoris(userId, bienId);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
