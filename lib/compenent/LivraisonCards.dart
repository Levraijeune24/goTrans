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
  late VoidCallback? suivre;

  int typeCl = 0;

  String typeLivraison;

  LivraisonsCard({
    required this.expediteur,
    required this.destinateur,
    required this.moyen_transport,
    required this.status,
    required this.date,
    required this.id,
    required this.liv,
    required this.Annuler,
    required this.Confirmer,
    required this.showInformation,
    this.typeLivraison = "",
    this.typeCl = 0,
    this.suivre,
  });

  Widget run() {
    var statusColor = status == 'terminee'
        ? Colors.blue
        : status == 'en_cours'
        ? Colors.red
        : status == 'validee'
        ? Colors.green
        : status == 'en_attente'
        ? Colors.orange
        : Colors.orange;

    return LayoutBuilder(builder: (context, constraints) {
      // Taille dispo max pour adapter le texte
      double maxWidth = constraints.maxWidth;

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
                  if (typeCl == 0)
                    Icon(
                      typeLivraison == "entrant" ? Icons.arrow_downward : Icons.arrow_upward,
                      color: typeLivraison == "entrant" ? Colors.green : Colors.red,
                      size: 24,
                    )
                  else
                    SizedBox.shrink(),
                  SizedBox(width: 8),
                  if (typeCl == 0)
                    Flexible(
                      child: Text(
                        typeLivraison == "entrant" ? "Livraison Entrante" : "Livraison Sortante",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: typeLivraison == "entrant" ? Colors.green : Colors.red,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    SizedBox.shrink(),
                ],
              ),

              SizedBox(height: 10),

              // Titres - adaptatifs avec Flexible
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      flex: 2,
                      child: Text('Expéditeur', style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                  Flexible(
                      flex: 2,
                      child: Text('Destinataire', style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                  Flexible(
                      flex: 2,
                      child:
                      Text('Moyen de transport', style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                  Flexible(
                      flex: 1,
                      child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                ],
              ),
              Divider(),

              // Données - adaptatives avec Flexible et ellipsis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(flex: 2, child: Text(expediteur, overflow: TextOverflow.ellipsis)),
                  Flexible(flex: 2, child: Text(destinateur, overflow: TextOverflow.ellipsis)),
                  Flexible(flex: 2, child: Text(moyen_transport, overflow: TextOverflow.ellipsis)),
                  Flexible(flex: 1, child: Text(date, overflow: TextOverflow.ellipsis)),
                ],
              ),
              Divider(),

              // Boutons d'action - avec Expanded et Wrap pour éviter débordement
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
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
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
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
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
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
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text("Infos", style: TextStyle(color: Colors.white)),
                    ),
                  ),

                  if (status == "en_cours" && typeCl == 0 && suivre != null)
                    InkWell(
                      onTap: () => suivre!(),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text("Suivre", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
