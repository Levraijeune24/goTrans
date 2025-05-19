import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Page de Livraison',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: PageLivreur(),
    );
  }
}

class PageLivreur extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.orange),
            onPressed: () {
              // Action pour les notifications
            },
          ),
          SizedBox(width: 20), // Espacement pour l'icône de notification
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 200, // Ajustez la hauteur selon vos besoins
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/map_image.png'), // Remplacez par votre image
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 1.0,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Arrivée estimée 10 min',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Divider(thickness: 1, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('Expéditeur', style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildInfoRow('Marien Manima', Icons.person),
                          _buildInfoRow('Av: Yolo, nord-sud', Icons.location_on),
                          Text('Destinataire', style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildInfoRow('Bob Kayemba', Icons.person),
                          _buildInfoRow('Av: Bukanga, n°12, A/Lemba', Icons.location_on),
                          _buildInfoRow('0815396419', Icons.phone),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Poids estimé', style: TextStyle(fontWeight: FontWeight.bold)),
                              Container(
                                padding: EdgeInsets.all(10.0),
                                margin: EdgeInsets.only(top: 5.0),
                                color: Colors.grey[200],
                                child: Text('0 à 20kg'),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                // Action pour accepter la livraison
                              },
                              child: Text('Accepter'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orange,
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.only(top: 5.0, bottom: 10.0),
            color: Colors.grey[200],
            child: Text(text),
          ),
        ),
        Icon(icon),
      ],
    );
  }
}