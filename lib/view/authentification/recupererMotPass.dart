import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Réinitialisation du Mot de Passe',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MotDePasseOublie(),
    );
  }
}

class MotDePasseOublie extends StatelessWidget {
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
        title: Text(''),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Veuillez entrer le code que vous avez reçu',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _codeInputField(),
                  SizedBox(width: 10),
                  _codeInputField(),
                  SizedBox(width: 10),
                  _codeInputField(),
                  SizedBox(width: 10),
                  _codeInputField(),
                ],
              ),
              SizedBox(height: 40),
              TextButton(
                onPressed: () {
                  // Action pour renvoyer le code
                },
                child: Text(
                  'Renvoier le code',
                  style: TextStyle(fontSize: 16, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _codeInputField() {
    return Container(
      width: 60,
      height: 60,
      child: TextFormField(
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, color: Colors.orange), // Couleur des chiffres
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.orange, width: 2.0), // Contour orange
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.orange, width: 2.0), // Contour orange quand activé
          ),
          filled: true,
          fillColor: Colors.white, // Couleur de fond blanche
        ),
        keyboardType: TextInputType.number,
        maxLength: 1, // Limiter à un seul chiffre
        // Ne pas afficher le compteur de caractères
        buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
      ),
    );
  }
}