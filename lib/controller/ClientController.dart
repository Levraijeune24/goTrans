
import 'package:flutter/material.dart';
import 'package:menji/view/client/pageAccueille.dart';
import '../serviceAu/local_storage_service.dart';
import '../services/ApiServiceLivraison.dart';


class ClientController {

  late ApiServiceLivraison v ;

  Future<void> init () async {
    v = ApiServiceLivraison();
    await v.init();
  }

  void InitClient(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PageAccueil()),
    );
  }

  Future<List<Map<String,String>>>  getClient() async {
    return v.getClient();
  }
}
