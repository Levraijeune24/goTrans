import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:menji/utils/elpers/elperDate.dart';
import 'package:menji/utils/elpers/elperLivraisons.dart';

import '../controller/authController.dart';
import '../serviceAu/local_storage_service.dart';


class Apilivraison {

   String? token;
  final adresse="https://gotrans.menjidrc.com/";

  void setToken(String token) {
    this.token = token;
  }
  
  Future<void> fetLivraison(String id) async {


    final url = Uri.parse(adresse+'api/livraison/getLivraisonDestinateur/$id');


    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',  // On envoie le token ici
      }
    );

    print('Statut : ${response.statusCode}');
    print('Réponse brute : ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Livraison reçue : $data');
      // tu peux retourner ou manipuler les données ici
    } else {
      print('Erreur : ${response.statusCode}');
    }
  }

  Future<List<Map<String,String>>> typeVehicule() async {

    print(token);

    List<Map<String,String>> mesTypes=[];

    final url = Uri.parse(adresse+'api/typeVehicule');


    final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',  // On envoie le token ici
        }
    );

    print('Statut : ${response.statusCode}');


    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      data["typeVehicule"].forEach((typeVehile) {

        mesTypes.add({"id":typeVehile["id"].toString(),
          "nom_type":typeVehile["nom_type"],
          "kilo_initiale":typeVehile["kilo_initiale"].toString(),
          "kilo_final":typeVehile["kilo_final"].toString(),

        },
        );


      });

    } else {
      print('Erreur : ${response.statusCode}');
    }
    return mesTypes;
  }

  Future<void>  Connection ()async {

    final url = Uri.parse(adresse+'api/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json'
        // On envoie le token ici
      },
      body: jsonEncode({
        "email":"benikasu@gmail.com",
        "password": "password" // ou d'autres données nécessaires à l'API
      }),
    );

  }

  Future<void>  SaveLivraison (String id_expediteur, String id_destinateur,String nom,String adresseExpedition,
      String adresseDestination,
      String telephoneDestination,String telephoneExpedition ,String moyenTransport)async {


    final url = Uri.parse(adresse+'api/livraison/store');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        "adresse_expedition":adresseExpedition,
        "tel_expedition": telephoneExpedition,
        "adresse_destination":adresseDestination,
        "tel_destination":telephoneDestination,
      'nom_destination':nom,
        "date":dateDuJour(),
        "code":genererCodeLivraison(),
        "status":"en_attente",
        "montant":"",
        "Kilo_total":"",
        "client_expediteur_id": id_expediteur,
        "client_destinateur_id":id_destinateur,
        "moyen_transport":moyenTransport
      }),
    );
    final data = jsonDecode(response.body);
    print('beniiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii');
    print(data);

  }

  Future<List<Map<String,String>>> getLivraison (int id) async {

    List<Map<String,String>> livraisons=[];

    final url = Uri.parse(adresse+'api/livraison/getLivraisonExpediteur/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      data["data"].forEach((livraison) {

        livraisons.add({"id":livraison["id"].toString(),
          "status":livraison["status"],
          "date":livraison["date"],
          "moyen_transport":livraison["moyen_transport"],

        },
        );

      });}

    return livraisons;

  }

   Future<List<Map<String,String>>> getLivraisonDestinateur (int id) async {

     List<Map<String,String>> livraisons=[];

     final url = Uri.parse(adresse+'api/livraison/getLivraisonDestinateur/$id');

     final response = await http.get(
         url,
         headers: {
           'Content-Type': 'application/json',
           'Authorization': 'Bearer $token'
         }
     );
     final data = jsonDecode(response.body);
     if (response.statusCode == 200) {

       final data = jsonDecode(response.body);
       data["data"].forEach((livraison) {

         livraisons.add({"id":livraison["id"].toString(),
           "status":livraison["status"],
           "date":livraison["date"],
           "moyen_transport":livraison["moyen_transport"],

         },
         );

       });}

     return livraisons;

   }

   Future<List<Map<String,String>>> getLivraisonLivreur (int id) async {

     List<Map<String,String>> livraisons=[];

     final url = Uri.parse(adresse+'api/livraison/getLivraisonLivreur/$id');

     final response = await http.get(
         url,
         headers: {
           'Content-Type': 'application/json',
           'Authorization': 'Bearer '+'2|mbb2JWJK15qVJUDtUgn5Eg20qfdMIbohHsYE6m5wfdef70e0'
         }
     );
     final data = jsonDecode(response.body);
     if (response.statusCode == 200) {

       final data = jsonDecode(response.body);

       data["data"].forEach((livraison) {

         livraisons.add({"id_livraison":livraison["id_livraison"].toString(),
           "immatriculation":livraison["immatriculation"],
           "nom_expediteur":livraison["nom_expediteur"],
           "nom_destinateur":livraison["nom_destinateur"],
           "date":livraison["date"],
           "status":livraison["status"],
           "id_livreur":livraison["livreur_id"].toString()

         },);

        }
       );


     }
     return livraisons;
       }


   Future<List<Map<String,String>>> showLivraisonLivreur (String id_livreur, String id_livraison) async {

     List<Map<String,String>> livraisons=[];

     final url = Uri.parse(adresse+'api/livraison/showLivraisonLivreur/$id_livreur/$id_livraison');

     print(url);

     final response = await http.get(
         url,
         headers: {
           'Content-Type': 'application/json',
           'Authorization': 'Bearer '+'2|mbb2JWJK15qVJUDtUgn5Eg20qfdMIbohHsYE6m5wfdef70e0'
         }
     );
     final data = jsonDecode(response.body);
     if (response.statusCode == 200) {

       final data = jsonDecode(response.body);
       print("HHHHHHHHH");
       print(data);
       data["data"].forEach((livraison) {

         livraisons.add({"id_livraison":livraison["id_livraison"].toString(),
           "immatriculation":livraison["immatriculation"],
           "nom_expediteur":livraison["nom_expediteur"],
           "nom_destinateur":livraison["nom_destinateur"],
           "adresse_expedition":livraison["adresse_expedition"],
           "tel_expedition":livraison["tel_expedition"],
           "adresse_destination":livraison["adresse_destination"],
           "tel_destination":livraison["tel_destination"]?? "",
         },);



       }
       );


     }
     return livraisons;
   }


  Future<String> annuler (String id) async {

    final url = Uri.parse(adresse+'api/livraison/cancel/$id');

    final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer '+'2|mbb2JWJK15qVJUDtUgn5Eg20qfdMIbohHsYE6m5wfdef70e0'
          // On envoie le token ici
        }
    );

    final data = jsonDecode(response.body);
    print(data);

    return data;


  }


   Future<String> editLivraisonLivreur (String id_livraison,String montant, String kilo) async {

     final url = Uri.parse(adresse+'api/livraison/en_cours');

     final response = await http.post(
         url,
         headers: {
           'Content-Type': 'application/json',
           'Authorization': 'Bearer '+'2|mbb2JWJK15qVJUDtUgn5Eg20qfdMIbohHsYE6m5wfdef70e0'
           // On envoie le token ici
         },
         body: jsonEncode({
           "id":id_livraison,
           "montant":montant,
           "poid": kilo // ou d'autres données nécessaires à l'API
         })
     );

     final data = jsonDecode(response.body);
     print(data);

     return data;


   }

  Future<List<Map<String,String>>> getClient () async {
    print("iciiciicicicicicicic");

    List<Map<String,String>> clients=[];

    final url = Uri.parse(adresse+'api/user/clients');

    final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    final data = jsonDecode(response.body);


    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      data["data"].forEach((client) {

        clients.add({"id":client["id"].toString(),
          "nom":client["user"]["name"],
        },
        );

      });}
    return clients;




  }

   Future<String> confirmerLivraison(String id_livraison, String codeLivraison)async{

    final url = Uri.parse(adresse+'api/livraison/terminer');

    final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer '+'2|mbb2JWJK15qVJUDtUgn5Eg20qfdMIbohHsYE6m5wfdef70e0'
          // On envoie le token ici
        },
        body: jsonEncode({
          "id":id_livraison,
          "codeLivraison":codeLivraison
        })
    );

    final data = jsonDecode(response.body);
    print(data);

    return data;

  }


}