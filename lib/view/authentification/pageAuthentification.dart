import 'package:flutter/material.dart';
import 'package:menji/view/authentification/recupererMotPass.dart';
import 'package:menji/controller/LivraisonController.dart';
import 'package:menji/compenent/blockMoyenTransport.dart';

import 'creerCompte.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connexion',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/logo2.png',
                height: 100,
              ),
              SizedBox(height: 20),
              Text(
                'Connexion',
                style: TextStyle(
                  fontFamily: 'Segoe UI',
                  fontSize: 37,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'E-mail ou téléphone',
                  hintStyle: TextStyle(color: Colors.grey), // Couleur grise pour le texte d'indication
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.orange, width: 0.7),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Mot de passe',
                  hintStyle: TextStyle(color: Colors.grey), // Couleur grise pour le texte d'indication
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.orange, width: 0.7),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              // Ligne avec "Créer un compte" et "Mot de passe oublié ?"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      // Action pour créer un compte
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreationCompte()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Créer ',
                            style: TextStyle(color: Colors.orange),
                          ),
                          TextSpan(
                            text: 'un compte',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Action pour mot de passe oublié
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MotDePasseOublie()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Mot de passe ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextSpan(
                            text: 'oublié ?',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {

                  LivraisonController(context).createLivraison();
                },
                child: Text(
                  'Connexion',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ), backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 115, vertical: 15),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 0.7,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Sign with",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 90,
                    height: 0.7,
                    color: Colors.orange,
                  ),
                ],
              ),
              SizedBox(height: 10),
              _roundedImageContainer('images/google.png'), // Appel à la fonction
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundedImageContainer(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Couleur de fond
        borderRadius: BorderRadius.circular(25.0), // Coins arrondis
        border: Border.all(color: Colors.orange, width: 0.7), // Bordure
      ),
      padding: EdgeInsets.all(10), // Espace autour de l'image
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0), // Coins arrondis pour l'image
        child: Image.asset(
          imagePath,
          width: 280,
          height: 30, // Ajustez la taille de l'image
          fit: BoxFit.contain, // Ajuster l'image pour qu'elle soit complètement visible
        ),
      ),
    );
  }
}
