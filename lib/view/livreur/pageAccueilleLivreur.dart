import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../compenent/ButtonClient.dart';
import '../../compenent/Commande.dart';
import '../../compenent/EnteteInfo.dart';
import '../../compenent/MenuNavgation.dart';
import '../../compenent/ShowCodeConfirmationDialog.dart';
import '../../compenent/TextBienvenue.dart';
import '../../controller/LivraisonController.dart';
import '../../controller/LivreurController.dart';
import '../../controller/authController.dart';
import '../../services/traking_sevice.dart';
import '../../utils/elpers/elperDate.dart';
import '../authentification/ProfilePage.dart';

class PageLivreur extends StatefulWidget {
  const PageLivreur({Key? key}) : super(key: key);


  @override
  _PageLivreurState createState() => _PageLivreurState();
}
class _PageLivreurState extends State<PageLivreur> {
  final LivraisonController _livraisonController = LivraisonController();
  final TextEditingController codeController = TextEditingController();

  final int _currentIndex = 0;

  dynamic roleUser;
  String nomLivreur = "";

  late Future<List<Map<String, String>>> livraisonsFuture;

  Future<List<Map<String, String>>> _initLivraisons() async {
    await _livraisonController.init();
    roleUser = await AuthController().getRole();

    final livraisons = await _livraisonController.getForLivreur(roleUser!.id);

    if (livraisons.isNotEmpty) {
      nomLivreur = livraisons[0]["nom_livreur"] ?? "";
    }

    return livraisons;
  }

  @override
  void initState() {
    super.initState();
    livraisonsFuture = _initLivraisons(); // assigné une seule fois ici
  }

  @override
  void dispose() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            TextBienvenue(name: nomLivreur).run(),
            const SizedBox(height: 30),
            enteteInfo("Mes livraisons", color: Colors.black, size: 28),
            const SizedBox(height: 15),
            ButtonClient(
              paddingHorizontale: 0,
              width: 9,
              isSelected: true,
              libelle: "Missions",
              height: 40,
              action: () {
                setState(() {
                  livraisonsFuture = _initLivraisons(); // recharge
                });
              },
            ).run(),
            const SizedBox(height: 30),
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
                        itineraire: "De : ${livraison["adresse_expedition"]} > ${livraison["adresse_destination"]}",
                        date: formaterDate(livraison["date"]!),
                        actions: [
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
            context.push("/profil");
          } else if (index == 1) {
            // Historique livreur : à implémenter plus tard
          } else if (index == 0) {

            context.go('/homeLivreur?reload=${DateTime.now().millisecondsSinceEpoch}');
          }
        },
        currentIndex: _currentIndex,
      ).run(),
    );
  }
}
