import 'package:flutter/material.dart';
import 'package:menji/view/authentification/pageAuthentification.dart';
import '../../controller/ClientController.dart';
import '../../controller/LivraisonController.dart';
import '../../controller/TypeVehiculeController.dart';
import '../../services/ApiLivraison.dart';
import 'commander.dart';
import 'package:menji/compenent/blockMoyenTransport.dart';
import 'package:menji/compenent/ListeBlockTransport.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageAccueil();
  }
}

class PageAccueil extends StatefulWidget {
  @override
  State<PageAccueil> createState() => PageAccueilState();
}

class PageAccueilState extends State<PageAccueil> {
  List<Map<String, String>> listes1 = [];
  List<Map<String, String>> listesLivraison1 = [];
  bool isLoadingTypeVehicule = true;
  bool isLoadingLivraison = true;

  void _initialisationTypeVehicule() async {

    listes1 = await Typevehiculecontroller().AllTypeVehicule();
    setState(() {
      isLoadingTypeVehicule = false;
    });
  }

  void _initialisationLivraison() async {
    listesLivraison1 = await LivraisonController().AllLivraison(2);
    setState(() {
      isLoadingLivraison = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initialisationTypeVehicule();
    _initialisationLivraison();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(''),
        iconTheme: IconThemeData(color: Colors.orange),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section "Mode de transport"
            Row(
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
            isLoadingTypeVehicule
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: Listeblocktransport(
                  context: context,
                  typeVehicules: listes1,
                ).Run(),
              ),
            ),
            SizedBox(height: 20),

            // Section "Mes livraisons"
            Row(
              children: [
                Text(
                  'Mes livraisons',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20),
                Icon(Icons.local_shipping, size: 24, color: Colors.orange),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.orange, size: 24),
                  onPressed: _initialisationLivraison,
                ),
              ],
            ),
            SizedBox(height: 10),
            isLoadingLivraison
                ? Center(child: CircularProgressIndicator())
                : Container(
              height: 300,
              child: ListView(
                children: listesLivraison1.map((livraison) {
                  return _buildDeliveryCard(
                    'Bob',
                    livraison["moyen_transport"]!,
                    livraison["status"]!,
                    livraison["date"]!,
                      livraison["id"]!

                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        currentIndex: 0,
        onTap: (index) {
          // Gérer la navigation ici
        },
      ),
    );
  }

  Widget _buildDeliveryCard(
      String name, String transportMode, String status, String time,String id) {
    Color statusColor =
    status == 'en_cours' ? Colors.blue : Colors.orange;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Titres
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nom', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Transport', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(),
            // Données
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name),
                Text(transportMode),
                Text(time),
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

                (status!="annulee")?
                InkWell(
                  onTap: () {
                    LivraisonController().annulerLivraison(id );
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
                
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text("Mod", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
