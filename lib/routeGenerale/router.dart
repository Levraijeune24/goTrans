import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:menji/view/authentification/ProfilePage.dart';
import 'package:menji/view/authentification/pageAuthentification.dart';
import 'package:menji/view/client/pageAccueille.dart';

import '../serviceAu/local_storage_service.dart';
import '../view/authentification/creerCompte.dart';
import '../view/livreur/pageAccueilleLivreur.dart';



final GoRouter router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final loggedIn = await LocalStorageService.isLoggedIn();
    final goingToLogin = state.uri.toString() == '/login';

    if (!loggedIn && !goingToLogin) return '/login';
    if (loggedIn && goingToLogin) return '/home';

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) =>  CreationCompte(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) =>  PageAccueil(),
    ),
    GoRoute(
      path: '/homeLivreur',
      builder: (context, state) =>  PageLivreur(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) =>  ProfilePage(),
    ),
  ],
);
