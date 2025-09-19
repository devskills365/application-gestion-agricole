// lib/pages/form_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/sac.dart';
import '../services/database_service.dart';

class FormPage extends StatefulWidget {
  final String? sacUuid;
  final Map<String, dynamic>? producteurData;
  final Sac? sacToEdit;

  const FormPage({
    super.key,
    this.sacUuid,
    this.producteurData,
    this.sacToEdit,
  });

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _poidsController = TextEditingController();
  final _qualiteController = TextEditingController();
  DateTime? _dateRecolte;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    // Utilise les données du sac existant en mode modification
    if (widget.sacToEdit != null) {
      _dateRecolte = widget.sacToEdit!.dateRecolte;
    }
  }

  @override
  void dispose() {
    _poidsController.dispose();
    _qualiteController.dispose();
    super.dispose();
  }

  void _saveData() async {
    if (_formKey.currentState!.validate() && _dateRecolte != null) {
      // Détermine si c'est une création ou une modification et récupère les données
      String uuid = widget.sacToEdit?.uuid ?? widget.sacUuid!;
      String producteurId = widget.sacToEdit?.producteurId ?? widget.producteurData!['producteur_id'];
      String nomProducteur = widget.sacToEdit?.nomProducteur ?? widget.producteurData!['nom'];
      String regionProducteur = widget.sacToEdit?.regionProducteur ?? widget.producteurData!['region'];
      bool estSynchronise = widget.sacToEdit?.estSynchronise ?? false;

      // Crée l'objet Sac en utilisant directement la valeur String du TextEditingController
      final sac = Sac(
        uuid: uuid,
        producteurId: producteurId,
        nomProducteur: nomProducteur,
        regionProducteur: regionProducteur,
        poids: _poidsController.text,
        dateRecolte: _dateRecolte!,
        qualite: _qualiteController.text,
        estSynchronise: estSynchronise,
      );

      // Utilise une seule méthode de sauvegarde dans DatabaseService (saveSac)
      await _dbService.saveSac(sac);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Données du sac enregistrées !')),
      );

      // Retourne à la page précédente
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs et sélectionner une date.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Détermine les données du producteur à afficher de manière sécurisée
    final String producteurNom = widget.sacToEdit?.nomProducteur ?? (widget.producteurData?['nom'] ?? 'Inconnu');
    final String producteurRegion = widget.sacToEdit?.regionProducteur ?? (widget.producteurData?['region'] ?? 'Inconnu');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sacToEdit != null ? 'Modifier la collecte' : 'Détails de la collecte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations du producteur',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8.0),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.green),
                title: Text(producteurNom),
                subtitle: const Text('Producteur'),
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.green),
                title: Text(producteurRegion),
                subtitle: const Text('Région'),
              ),
              const Divider(),
              Text(
                'Données de la récolte',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _poidsController,
                decoration: const InputDecoration(labelText: 'Poids (kg)'),
                keyboardType: TextInputType.number,

              ),
              TextFormField(
                controller: _qualiteController,
                decoration: const InputDecoration(labelText: 'Qualité'),

              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dateRecolte ?? DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _dateRecolte = picked;
                    });
                  }
                },
                child: Text(_dateRecolte == null ? 'Sélectionner une date' : 'Date: ${_dateRecolte!.day}/${_dateRecolte!.month}/${_dateRecolte!.year}'),
              ),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _saveData,
                  child: Text(widget.sacToEdit != null ? 'Modifier les données' : 'Enregistrer et valider'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}