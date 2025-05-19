import 'package:flutter/material.dart';
import 'package:menji/view/authentification/chargementApp.dart';
import 'package:menji/view/authentification/creerCompte.dart';
import 'package:menji/view/authentification/pageAuthentification.dart';
import 'package:menji/view/authentification/recupererMotPass.dart';
import 'package:menji/view/client/commander.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/view/livreur/pageAccueilleLivreur.dart';
import 'package:menji/view/livreur/validationLivreur.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        //useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

