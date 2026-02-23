import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/bien_controller.dart';
import '../../models/bien_immobilier.dart';
import 'bien_detail_screen.dart';
import '../../utils/constants.dart';

class BienListScreen extends StatelessWidget {
  const BienListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bienController = context.watch<BienController>();

    return StreamBuilder<List<BienImmobilier>>(
      stream: bienController.getBiensStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erreur: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => bienController.chargerBiens(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Aucun bien disponible',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final biens = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () => bienController.chargerBiens(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: biens.length,
            itemBuilder: (context, index) {
              final bien = biens[index];
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
                  trailing: const Icon(Icons.chevron_right),
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
      },
    );
  }
}
