
import 'package:flutter/material.dart';
import 'package:menji/view/redesign/suivi.dart';

import '../../compenent/ButtonClient.dart';
import '../../compenent/Commande.dart';
import '../../compenent/MenuNavgation.dart';
import 'commander.dart';
import 'historique.dart';



// 1. Enum pour les types de véhicules
enum VehicleType { moto, camion, grosCamion }

// 2. Extension pour les propriétés de chaque type
extension VehicleTypeExtension on VehicleType {
  String get name {
    switch (this) {
      case VehicleType.moto:
        return 'Moto';
      case VehicleType.camion:
        return 'Camion';
      case VehicleType.grosCamion:
        return 'Gros Camion';
    }
  }

  String get description {
    switch (this) {
      case VehicleType.moto:
        return 'Véhicule à deux roues adapté pour la livraison rapide de colis légers ou de petits objets.';
      case VehicleType.camion:
        return 'Véhicule adapté pour le transport de charges moyennes en ville.';
      case VehicleType.grosCamion:
        return 'Véhicule lourd adapté pour le transport de grandes quantités ou charges lourdes.';
    }
  }

  String get imagePath {
    switch (this) {
      case VehicleType.moto:
        return 'images/moto.png';
      case VehicleType.camion:
        return 'images/moto.png';
      case VehicleType.grosCamion:
        return 'images/moto.png';
    }
  }

  String get tarif {
    switch (this) {
      case VehicleType.moto:
        return '1\$';
      case VehicleType.camion:
        return '15\$';
      case VehicleType.grosCamion:
        return '30\$';
    }
  }

  String get capacite {
    switch (this) {
      case VehicleType.moto:
        return '1 colis ou jusqu\'à 30 kg';
      case VehicleType.camion:
        return 'Jusqu\'à 20 colis ou 500 kg';
      case VehicleType.grosCamion:
        return 'Jusqu\'à 100 colis ou 2000 kg';
    }
  }

  String get vitesse {
    switch (this) {
      case VehicleType.moto:
        return '40-60 km/h';
      case VehicleType.camion:
        return '30-50 km/h';
      case VehicleType.grosCamion:
        return '20-40 km/h';
    }
  }
}



class HomePages extends StatefulWidget {
  const HomePages({super.key});

  @override
  State<HomePages> createState() => _HomePageState();
}

class _HomePageState extends State<HomePages> {
  int _currentIndex = 0;
  int _selectedDeliveryIndex = 0;

  void _navigateToVehicleScreen(VehicleType vehicleType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleInfoScreen(vehicleType: vehicleType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: const Text(
            'Accueil',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Image.asset(
                    'images/Icone_notif.png',
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {

                    });
                  },
                )
              ],
            ),
          ],
        ),
          bottomNavigationBar: MenuNavigation(
          action: (index){
      setState(() {
        _currentIndex = index;
      });
    },
    currentIndex: _currentIndex
    ).run(),


        body:SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 24),
                      children: [
                        const TextSpan(
                          text: 'Bienvenu ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                        TextSpan(
                          text: "Bob",
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.orange,
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryItem(
                        context,
                        imagePath: 'images/moto.png',
                        label: 'Moto',
                        onTap: () => _navigateToVehicleScreen(VehicleType.moto),
                      ),
                      _buildCategoryItem(
                        context,
                        imagePath: 'images/moto.png',
                        label: 'Camion',
                        onTap: () => _navigateToVehicleScreen(VehicleType.camion),
                      ),
                      _buildCategoryItem(
                        context,
                        imagePath: 'images/moto.png',
                        label: 'Gros camion',
                        onTap: () => _navigateToVehicleScreen(VehicleType.grosCamion),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Mes livraisons',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Segoe UI',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ButtonClient(
                        isSelected: false,
                          libelle: "Entrant",
                          height: 40,
                          action: (){
                            setState(() {
                              _selectedDeliveryIndex = 1;
                            });

                          }
                      ).run(),
                      const SizedBox(width: 20),

                      ButtonClient(
                        libelle: "Sortant",
                          height: 40,
                        action: (){
                          setState(() {
                            _selectedDeliveryIndex = 1;
                          });
                        }
                      ).run(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Commande(
                    status:" En attente de validation" ,
                    titre: "Commande #4578966 ",
                    itineraire: "De : Combe > Lingwala",
                    date: "04 Juin 2025 -09h00", actions: [

                      ButtonClient(
                          libelle: "Suivre",
                          action: (){
                          }
                      ).run(),
                      ButtonClient(
                          libelle: "Fin course",
                          action: (){
                          }
                      ).run()

                  ], actionVoirPlus: ( ) {

                  }
                  ).run(),

                ],
              ),
            ),
          ),

      );
  }

  Widget _buildCategoryItem(
      BuildContext context, {
        required String imagePath,
        required String label,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(//
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.only(top: 25),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(245, 240, 250, 1.0),
          borderRadius: BorderRadius.circular(12),

        ),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              height: 50,
              width: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 40, color: Colors.red);
              },
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Segoe UI',
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryStatus(
      String status, {
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        constraints: const BoxConstraints(minWidth: 100),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : const Color.fromRGBO(245, 240, 250, 1.0),
          borderRadius: BorderRadius.circular(8),

        ),
        child: Center(
          child: Text(
            status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}