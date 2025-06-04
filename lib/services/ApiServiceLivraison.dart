import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:menji/utils/elpers/elperDate.dart';
import 'package:menji/utils/elpers/elperLivraisons.dart';

import '../controller/authController.dart';
import '../serviceAu/local_storage_service.dart';


class Apilivraison {

   String? token;
  final adresse="https://gotrans.menjidrc.com/";


   Future<void> init() async {
     print("Initialisation en cours...");
     token = await LocalStorageService().getToken();
     print("Token récupéré : $token");
   }
  

  Future<List<Map<String,String>>> typeVehicule() async {

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

  Future<void>  SaveLivraison (String id_expediteur,
      String id_destinateur,
      String nom,
      String adresseExpedition,
      String adresseDestination,
      String telephoneDestination,
      String telephoneExpedition ,
      String moyenTransport,
      String longitude_expedition,
      String latitude_expedition,
      String longitude_destination,
      String latitude_destination,

      )async {


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
        "moyen_transport":moyenTransport,
        //
        "longitude_expedition":longitude_expedition,
        "latitude_expedition":latitude_expedition,
        "longitude_destination":longitude_destination,
        "latitude_destination":latitude_destination
      }),
    );
    final data = jsonDecode(response.body);
    print(data);
  }

  Future<List<Map<String,String>>> getLivraisonExpediteur (int id) async {

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
          "code":livraison["code"],
          "adresse_expedition":livraison["expedition"]["adresse"],
          "expediteur_id":livraison["expediteur"]["id"].toString(),
          "adresse_destination":livraison["destination"]["adresse"],
          "moyen_transport":livraison["moyen_transport"],
          "expediteur": livraison["expediteur"]?["user"]?["name"] ?? "",
          "destinateur": livraison["destinateur"]?["user"]?["name"] ?? "${livraison["destination"]["nom_destination"]} (n'esxiste pas)",

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
           "code":livraison["code"],
           "adresse_expedition":livraison["expedition"]["adresse"],
           "adresse_destination":livraison["destination"]["adresse"],
           "moyen_transport":livraison["moyen_transport"],
           "expediteur_id":livraison["expediteur"]["id"].toString(),
           "expediteur": livraison["expediteur"]?["user"]?["name"] ?? "",
           "destinateur": livraison["destinateur"]?["user"]?["name"] ?? "${livraison["destination"]["nom_destination"]} (n'esxiste pas)",
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
           'Authorization': 'Bearer $token'
         }
     );
     final data = jsonDecode(response.body);
     if (response.statusCode == 200) {

       final data = jsonDecode(response.body);


       data["data"].forEach((livraison) {
         print(livraison["vehicule"]["livreurs"][0].toString());
         livraisons.add({"id":livraison["id"].toString(),
           "id_livreur":livraison["vehicule"]["livreurs"][0]["id"].toString(),
           "status":livraison["status"],
           "date":livraison["date"],
           "code":livraison["code"],
           "adresse_expedition":livraison["expedition"]["adresse"],
           "adresse_destination":livraison["destination"]["adresse"],
           "moyen_transport":livraison["moyen_transport"],
           "expediteur": livraison["expediteur"]?["user"]?["name"] ?? "",
           "destinateur": livraison["destinateur"]?["user"]?["name"] ?? "${livraison["destination"]["nom_destination"]} (n'esxiste pas)",
         },
         );
        }
       );


     }
     return livraisons;
       }


   Future<List<Map<String,String>>> showLivraisonLivreur (String id_livreur, String id_livraison) async {

     List<Map<String,String>> livraisons=[];

     final url = Uri.parse(adresse+'api/livraison/showLivraisonLivreur/$id_livreur/$id_livraison');

     final response = await http.get(
         url,
         headers: {
           'Content-Type': 'application/json',
           'Authorization': 'Bearer $token'
         }
     );

     if (response.statusCode == 200) {

       final data = jsonDecode(response.body);


       data["data"].forEach((livraison) {



         livraisons.add({"id":livraison["id"].toString(),
           "id_livreur":livraison["vehicule"]["livreurs"][0]["id"].toString(),
           "tarif":livraison["vehicule"]["type_vehicule"]["tarif"]["prix_tarif"].toString(),
           "status":livraison["status"],
           "expedition_longitude":livraison["expedition"]["longitude"].toString(),
           "expedition_latitude":livraison["expedition"]["latitude"].toString(),


           "date":livraison["date"],
           "code":livraison["code"],
           "adresse_expedition":livraison["expedition"]["adresse"],
           "tel_expedition":livraison["expedition"]["tel_expedition"]?? "",
           "tel_destination":livraison["destination"]["tel_destination"]?? "",
           "adresse_destination":livraison["destination"]["adresse"],
           "moyen_transport":livraison["moyen_transport"],
           "expediteur": livraison["expediteur"]?["user"]?["name"] ?? "",
           "destinateur": livraison["destinateur"]?["user"]?["name"] ?? "${livraison["destination"]["nom_destination"]} (n'esxiste pas)",
         },
         );



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
          'Authorization': 'Bearer $token'
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
           'Authorization': 'Bearer $token'
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
          "email":client["user"]["email"],
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
          'Authorization': 'Bearer $token'
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