import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/bien_controller.dart';
import '../../models/bien_immobilier.dart';
import '../../utils/constants.dart';
import 'add_bien_screen.dart';

class BienDetailScreen extends StatefulWidget {
  final String bienId;

  const BienDetailScreen({super.key, required this.bienId});

  @override
  State<BienDetailScreen> createState() => _BienDetailScreenState();
}

class _BienDetailScreenState extends State<BienDetailScreen> {
  bool _isFavoris = false;
  bool _checkingFavoris = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadBien();
    _checkFavoris();
  }

  Future<void> _loadBien() async {
    final bienController = context.read<BienController>();
    await bienController.chargerBienParId(widget.bienId);
  }

  Future<void> _checkFavoris() async {
    final authController = context.read<AuthController>();
    final bienController = context.read<BienController>();

    if (authController.isAuthenticated) {
      bool favoris = await bienController.estFavoris(
        authController.currentUser!.uid,
        widget.bienId,
      );
      setState(() {
        _isFavoris = favoris;
        _checkingFavoris = false;
      });
    } else {
      setState(() {
        _checkingFavoris = false;
      });
    }
  }

  Future<void> _toggleFavoris() async {
    final authController = context.read<AuthController>();
    final bienController = context.read<BienController>();

    if (!authController.isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous devez être connecté pour ajouter aux favoris'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    bool success;
    if (_isFavoris) {
      success = await bienController.retirerFavoris(
        authController.currentUser!.uid,
        widget.bienId,
      );
    } else {
      success = await bienController.ajouterFavoris(
        authController.currentUser!.uid,
        widget.bienId,
      );
    }

    if (mounted && success) {
      setState(() {
        _isFavoris = !_isFavoris;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavoris
              ? 'Ajouté aux favoris'
              : 'Retiré des favoris'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _supprimerBien(BienImmobilier bien) async {
    final authController = context.read<AuthController>();
    final bienController = context.read<BienController>();

    final isOwner = authController.isAuthenticated &&
        authController.currentUser?.uid == bien.userId;
    if (!isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous ne pouvez supprimer que vos propres biens'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce bien ?'),
        content: const Text(
          'Cette action retirera le bien de la liste publique. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmation != true) return;

    setState(() {
      _isDeleting = true;
    });

    final success = await bienController.supprimerBien(bien.id!);
    if (!mounted) return;

    setState(() {
      _isDeleting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bien supprimé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(bienController.errorMessage ?? 'Erreur de suppression'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _modifierBien(BienImmobilier bien) async {
    final authController = context.read<AuthController>();
    final isOwner = authController.isAuthenticated &&
        authController.currentUser?.uid == bien.userId;

    if (!isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous ne pouvez modifier que vos propres biens'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddBienScreen(bienToEdit: bien),
      ),
    );

    if (result == true && mounted) {
      await _loadBien();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bien mis à jour'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final bienController = context.watch<BienController>();
    final bien = bienController.bienSelectionne;

    if (bienController.isLoading && bien == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (bien == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails')),
        body: const Center(
          child: Text('Bien introuvable'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du bien'),
        actions: [
          if (authController.isAuthenticated &&
              authController.currentUser?.uid == bien.userId)
            IconButton(
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              tooltip: 'Supprimer',
              onPressed: _isDeleting ? null : () => _supprimerBien(bien),
            ),
          if (_checkingFavoris)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: Icon(
                _isFavoris ? Icons.favorite : Icons.favorite_border,
                color: _isFavoris ? Colors.red : null,
              ),
              onPressed: _toggleFavoris,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images
            if (bien.images.isNotEmpty)
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: bien.images.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: bien.images[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.home, size: 64),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 250,
                color: Colors.grey[300],
                child: const Icon(Icons.home, size: 64),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bien.titre,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${bien.adresse}, ${bien.ville} ${bien.codePostal}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          Icons.attach_money,
                          formatPrix(bien.prix),
                        ),
                        _buildInfoItem(
                          Icons.square_foot,
                          '${bien.superficie}m²',
                        ),
                        _buildInfoItem(
                          Icons.bed,
                          '${bien.nombrePieces} pièces',
                        ),
                        _buildInfoItem(
                          Icons.category,
                          bien.type,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bien.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _modifierBien(bien),
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'Modifier les informations',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Informations',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Type', bien.type),
                  _buildInfoRow('Superficie', '${bien.superficie}m²'),
                  _buildInfoRow('Nombre de pièces', '${bien.nombrePieces}'),
                  _buildInfoRow('Prix', formatPrix(bien.prix)),
                  _buildInfoRow(
                    'Statut',
                    bien.statut,
                  ),
                  _buildInfoRow(
                    'Date de création',
                    formatDate(bien.dateCreation),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
