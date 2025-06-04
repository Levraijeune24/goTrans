
import 'package:flutter/material.dart';



class LivraisonsCard {
  String expediteur;
  String destinateur;
  String moyen_transport;
  String status;
  String date;
  String id;
  Map<String, String> liv;
  Function Annuler;
  Function Confirmer;
  Function showInformation;

  int typeCl=0;

  String typeLivraison;

  LivraisonsCard({
    required this.expediteur,required this.destinateur,
    required this.moyen_transport,
    required this.status,required this.date,required this.id,required this.liv,
    required this.Annuler,
    required this.Confirmer,
    required this.showInformation,
    this.typeLivraison="",
    this.typeCl=0
  });

  Widget run(){

    status == 'en_cours' ? status == 'terminee' ? Colors.green : Colors.orange : Colors.orange;

    var statusColor = status == 'terminee' ? Colors.blue :
    status == 'en_cours' ? Colors.red: status == 'validee' ?
    Colors.green:status == 'en_attente' ? Colors.orange: Colors.orange;

     return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Flèche en haut
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                typeCl==0?
                Icon(
                  typeLivraison == "entrant" ? Icons.arrow_downward : Icons.arrow_upward,
                  color: typeLivraison == "entrant" ? Colors.green : Colors.red,
                  size: 24,
                ):Center(),

                SizedBox(width: 8),
                typeCl==0?
                Text(
                  typeLivraison == "entrant" ? "Livraison Entrante" : "Livraison Sortante",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: typeLivraison == "entrant" ? Colors.green : Colors.red,
                  ),
                ):Center(),
              ],
            ),

            SizedBox(height: 10),

            // Titres
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expediteur', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Destinateur', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Moyen de transport', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(),

            // Données
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(expediteur),
                Text(destinateur),
                Text(moyen_transport),
                Text(date),
              ],
            ),
            Divider(),

            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text("Statut : $status", style: TextStyle(color: Colors.white)),
                ),

                if (status == "en_attente")
                  InkWell(
                    onTap: () => Annuler(id),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text("Annuler", style: TextStyle(color: Colors.white)),
                    ),
                  ),

                if (status == "en_cours")
                  InkWell(
                    onTap: () {
                      Confirmer(id);
                      print("confirmer");
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text("Confirmer", style: TextStyle(color: Colors.white)),
                    ),
                  ),

                InkWell(
                  onTap: () => showInformation(liv),
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text("Infos", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );


  }


}








