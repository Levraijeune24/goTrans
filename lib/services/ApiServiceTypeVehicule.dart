import 'dart:convert';
import 'package:http/http.dart' as http;
import '../serviceAu/local_storage_service.dart';


class ApiServiceTypeVehicule{

  String? token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  String get _adresse => "https://gotrans.menjidrc.com/";



  Future<void> init() async {
    print("Initialisation en cours...");
    token = await LocalStorageService().getToken();
    print("Token récupéré : $token");
  }



  Future<List<Map<String,String>>> fetchTypeVehicules()async{

    List<Map<String,String>> mesTypes=[];

    final response = await http.get(
        Uri.parse(_adresse+'api/typeVehicule'),
        headers: _headers
    );

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






}