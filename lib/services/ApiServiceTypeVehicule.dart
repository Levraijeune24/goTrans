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

    token = await LocalStorageService().getToken();

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
          "kilo_tarif":typeVehile["tarif"]["valeur"].toString(),
          "prix_tarif":typeVehile["tarif"]["prix"].toString(),
          "description":typeVehile["description"].toString(),
        },
        );
      });

    } else {
      print('Erreur : ${response.statusCode}');
    }
    return mesTypes;

  }






}