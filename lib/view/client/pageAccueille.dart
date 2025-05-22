import 'package:flutter/material.dart';
import 'package:menji/view/authentification/pageAuthentification.dart';
import 'commander.dart';
import 'package:menji/compenent/blockMoyenTransport.dart';
import 'package:menji/compenent/ListeBlockTransport.dart';



class MyApp extends StatelessWidget {

  List<Map<String,String>> listes;
  List<Map<String,String>> listesLivraison;
  MyApp(this.listes,this.listesLivraison);

  @override
  Widget build(BuildContext context) {
    print(this.listes);
    return MaterialApp(
      title: 'Service de Livraison',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: PageAccueil(this.listes,this.listesLivraison),
    );
  }
}

class PageAccueil extends StatefulWidget {
  late List<Map<String,String>> listes;
  List<Map<String,String>> listesLivraison;
  PageAccueil(this.listes,this.listesLivraison);

  @override
  PageAccueilstate createState() => PageAccueilstate(this.listes,this.listesLivraison);
}


class PageAccueilstate extends State<PageAccueil> {

  late List<Map<String,String>> listes;
  List<Map<String,String>> listesLivraison;

  PageAccueilstate(this.listes,this.listesLivraison);

  @override
  void initState() {
    super.initState();
    // Initialise les données ici
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(''),
        iconTheme: IconThemeData(color: Colors.orange), // Couleur de l'icône
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.orange),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Section "Mode de transport"
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Mode de transport',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20),
                Icon(Icons.directions_car, size: 24, color: Colors.orange),
              ],
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:Listeblocktransport(context: context, typeVehicules: this.listes).Run(),
              ),
            ),
            SizedBox(height: 20), // Espace entre les sections

            // Section "Mes livraisons"
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Mes livraisons',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20),
                Icon(Icons.local_shipping, size: 24, color: Colors.orange),
              ],
            ),
            Column(
              children:  listesLivraison.map((livraison) {
                return _buildDeliveryCard('Bob', livraison["moyen_transport"]!, livraison["status"]!, livraison["date"]!);
              }).toList(),
            ),



            // Barre de navigation en bas
            SizedBox(height: 5), // Espace pour éviter le débordement
            BottomNavigationBar(
              backgroundColor: Colors.grey[200],
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Historique',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
              currentIndex: 0, // Index de l'onglet actuel
              onTap: (index) {
                // Gérer la navigation ici
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDeliveryCard(String name, String transportMode, String status, String time) {
    Color statusColor;

    // Définir la couleur en fonction du statut
    if (status == 'En cours...') {
      statusColor = Colors.blue; // Couleur bleue pour "En cours"
    } else {
      statusColor = Colors.orange; // Couleur par défaut pour "En attente"
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Ligne avec les titres
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nom', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('transport', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),

              ],
            ),
            Divider(), // Ligne de séparation
            // Ligne avec les données
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name),
                Text(transportMode),
                Text(time),

              ],
            ),
            Divider(), // Ligne de séparation
            // Statut avec conteneur coloré
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: statusColor, // Utiliser la couleur définie ci-dessus
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text("statut : "+status, style: TextStyle(color: Colors.white)),
                ),

                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.red, // Utiliser la couleur définie ci-dessus
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text("Annulee", style: TextStyle(color: Colors.white)),
                )

              ],
            )
            ,
          ],
        ),
      ),
    );
  }
}