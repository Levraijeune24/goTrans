import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Validation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ValidationScreen(),
    );
  }
}

class ValidationScreen extends StatelessWidget {
  const ValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Validation',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre "Informations clients" centré avec le trait en dessous
            const SizedBox(height: 5),
            Center(
              child: Column(
                children: [
                  const Text(
                    'Informations clients',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    height: 2,
                    width: 150,
                    color: Colors.orange,
                    margin: const EdgeInsets.only(top: 8),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Section Expediteur
            const Text(
              'Expediteur',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 40,
              width: 400,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(245, 247, 250, 1.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                  'Marien Manima',
                style: TextStyle(
                //color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 40,
              width: 400,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color.fromRGBO(245, 247, 250, 1.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Av. MWELI 98 C/ MATETE ',
                style: TextStyle(
                  //color: Colors.orange,
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 40,
              width: 400,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(245, 247, 250, 1.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '+243 999 641 523',
                style: TextStyle(
                  //color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Section Destinateur
            const Text(
              'Destinateur',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 40,
              width: 400,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(245, 247, 250, 1.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                  'Bob kayemba',
                style: TextStyle(
                  //color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 40,
              width: 400,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(245, 247, 250, 1.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                  'Av: Bukenga, n°12 Q/ Lemba',
                style: TextStyle(
                  //color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 40,
              width: 400,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(245, 247, 250, 1.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                  '+243 856 841 787',
                  style: TextStyle(
                  //color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Section Tarification
            const Text(
              'Tarification',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),

            // Ligne Poids
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Poids',
                  style: TextStyle(
                      fontSize: 18
                  ),
                ),
                Container(
                  height: 40,
                  width: 130,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text(
                      '70KG',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Ligne Prix total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Prix Total',
                  style: TextStyle(
                      fontSize: 18
                  ),
                ),
                Container(
                  height: 40,
                  width: 130,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text(
                    '12.000 Fc',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Bouton Confirmer
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Action de confirmation
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Confirmer',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}