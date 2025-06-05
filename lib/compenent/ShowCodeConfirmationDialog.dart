
import 'package:flutter/material.dart';
import '../controller/LivraisonController.dart';


class ShowCodeConfirmationDialog {


  BuildContext context;
  TextEditingController controller;
  String idLivraison;
  LivraisonController liv;

  ShowCodeConfirmationDialog({required this.context,required this.controller,
    required this.idLivraison,required this.liv});


  run(){
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmation"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Entrez le code de validation :"),
            SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Code de validation",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text("Valider"),
            onPressed: () async {
              String code = controller.text;
              liv.confirmerLivraison(context,idLivraison, controller.text);
            },
          ),
        ],
      ),
    );




  }





}