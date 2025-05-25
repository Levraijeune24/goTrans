
import 'package:flutter/material.dart';
import 'package:menji/view/client/pageAccueille.dart';
import '../serviceAu/local_storage_service.dart';
import '../services/ApiLivraison.dart';


class ClientController {

  Apilivraison v= Apilivraison();

  setToken() async{
    String? token= await LocalStorageService().getToken();
    v.setToken(token!);
  }

  void InitClient(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  Future<List<Map<String,String>>>  getClient() async {
    return v.getClient();
  }
}
