import 'package:flutter/material.dart';

import '../../compenent/ButtonClient.dart';
import '../../compenent/Commande.dart';
import '../../compenent/MenuNavgation.dart';
import '../../compenent/ShowCodeConfirmationDialog.dart';
import '../../controller/LivraisonController.dart';
import '../../controller/LivreurController.dart';
import '../../controller/authController.dart';
import '../../services/traking_sevice.dart';
import '../../utils/elpers/elperDate.dart';
import '../authentification/ProfilePage.dart';

class PageLivreur extends StatefulWidget {
  const PageLivreur({super.key});

  @override
  _PageLivreurState createState() => _PageLivreurState();
}

class _PageLivreurState extends State<PageLivreur> {
  final LivraisonController _livraisonController = LivraisonController();
  final TextEditingController codeController = TextEditingController();
  final int _currentIndex = 0;
  late Future<List<Map<String, String>>> livraisonsFuture;

  Future<void> _initLivraisons() async {
    await _livraisonController.init();
    final roleUser = await AuthController().getRole();
    livraisonsFuture = _livraisonController.getForLivreur(roleUser!.id);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initLivraisons();
  }

  @override
  void dispose() {
    TrackingService.stopTracking();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text(
          'Accueil',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        iconTheme: const IconThemeData(color: Colors.orange),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.orange),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/map_image.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: livraisonsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Problème de connexion...'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucune livraison pour vous maintenant'));
                  }

                  final livraisons = snapshot.data!;

                  return ListView.builder(
                    itemCount: livraisons.length,
                    itemBuilder: (context, index) {
                      final livraison = livraisons[index];
                      final status = livraison["status"];
                      if (status != "validee" && status != "en_cours" && status != "terminee") {
                        return const SizedBox.shrink();
                      }
                      return Commande(
                        status: " $status ",
                        titre: "Commande #${livraison["code"]} ",
                        itineraire: "De : Combe > Lingwala",
                        date: formaterDate(livraison["date"]!),
                        actions: [
                          ButtonClient(
                            libelle: "",
                            action: () {},
                          ).run(),
                          if (status == "en_cours")
                            ButtonClient(
                              libelle: "Fin course",
                              action: () {
                                ShowCodeConfirmationDialog(
                                  context: context,
                                  controller: codeController,
                                  idLivraison: livraison["id"]!,
                                  liv: _livraisonController,
                                ).run();
                              },
                            ).run(),
                        ],
                        actionVoirPlus: () {
                          Livreurcontroller().getDetailleLivraison(
                            context,
                            livraison["id_livreur"]!,
                            livraison["id"]!,
                          );
                        },
                      ).run();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MenuNavigation(
        action: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  ProfilePage()),
            );
          } else if (index == 1) {
            // Historique : à implémenter si nécessaire
          } else if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PageLivreur()),
            );
          }
        },
        currentIndex: _currentIndex,
      ).run(),
    );
  }
}
