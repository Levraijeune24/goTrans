
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/services/ApiLivraison.dart';
import 'package:menji/view/client/commander.dart';




class LivraisonController {


  BuildContext context;

  LivraisonController(this.context);


  void createLivraison() async{
    final donnees= await Apilivraison().typeVehicule();
    final donneesLivraison= await Apilivraison().getLivraison(3);


    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp(donnees,donneesLivraison)),
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
      String telephoneDestination,String telephoneExpediteur,String moyenTransport
      ) async{

    try {
      final donnees= await Apilivraison().SaveLivraison(adresseExpedition,
          adresseDestination,telephoneDestination,telephoneExpediteur,moyenTransport);

      createLivraison() ;

      // Afficher le toast de succès
      Fluttertoast.showToast(
        msg: "Livraison créée avec succès ✅",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,

        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      // En cas d’erreur
      Fluttertoast.showToast(
        msg: "Erreur : $e ❌",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }


  }








}

