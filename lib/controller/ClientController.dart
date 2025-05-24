
import 'package:flutter/material.dart';
import 'package:menji/view/client/pageAccueille.dart';
import '../services/ApiLivraison.dart';


class ClientController {

  void InitClient(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  Future<List<Map<String,String>>>  getClient() async {
    return Apilivraison().getClient();
  }
}
