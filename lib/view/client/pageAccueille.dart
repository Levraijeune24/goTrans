import 'package:flutter/material.dart';
import 'package:menji/view/authentification/pageAuthentification.dart';
import 'commander.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service de Livraison',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: PageAccueil(),
    );
  }
}

class PageAccueil extends StatelessWidget {
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
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PageCommander()), // Naviguer vers PageCommander
                      );
                    },
                    child: _buildCard(
                      'images/moto.png',
                      'Vehicul Moto',
                      'Livraison en ville.',
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PageCommander()), // Naviguer vers PageCommander
                      );
                    },
                    child: _buildCard(
                      'images/Taxi.png',
                      'Vehicule Hiace',
                      'À partir de 2 Kg selon distance.',
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PageCommander()), // Naviguer vers PageCommander
                      );
                    },
                    child: _buildCard(
                      'images/guzzi.png',
                      'Gros Camion',
                      'Livraison rapide en ville.',
                    ),
                  ),
                ],
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
            SizedBox(height: 5),
            _buildDeliveryCard('Bob', 'Bus', 'En cours...', 'Heure:'),
            SizedBox(height: 10),
            _buildDeliveryCard('Mike', 'Bus', 'En attente...', '12/12/2025'),

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

  Widget _buildCard(String imagePath, String title, String subtitle) {
    return Container(
      width: 250,
      height: 300,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 160,
              height: 160,
              fit: BoxFit.contain,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            Icon(Icons.arrow_forward, color: Colors.orange, size: 24),
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
                Text('Mode de transport', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Heure', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: statusColor, // Utiliser la couleur définie ci-dessus
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(status, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}