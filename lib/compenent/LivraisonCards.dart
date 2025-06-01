
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

  LivraisonsCard({
    required this.expediteur,required this.destinateur,
    required this.moyen_transport,
    required this.status,required this.date,required this.id,required this.liv,
    required this.Annuler,
    required this.Confirmer,
    required this.showInformation
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
                  child: Text("Statut : $status",
                      style: TextStyle(color: Colors.white)),
                ),

                (status=="en_attente")?
                InkWell(
                  onTap: () {
                    Annuler(id);

                  },
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text("Annuler", style: TextStyle(color: Colors.white)),
                  ),
                ):Center(),
                (status=="en_cours")?
                InkWell(
                  onTap: (){
                    Confirmer(id);
                    print("confirmer");
                    //_showCodeConfirmationDialog(context,codeController,id,_livraisonController);
                  },
                  child:Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text("Confirmer", style: TextStyle(color: Colors.white)),
                  ) ,
                ):Center()
                ,
                InkWell(
                  onTap: (){


                    showInformation(liv);
                    //_showCodeDetaille(context,liv);

                  },
                  child:Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text("Infos", style: TextStyle(color: Colors.white)),
                  ) ,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }


}








