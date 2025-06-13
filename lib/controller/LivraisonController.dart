
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/services/ApiServiceLivraison.dart';
import 'package:menji/view/client/commander.dart';

import '../serviceAu/local_storage_service.dart';
import '../utils/elpers/elperDate.dart';
import '../view/client/suivisColis.dart';
import '../view/livreur/pageAccueilleLivreur.darT';


class LivraisonController {
  late ApiServiceLivraison v;

  Future<void> init () async {
        v = ApiServiceLivraison();
       await v.init();
  }

  Future<List<Map<String,String>>> getForExpeditaire(int id) async{
     final donneesLivraison= await v.getLivraisonExpediteur(id);
     return donneesLivraison;
  }


  Future<List<Map<String,String>>> getForDestinataire(int id) async{

    final donneesLivraison= await v.getLivraisonDestinateur(id);
    return donneesLivraison;
  }

  void create(List<String> nom_type,BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PageCommander(nom_type)),
    );
  }


  void cancel(String id_livraison,BuildContext context){
    v.annuler(id_livraison);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("vous avez annulee une livraison")),
    );
  }


  void editLivraisonLivreur(BuildContext context,String id_livraison,String montant, String kilo){

    v.editLivraisonLivreur(id_livraison, montant, kilo);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PageLivreur()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Livraison confirme  !')),
    );
  }

  void confirm(BuildContext context,String id_livraison,String code_livraison)async{

     v.confirmerLivraison(id_livraison, code_livraison);
     Navigator.pop(context);

     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('le statut est change avec succes')),
    );

  }

  Future<bool> store ( dynamic id_expediteur,
      dynamic id_destinateur,
      dynamic nom,
      dynamic adresseExpedition,
      dynamic adresseDestination,
      dynamic telephoneDestination,
      dynamic telephoneExpediteur,
      dynamic moyenTransport,
      dynamic context,
      dynamic longitude_expedition,
      dynamic latitude_expedition,
      dynamic longitude_destination,
      dynamic latitude_destination) async{


     bool isStore =await v.SaveLivraison(id_expediteur,
          id_destinateur,
          nom,adresseExpedition,
          adresseDestination,
          telephoneDestination,
          telephoneExpediteur,
          moyenTransport,
          longitude_expedition,
          latitude_expedition,
          longitude_destination,
          latitude_destination
      );


     return isStore;
  }

  Future<List<Map<String,String>>> getForLivreur(int id_livreur) async{

    final donneesLivraison= await v.getLivraisonLivreur(id_livreur);
    return donneesLivraison;
  }


  Future<List<Map<String,String>>> ShowForLivreur(String id_livreur, String id_livraison) async{


    final donneesLivraison= await v.showLivraisonLivreur(id_livreur,id_livraison);

    return donneesLivraison;
  }

     Suivre(context, String id) {


       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => SuivisColis(id)),
       );


      }

  Future<String> setLocalisation(dynamic longitude,dynamic latitude,dynamic id_livraison) {

    return v.setLocalisation(longitude,latitude,id_livraison);

  }

  Future<Map<String,dynamic>> getLocalisation(String id) {
    return v.getLocalisation(id);
    
  }



}

