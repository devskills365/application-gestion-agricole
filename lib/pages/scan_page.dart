// lib/pages/scan_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/database_service.dart';
import '../pages/data_list_page.dart';
import '../pages/form_page.dart';

const url = 'http://192.168.10.114:5000/api/sacs';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final DatabaseService _dbService = DatabaseService();
  String? sacUuid;
  Map<String, dynamic>? producteurData;

  final MobileScannerController _scannerController = MobileScannerController(
    formats: [BarcodeFormat.all],
  );

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty) {
      final barcode = capture.barcodes.first;
      if (barcode.rawValue != null) {
        final String code = barcode.rawValue!;
        _scannerController.stop();

        if (sacUuid == null) {
          final Uri? uri = Uri.tryParse(code);
          if (uri != null && uri.pathSegments.isNotEmpty) {
            final potentialUuid = uri.pathSegments.last;
            if (_estUnUuidValide(potentialUuid)) {
              setState(() => sacUuid = potentialUuid);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sac scanné. Scannez le QR du producteur.'),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ce n\'est pas un QR de sac valide.'),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Veuillez scanner un QR de sac valide.'),
              ),
            );
          }
          _scannerController.start();
        } else {
          try {
            final data = jsonDecode(code);
            if (_estUnProducteurValide(data)) {
              setState(() => producteurData = data);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormPage(
                    sacUuid: sacUuid!,
                    producteurData: producteurData!,
                  ),
                ),
              ).then((_) {
                setState(() {
                  sacUuid = null;
                  producteurData = null;
                });
                _scannerController.start();
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR producteur invalide.')),
              );
              _scannerController.start();
            }
          } catch (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur: QR non valide (JSON attendu).'),
              ),
            );
            _scannerController.start();
          }
        }
      }
    }
  }

  void _syncData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Début de la synchronisation...')),
    );

    final sacsNonSynchronises = await _dbService.getSacsNonSynchronises();
    final headers = {'Content-Type': 'application/json'};

    if (sacsNonSynchronises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune donnée à synchroniser.')),
      );
      return;
    }

    int syncedCount = 0;
    for (var sac in sacsNonSynchronises) {
      if (!_estUnUuidValide(sac.uuid) || !_estUnUuidValide(sac.producteurId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('UUID invalide pour sac ${sac.uuid}')),
        );
        continue;
      }
      if (sac.nomProducteur.isEmpty || sac.regionProducteur.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Données manquantes pour sac ${sac.uuid}')),
        );
        continue;
      }

      final payload = {
        "sac_uuid": sac.uuid,
        "producteur": {
          "producteur_id": sac.producteurId,
          "nom": sac.nomProducteur,
          "region": sac.regionProducteur,
        },
        "details": {
          "poids": sac.poids,
          "date_recolte": sac.dateRecolte.toIso8601String().substring(0, 10),
          "qualite": sac.qualite,
        },
      };

      try {
        final response = await http
            .post(Uri.parse(url), headers: headers, body: jsonEncode(payload))
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 201) {
          await _dbService.marquerCommeSynchronise(sac.uuid);
          syncedCount++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Échec sac ${sac.uuid}: ${response.statusCode}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur sac ${sac.uuid}: $e')));
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Synchronisation terminée ! $syncedCount sacs synchronisés.',
        ),
      ),
    );
  }

  bool _estUnUuidValide(String code) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(code);
  }

  bool _estUnProducteurValide(Map<String, dynamic> data) {
    return data.containsKey('producteur_id') &&
        data.containsKey('nom') &&
        data.containsKey('region');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Agricole'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncData,
            tooltip: 'Synchroniser les données',
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DataListPage()),
              );
            },
            tooltip: 'Voir les données collectées',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  sacUuid == null
                      ? 'Scannez le QR code du sac'
                      : 'Scannez le QR code du producteur',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
