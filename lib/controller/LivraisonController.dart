
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/services/ApiLivraison.dart';
import 'package:menji/view/client/commander.dart';

import '../serviceAu/local_storage_service.dart';
import '../view/livreur/pageAccueilleLivreur.darT';


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

  Future<List<Map<String,String>>> AllLivraisonDestinateur(int id) async{

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

  void editLivraisonLivreur(BuildContext context,String id_livraison,String montant, String kilo){

    Apilivraison().editLivraisonLivreur(id_livraison, montant, kilo);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PageLivreur()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Livraison confirme  !')),
    );
  }

  void confirmerLivraison(BuildContext context,String id_livraison,String code_livraison)async{

     v.confirmerLivraison(id_livraison, code_livraison);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PageAccueil()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Livraison termine')),
    );


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



  Future<List<Map<String,String>>> AllLivraisonLivreur(int id_livreur) async{

    final donneesLivraison= await Apilivraison().getLivraisonLivreur(id_livreur);
    return donneesLivraison;
  }


  Future<List<Map<String,String>>> ShowLivraisonLivreur(String id_livreur, String id_livraison) async{


    final donneesLivraison= await Apilivraison().showLivraisonLivreur(id_livreur,id_livraison);

    return donneesLivraison;
  }

}

