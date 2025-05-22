
import 'package:flutter/material.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/services/ApiLivraison.dart';
import 'package:menji/view/client/commander.dart';




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
  void creationLivraison(List<String> nom_type){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApps(nom_type)),
    );

  }

  void storeLivraison (String adresseExpedition,
      String adresseDestination,
      String telephoneDestination,String moyenTransport
      ) async{
    final donnees= await Apilivraison().SaveLivraison(adresseExpedition,
        adresseDestination,telephoneDestination,moyenTransport);


  }







}

