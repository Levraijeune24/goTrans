
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/services/ApiLivraison.dart';
import 'package:menji/view/client/commander.dart';

import '../serviceAu/local_storage_service.dart';


class LivraisonController {
  Apilivraison v= Apilivraison();

  setToken() async{
    String? token= await LocalStorageService().getToken();
    v.setToken(token!);
  }




  Future<List<Map<String,String>>> AllLivraison(int id) async{

     final donneesLivraison= await v.getLivraison(id);
     return donneesLivraison;
  }

  void creationLivraison(List<String> nom_type,BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApps(nom_type)),
    );
  }

  void annulerLivraison(String id_livraison,BuildContext context){
    v.annuler(id_livraison);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("vous avez annulee une livraison")),
    );
  }

  void editLivraison(String id_livraison,BuildContext context){

  }

  void storeLivraison (String id_expediteur,String id_destinateur,
      String nom,
      String adresseExpedition,
      String adresseDestination,
      String telephoneDestination,String telephoneExpediteur,String moyenTransport
      ,BuildContext context) async{


      final donnees= await v.SaveLivraison(id_expediteur,id_destinateur,nom,adresseExpedition,
          adresseDestination,telephoneDestination,telephoneExpediteur,moyenTransport);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("la livraison est ajouter avec succes !!!")),
      );
  }

}

