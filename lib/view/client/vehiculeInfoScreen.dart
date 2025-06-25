
import 'package:flutter/material.dart';
import 'package:menji/view/redesign/pageAccueille.dart';

import '../../compenent/AppBarCostum.dart';
import '../../controller/LivraisonController.dart';
import '../../model/TypeVehiculeModel.dart';



class VehiculeInfoScreen extends StatelessWidget {
  final VehiculeType vehicleType;

  const VehiculeInfoScreen({super.key, required this.vehicleType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCostum(context:context,libelle:"Description du vehicule").run(),
      body: Column(
        children: [
          // Container avec dégradé orange
          Container(
            height: MediaQuery.of(context).size.height * 0.35, // Réduit un peu pour l'AppBar
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(380),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.yellow[800]!,
                  Colors.yellow[600]!,
                  Colors.yellow[400]!,
                ],
                stops: const [0.1, 0.5, 0.9],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    vehicleType.imagePath,
                    height: 160, // Ajusté pour l'AppBar
                    width: 160,  // Ajusté pour l'AppBar
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),

          // Partie inférieure avec les informations
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicleType.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Description
                  Text(
                    'Description :',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow[700],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    vehicleType.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Divider(thickness: 0.4),

                  // Tarif
                  _buildInfoItem('Tarif par poids :', vehicleType.prix_tarif +" Fc par "+vehicleType.kilo_tarif+" Kg"),
                  const Divider(thickness: 0.4),

                  // Capacité
                  _buildInfoItem('Capacité maximale :',vehicleType.kilo_initiale +" Kg et "+vehicleType.kilo_finale+" Kg"),
                  const Divider(thickness: 0.4),

                  // Vitesse
                  _buildInfoItem('Vitesse moyenne estimée:', vehicleType.vitesse),
                  const Divider(thickness: 0.4),

                  // Bouton Commander
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 1,
                        ),
                        onPressed: () {
                          LivraisonController().create(vehicleType.name, context);
                        },
                        child: const Text(
                          'Commander',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}