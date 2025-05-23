
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/services/ApiLivraison.dart';
import 'package:menji/view/client/commander.dart';




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
