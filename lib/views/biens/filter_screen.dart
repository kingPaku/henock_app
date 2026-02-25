import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/bien_controller.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final _villeController = TextEditingController();
  final _prixMinController = TextEditingController();
  final _prixMaxController = TextEditingController();

  @override
  void dispose() {
    _villeController.dispose();
    _prixMinController.dispose();
    _prixMaxController.dispose();
    super.dispose();
  }

  void _appliquerFiltres() {
    final bienController = context.read<BienController>();
    
    bienController.appliquerFiltres(
      ville: _villeController.text.trim().isNotEmpty
          ? _villeController.text.trim()
          : null,
      prixMin: _prixMinController.text.trim().isNotEmpty
          ? double.tryParse(_prixMinController.text.trim())
          : null,
      prixMax: _prixMaxController.text.trim().isNotEmpty
          ? double.tryParse(_prixMaxController.text.trim())
          : null,
    );

    Navigator.pop(context);
  }

  void _reinitialiserFiltres() {
    _villeController.clear();
    _prixMinController.clear();
    _prixMaxController.clear();
    
    final bienController = context.read<BienController>();
    bienController.reinitialiserFiltres();
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtres'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Filtrer les biens',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _villeController,
              decoration: const InputDecoration(
                labelText: 'Ville',
                hintText: 'Ex: Paris',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _prixMinController,
                    decoration: const InputDecoration(
                      labelText: 'Prix min (\$)',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _prixMaxController,
                    decoration: const InputDecoration(
                      labelText: 'Prix max (\$)',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _appliquerFiltres,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Appliquer les filtres'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _reinitialiserFiltres,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Réinitialiser'),
            ),
          ],
        ),
      ),
    );
  }
}
