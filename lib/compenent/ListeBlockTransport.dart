
import 'package:flutter/material.dart';
import 'package:menji/compenent/blockMoyenTransport.dart';
import 'package:menji/controller/LivraisonController.dart';

import '../model/TypeVehiculeModel.dart';

class Listeblocktransport {

  BuildContext context;
  List<Map<String, String>> typeVehicules = [];


  Listeblocktransport({ required
    this.typeVehicules, required this.context
});


  List<Widget> Run(){
    List<Widget> MoyenTransports = [];

    this.typeVehicules.forEach((typeVehile) {

          String? kilo_initiale= typeVehile["kilo_initiale"];
          String? kilo_final= typeVehile["kilo_final"];
          String? nom_type= typeVehile["nom_type"];

          VehiculeType typeVehicule=VehiculeType(
            name: nom_type!,
            description:typeVehile["description"]! ,
            imagePath: "images/Icone_moto.png",
            tarif: "",
            capacite: "",
            vitesse: "",
            prix_tarif: typeVehile["prix_tarif"]!,
            kilo_tarif: typeVehile["kilo_tarif"]!,
            kilo_initiale:typeVehile["kilo_initiale"]!,
            kilo_finale: typeVehile["kilo_final"]!
          );

          MoyenTransports.add(
              _buildCategoryItem(
                context,
                imagePath: 'images/Icone_moto.png',
                label: nom_type?? "inconnue",
                onTap: () => LivraisonController().createScreen(typeVehicule,context),
              )
          );

    });


    return MoyenTransports;


  }


}

Widget _buildCategoryItem(
    BuildContext context, {
      required String imagePath,
      required String label,
      required VoidCallback onTap,
    }) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: screenHeight * 0.17,
      width: screenWidth * 0.30,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [

        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 6,
            child: Image.asset(
              imagePath,
              height: screenHeight * 0.08,
              width: screenWidth * 0.26,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 40, color: Colors.red);
              },
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            flex: 3,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: screenWidth * 0.030,
                fontWeight: FontWeight.w600,
                fontFamily: 'Segoe UI',
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


