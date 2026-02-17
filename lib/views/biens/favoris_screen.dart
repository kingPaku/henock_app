import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/bien_controller.dart';
import '../../models/bien_immobilier.dart';
import '../../utils/constants.dart';
import 'bien_detail_screen.dart';

class FavorisScreen extends StatefulWidget {
  const FavorisScreen({super.key});

  @override
  State<FavorisScreen> createState() => _FavorisScreenState();
}

class _FavorisScreenState extends State<FavorisScreen> {
  @override
  void initState() {
    super.initState();
    _loadFavoris();
  }

  Future<void> _loadFavoris() async {
    final authController = context.read<AuthController>();
    final bienController = context.read<BienController>();

    if (authController.isAuthenticated) {
      await bienController.chargerFavoris(authController.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final bienController = context.watch<BienController>();

    if (!authController.isAuthenticated) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Connectez-vous pour voir vos favoris',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (bienController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final favoris = bienController.biensFavoris;

    if (favoris.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun favori pour le moment',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavoris,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: favoris.length,
        itemBuilder: (context, index) {
          final bien = favoris[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: bien.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: bien.images.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox(
                          width: 80,
                          height: 80,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.home),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.home),
                      ),
              ),
              title: Text(
                bien.titre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('${bien.ville}, ${bien.codePostal}'),
                  Text('${bien.superficie}m² • ${bien.nombrePieces} pièces'),
                  const SizedBox(height: 4),
                  Text(
                    formatPrix(bien.prix),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () async {
                  final success = await bienController.retirerFavoris(
                    authController.currentUser!.uid,
                    bien.id!,
                  );
                  if (mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Retiré des favoris'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BienDetailScreen(bienId: bien.id!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
