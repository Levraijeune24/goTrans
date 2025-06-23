
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
            imagePath: "images/moto.png",
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
                imagePath: 'images/moto.png',
                label: nom_type?? "inconnue",
                onTap: () => LivraisonController().createScreen(typeVehicule,context),
              )
          );

      // MoyenTransports.add(
      //     BlockMoyenTransport((){
      //       LivraisonController().createScreen(typeVehicule,context);
      //     }, context: context,
      //         image: "images/Taxi.png", title: nom_type?? "inconnue", description: "").Run()
      // );

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