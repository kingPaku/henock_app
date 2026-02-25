import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/bien_controller.dart';
import '../../models/bien_immobilier.dart';

class AddBienScreen extends StatefulWidget {
  final BienImmobilier? bienToEdit;

  const AddBienScreen({super.key, this.bienToEdit});

  @override
  State<AddBienScreen> createState() => _AddBienScreenState();
}

class _AddBienScreenState extends State<AddBienScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  final _adresseController = TextEditingController();
  final _villeController = TextEditingController();
  final _codePostalController = TextEditingController();
  final _superficieController = TextEditingController();
  final _nombrePiecesController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedType = 'Appartement';
  String _selectedStatut = 'En vente';
  final List<String> _types = [
    'Appartement',
    'Maison',
    'Studio',
    'Villa',
    'Loft',
    'Autre'
  ];
  final List<String> _statuts = const [
    'En vente',
    'Déjà vendu',
    'Retiré de la vente',
  ];
  final List<String> _images = [];

  bool get _isEditMode => widget.bienToEdit != null;

  @override
  void initState() {
    super.initState();
    _prefillFormIfNeeded();
  }

  void _prefillFormIfNeeded() {
    final bien = widget.bienToEdit;
    if (bien == null) return;

    _titreController.text = bien.titre;
    _descriptionController.text = bien.description;
    _prixController.text = bien.prix.toStringAsFixed(0);
    _adresseController.text = bien.adresse;
    _villeController.text = bien.ville;
    _codePostalController.text = bien.codePostal;
    _superficieController.text = bien.superficie.toString();
    _nombrePiecesController.text = bien.nombrePieces.toString();
    _selectedType = bien.type;
    _selectedStatut = _statuts.contains(bien.statut)
        ? bien.statut
        : (bien.disponible ? 'En vente' : 'Retiré de la vente');
    _images.addAll(bien.images);
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _adresseController.dispose();
    _villeController.dispose();
    _codePostalController.dispose();
    _superficieController.dispose();
    _nombrePiecesController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _addImage() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty && !_images.contains(url)) {
      setState(() {
        _images.add(url);
        _imageUrlController.clear();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    if (!authController.isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous devez être connecté pour ajouter un bien'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final bien = BienImmobilier(
      id: widget.bienToEdit?.id,
      titre: _titreController.text.trim(),
      description: _descriptionController.text.trim(),
      prix: double.parse(_prixController.text.trim()),
      adresse: _adresseController.text.trim(),
      ville: _villeController.text.trim(),
      codePostal: _codePostalController.text.trim(),
      type: _selectedType,
      superficie: int.parse(_superficieController.text.trim()),
      nombrePieces: int.parse(_nombrePiecesController.text.trim()),
      images: _images,
      userId: widget.bienToEdit?.userId ?? authController.currentUser!.uid,
      dateCreation: widget.bienToEdit?.dateCreation,
      disponible: _selectedStatut == 'En vente',
      statut: _selectedStatut,
    );

    final bienController = context.read<BienController>();
    final bool success = _isEditMode
        ? await bienController.modifierBien(widget.bienToEdit!.id!, bien)
        : await bienController.ajouterBien(bien);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Bien modifié avec succès!'
                : 'Bien ajouté avec succès!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      if (_isEditMode) {
        Navigator.pop(context, true);
      } else {
        _resetForm();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bienController.errorMessage ??
                (_isEditMode
                    ? 'Erreur lors de la modification'
                    : 'Erreur lors de l\'ajout'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _titreController.clear();
    _descriptionController.clear();
    _prixController.clear();
    _adresseController.clear();
    _villeController.clear();
    _codePostalController.clear();
    _superficieController.clear();
    _nombrePiecesController.clear();
    _imageUrlController.clear();
    setState(() {
      _images.clear();
      _selectedType = 'Appartement';
      _selectedStatut = 'En vente';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Modifier le bien' : 'Ajouter un bien'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prixController,
                      decoration: const InputDecoration(
                        labelText: 'Prix (\$) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un prix';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Prix invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type *',
                        border: OutlineInputBorder(),
                      ),
                      items: _types.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatut,
                decoration: const InputDecoration(
                  labelText: 'Statut du bien *',
                  border: OutlineInputBorder(),
                ),
                items: _statuts.map((statut) {
                  return DropdownMenuItem(
                    value: statut,
                    child: Text(statut),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedStatut = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(
                  labelText: 'Adresse *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une adresse';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _villeController,
                      decoration: const InputDecoration(
                        labelText: 'Ville *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une ville';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _codePostalController,
                      decoration: const InputDecoration(
                        labelText: 'Code postal *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un code postal';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _superficieController,
                      decoration: const InputDecoration(
                        labelText: 'Superficie (m²) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une superficie';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Superficie invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _nombrePiecesController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de pièces *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nombre de pièces';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Nombre invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Images (URLs)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL de l\'image',
                        border: OutlineInputBorder(),
                        hintText: 'https://example.com/image.jpg',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addImage,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            Image.network(
                              _images[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                );
                              },
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                color: Colors.red,
                                onPressed: () => _removeImage(index),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Consumer<BienController>(
                builder: (context, bienController, _) {
                  return ElevatedButton(
                    onPressed: bienController.isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: bienController.isLoading
                        ? const CircularProgressIndicator()
                        : Text(_isEditMode
                            ? 'Enregistrer les modifications'
                            : 'Ajouter le bien'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
