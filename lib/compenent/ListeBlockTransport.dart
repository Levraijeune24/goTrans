
import 'package:flutter/material.dart';
import 'package:menji/compenent/blockMoyenTransport.dart';
import 'package:menji/controller/LivraisonController.dart';



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
      MoyenTransports.add(
          BlockMoyenTransport((){
            LivraisonController().creationLivraison([" $nom_type : $kilo_initiale kg - $kilo_final kg",nom_type!],context);
          }, context: context,
              image: "images/Taxi.png", title: nom_type?? "inconnue", description: "$kilo_initiale kg - $kilo_final kg").Run()
      );

    });


    return MoyenTransports;


  }


}