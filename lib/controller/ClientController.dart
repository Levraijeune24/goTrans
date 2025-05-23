
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/services/ApiLivraison.dart';
import 'package:menji/view/client/commander.dart';




class ClientController {

  BuildContext context;

  ClientController(this.context);


  void InitClent() async{

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  }



