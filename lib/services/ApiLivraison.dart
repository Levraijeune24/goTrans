import 'dart:convert';
import 'package:http/http.dart' as http;



class Apilivraison {
  final String token;




  Apilivraison({this.token="2|T9Of60n4r1IjQuu8j1L9jeZ788sSS3n6q1Ak3p9B7673c987"});

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

    print('Statut : ${response.statusCode}');
    print('Réponse brute : ${response.body}');



  }
}