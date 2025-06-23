import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:menji/view/authentification/ProfilePage.dart';
import 'package:menji/view/authentification/pageAuthentification.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/view/authentification/creerCompte.dart';
import 'package:menji/view/livreur/pageAccueilleLivreur.dart';
import '../serviceAu/local_storage_service.dart';
import '../view/redesign/pageAccueille.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final loggedIn = await LocalStorageService.isLoggedIn();
    final roleinfo = await LocalStorageService().getRoleInfo();
    final currentPath = state.uri.toString();

    // Si non connecté, rediriger tout sauf login/register vers login
    if (!loggedIn && currentPath != '/login' && currentPath != '/register') {
      return '/login';
    }

    // Si connecté, empêcher accès à login/register
    if (loggedIn && (currentPath == '/login' || currentPath == '/register')) {
      if (roleinfo?.role == "client") return '/home';
      if (roleinfo?.role == "livreur") return '/homeLivreur';
    }

    // Gestion d'accès en fonction du rôle
    if (loggedIn) {
      if (roleinfo?.role == "client" && currentPath.startsWith('/homeLivreur')) {
        return '/home'; // redirection interdite au livreur
      }

      if (roleinfo?.role == "livreur" && currentPath.startsWith('/home')) {
        return '/homeLivreur'; // redirection interdite au client
      }
    }
    return null; // Pas de redirection
  },

  routes: [
    // Authentification
    GoRoute(
      path: '/login',
      builder: (context, state) =>  LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => CreationCompte(),
    ),

    // Client uniquement
    GoRoute(
      path: '/home',
      builder: (context, state) => PageAccueil(),
    ),

    // Livreur uniquement
    GoRoute(
      path: '/homeLivreur',
      builder: (context, state) => PageLivreur(),
    ),

    // Routes accessibles par les deux
    GoRoute(
      path: '/profil',
      builder: (context, state) => ProfilePage(),
    ),

  ],
);
