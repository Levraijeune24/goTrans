

import 'package:flutter/material.dart';
import 'package:menji/compenent/blockMoyenTransport.dart';



class Listeblocktransport {



  BuildContext context;
  List<Map<String, String>> typeVehicules = [];


  Listeblocktransport({ required
    this.typeVehicules, required this.context
});


  List<Widget> Run(){
    List<Widget> MoyenTransports = [];

    this.typeVehicules.forEach((typeVehile) {

      MoyenTransports.add(
          BlockMoyenTransport((){}, context: context,
              image: "ggg", title: typeVehile["nom_type"]?? "inconnue", description: "").Run()
      );

    });


    return MoyenTransports;


  }


}