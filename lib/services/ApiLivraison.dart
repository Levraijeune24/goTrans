import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:menji/utils/elpers/elperDate.dart';
import 'package:menji/utils/elpers/elperLivraisons.dart';


class Apilivraison {

  final String token;

  Apilivraison({this.token="39|5IjcfWeKj7SNyGXYg9GP2KsxJjfWoLqEWFNMmRqh3e56db33"});

  Future<void> fetLivraison(String id) async {

    final url = Uri.parse('https://gotrans.menjidrc.com/api/livraison/getLivraisonDestinateur/$id');


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

    List<Map<String,String>> mesTypes=[];

    final url = Uri.parse('https://gotrans.menjidrc.com/api/typeVehicule');


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

    final url = Uri.parse('https://gotrans.menjidrc.com/api/login');

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

  Future<void>  SaveLivraison (String adresseExpedition,
      String adresseDestination,
      String telephoneDestination,String telephoneExpedition ,String moyenTransport)async {

    final url = Uri.parse('https://gotrans.menjidrc.com/api/livraison/store');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json'
        // On envoie le token ici
      },
      body: jsonEncode({
        "adresse_expedition":adresseExpedition,
        "tel_expedition": telephoneExpedition,
        "adresse_destination":adresseDestination,
        "tel_destination":telephoneDestination,
        "date":dateDuJour(),
        "code":genererCodeLivraison(),
        "status":"en_attente",
        "montant":"",
        "Kilo_total":"",
        "client_expediteur_id": "3",
        "client_destinateur_id":"3",
        "moyen_transport":moyenTransport
      }),
    );
    final data = jsonDecode(response.body);
    print(data);

  }

  Future<List<Map<String,String>>> getLivraison (int id) async {

    List<Map<String,String>> livraisons=[];

    final url = Uri.parse('https://gotrans.menjidrc.com/api/livraison/getLivraisonDestinateur/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json'
        // On envoie le token ici
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
    print(livraisons);
    return livraisons;

  }


}