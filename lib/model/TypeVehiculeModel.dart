






class VehiculeType {
  final String name;
  final String description;
  final String imagePath;
  final String tarif;
  final String capacite;
  final String vitesse;

  final String kilo_initiale;
  final String kilo_finale;

  final String kilo_tarif;
  final String prix_tarif;

  VehiculeType({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.tarif,
    required this.capacite,
    required this.vitesse,
    required this.kilo_tarif,
    required this.prix_tarif,

    required this.kilo_initiale,
    required this.kilo_finale
  });
}
