import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Validation',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: PageValidation(),
    );
  }
}

class PageValidation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Validation',
          style: TextStyle(color: Colors.orange),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations clients',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildInfoRow('Expéditeur', 'Marien Manima', Icons.person),
            _buildInfoRow('Destinataire', 'Bob kayemba', Icons.person),
            _buildInfoRow('Adresse', 'Av: Bukenga, n°12 Q/ Lemba', Icons.location_on),
            _buildInfoRow('Téléphone', '+243 856 841 787', Icons.phone),
            SizedBox(height: 20),
            Text(
              'Tarification',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildPricingRow('Prix unitaire', '3000 Fc/Kg'),
            _buildPricingRow('Poids', '70 KG'),
            _buildPricingRow('Prix total', '12.000 Fc'),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Action pour confirmer
                },
                child: Text('Confirmer'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Couleur verte
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.all(10.0),
              width: 200, // Largeur fixe pour les conteneurs
              color: Colors.white,
              child: Text(value),
            ),
          ],
        ),
        Icon(icon),
      ],
    );
  }

  Widget _buildPricingRow(String label, String value) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.only(top: 5.0, bottom: 10.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}