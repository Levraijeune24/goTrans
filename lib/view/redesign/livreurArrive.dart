import 'package:flutter/material.dart';

void main() {
  runApp(const ArriveScreen());
}

class ArriveScreen extends StatelessWidget {
  const ArriveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: Stack(
            children: [
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.1, // Le bloc remonte vers le milieu
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ligne du nom avec icônes
                      Row(
                        children: [
                          // Icône profil à gauche
                          const Icon(Icons.account_circle, color: Colors.orange, size: 30),
                          const SizedBox(width: 10),
                          // Nom
                          const Expanded(
                            child: Text(
                              'Shekinah Kalala',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Icône message
                          IconButton(
                            icon: const Icon(Icons.message, color: Colors.orange, size: 24),
                            onPressed: () {},
                          ),
                          // Icône téléphone
                          IconButton(
                            icon: const Icon(Icons.phone, color: Colors.orange, size: 24),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Véhicule
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Moto - ABC 1234',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Moto - ABC 1234',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Téléphone
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          '089 xxx xxxx',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Bouton "Fin course" en bleu foncé
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(73, 73, 73, 1.0), // Bleu foncé
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Fin course',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}