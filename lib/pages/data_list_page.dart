import 'package:flutter/material.dart';
import '../models/sac.dart';
import '../services/database_service.dart';
import 'form_page.dart';

class DataListPage extends StatefulWidget {
  const DataListPage({super.key});

  @override
  _DataListPageState createState() => _DataListPageState();
}

class _DataListPageState extends State<DataListPage> {
  final DatabaseService _dbService = DatabaseService();
  late Future<List<Sac>> _sacsFuture;

  @override
  void initState() {
    super.initState();
    _sacsFuture = _dbService.getSacs();
  }

  Future<void> _refreshData() async {
    setState(() {
      _sacsFuture = _dbService.getSacs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Données Collectées'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<Sac>>(
        future: _sacsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune donnée enregistrée.'));
          } else {
            final sacs = snapshot.data!;
            return ListView.builder(
              itemCount: sacs.length,
              itemBuilder: (context, index) {
                final sac = sacs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: Icon(
                      sac.estSynchronise ? Icons.cloud_done : Icons.cloud_upload,
                      color: sac.estSynchronise ? Colors.green : Colors.orange,
                    ),
                    title: Text('Producteur: ${sac.nomProducteur}'),
                    subtitle: Text('UUID: ${sac.uuid}\nPoids: ${sac.poids} kg\nDate: ${sac.dateRecolte.toLocal().toString().split(' ')[0]}'),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormPage(
                            sacToEdit: sac,
                            sacUuid: sac.uuid,
                            producteurData: {
                              'producteur_id': sac.producteurId,
                              'nom': sac.nomProducteur,
                              'region': sac.regionProducteur,
                            },
                          ),
                        ),
                      ).then((_) {
                        // Recharger la liste après la modification
                        _refreshData();
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}