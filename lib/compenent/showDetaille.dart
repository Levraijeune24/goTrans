import 'package:flutter/material.dart';
import 'package:flutter/services.dart';





class ShowDetaille{


  Map<String, String> livr;
  BuildContext context;

  ShowDetaille({required this.livr, required this.context});

  run(){
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.local_shipping, color: Colors.blue),
            SizedBox(width: 10),
            Text(
              "Détails ",
              style: TextStyle(fontWeight: FontWeight.bold),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildStyledRow(icon:  Icons.person, label: "Expéditeur :", value:  livr["expediteur"] ?? "Inconnu").run(),
              SizedBox(height: 10),
              buildStyledRow(icon: Icons.person_outline,label: "Destinataire :",value: livr["destinateur"] ?? "Inconnu").run(),
              SizedBox(height: 10),
              buildStyledRow(icon: Icons.location_on,label: "Adresse d'expedition :",value: livr["adresse_expedition"] ?? "N/A").run(),
              SizedBox(height: 10),
              buildStyledRow(icon: Icons.location_on,label: "Adresse de destination :",value: livr["adresse_destination"] ?? "N/A").run(),
              SizedBox(height: 10),
              buildStyledRow(icon:Icons.qr_code,label: "Code Livraison :",value: livr["code"] ?? "Non disponible").run(),
              SizedBox(height: 10),
              buildStyledRow(icon:Icons.date_range,label: "Date :",value: livr["date"] ?? "Non précisée").run(),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.copy, color: Colors.blue),
            label: Text("Copier le code"),
            onPressed: () {
              final code = livr["code"] ?? "";
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Code copié dans le presse-papiers")),
              );
            },
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.close),
            label: Text("Fermer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );

  }

}

class buildStyledRow{

  IconData icon;
  String label;
  String value;


  buildStyledRow({required this.icon,required this.label,required this.value});

  run(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(text: "$label ", style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }




}

