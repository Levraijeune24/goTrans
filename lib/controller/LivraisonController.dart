
import 'package:flutter/material.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/services/ApiLivraison.dart';




class LivraisonController {


  BuildContext context;

  LivraisonController(this.context);


  void createLivraison() async{
    final donnees= await Apilivraison().typeVehicule();
    print(donnees);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp(donnees)),
    );
  }





}

