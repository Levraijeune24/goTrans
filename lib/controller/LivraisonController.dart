
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/services/ApiLivraison.dart';
import 'package:menji/view/client/commander.dart';




class LivraisonController {

  Future<List<Map<String,String>>> AllLivraison(int id) async{
     final donneesLivraison= await Apilivraison().getLivraison(id);
     return donneesLivraison;
  }

  void creationLivraison(List<String> nom_type,BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApps(nom_type)),
    );
  }

  void storeLivraison (String adresseExpedition,
      String adresseDestination,
      String telephoneDestination,String telephoneExpediteur,String moyenTransport
      ,BuildContext context) async{

      final donnees= await Apilivraison().SaveLivraison(adresseExpedition,
          adresseDestination,telephoneDestination,telephoneExpediteur,moyenTransport);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
  }



}

