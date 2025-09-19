class Sac {
  final String uuid;
  final String producteurId;
  final String nomProducteur;
  final String regionProducteur;
  final String? poids; // Rendu optionnel
  final DateTime dateRecolte;
  final String? qualite; // Rendu optionnel
  bool estSynchronise;

  Sac({
    required this.uuid,
    required this.producteurId,
    required this.nomProducteur,
    required this.regionProducteur,
    this.poids, // Pas required
    required this.dateRecolte,
    this.qualite, // Pas required
    this.estSynchronise = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'producteur_id': producteurId,
      'nom_producteur': nomProducteur,
      'region_producteur': regionProducteur,
      'poids': poids, // Peut être null
      'date_recolte': dateRecolte.toIso8601String(),
      'qualite': qualite, // Peut être null
      'est_synchronise': estSynchronise ? 1 : 0,
    };
  }

  factory Sac.fromMap(Map<String, dynamic> map) {
    return Sac(
      uuid: map['uuid'],
      producteurId: map['producteur_id'],
      nomProducteur: map['nom_producteur'],
      regionProducteur: map['region_producteur'],
      poids: map['poids'], // Peut être null
      dateRecolte: DateTime.parse(map['date_recolte']),
      qualite: map['qualite'], // Peut être null
      estSynchronise: map['est_synchronise'] == 1,
    );
  }
}