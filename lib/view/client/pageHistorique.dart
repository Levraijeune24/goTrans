import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/view/client/pageHistorique.dart';
import '../../compenent/AppBarCostum.dart';
import '../../compenent/ButtonClient.dart';
import '../../compenent/Commande.dart';
import '../../compenent/EnteteInfo.dart';
import '../../compenent/LivraisonCards.dart';
import '../../compenent/MenuNavgation.dart';
import '../../compenent/Navigation.dart';
import '../../compenent/ShowCodeConfirmationDialog.dart';
import '../../compenent/showDetaille.dart';
import '../../controller/LivraisonController.dart';
import '../../controller/TypeVehiculeController.dart';
import '../../controller/authController.dart';
import 'package:menji/compenent/ListeBlockTransport.dart';

import '../../utils/elpers/elperDate.dart';
import '../authentification/ProfilePage.dart';

class PageHistorique extends StatefulWidget {
  @override
  State<PageHistorique> createState() => PageHistoriqueState();
}

class PageHistoriqueState extends State<PageHistorique> {
  final LivraisonController _livraisonController = LivraisonController();
  final TextEditingController codeController = TextEditingController();

  late dynamic roleUser;
  int _currentIndex = 0;
  bool isSelected = true;

  List<Map<String, String>> listesLivraisonDestinateur = [];
  List<Map<String, String>> listesLivraisonExpeditaire = [];



  Future<List<List<Map<String, String>>>> _initialisationLivraison() async {
    roleUser = await AuthController().getRole();
    await _livraisonController.init();
    listesLivraisonExpeditaire = await _livraisonController.getForExpeditaire(roleUser!.id);
    listesLivraisonDestinateur = await _livraisonController.getForDestinataire(roleUser!.id);
    return [listesLivraisonExpeditaire, listesLivraisonDestinateur];
  }

  @override
  void initState() {
    super.initState();
     _initialisationLivraison(); // Appel unique
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBarCostum(context: context, libelle: "Mon historique").run(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            enteteInfo("Mes livraisons", color: Colors.black),
            const SizedBox(height: 15),
            Row(
              children: [
                ButtonClient(
                  isSelected: isSelected,
                  libelle: "Entrant",
                  height: 40,
                  action: () {
                    setState(() {
                      isSelected = true;
                    });
                  },
                ).run(),
                const SizedBox(width: 20),
                ButtonClient(
                  isSelected: !isSelected,
                  libelle: "Sortant",
                  height: 40,
                  action: () {
                    setState(() {
                      isSelected = false;
                    });
                  },
                ).run(),
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<List<Map<String, String>>>>(
              future:  _initialisationLivraison(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Problème de connexion'));
                } else if (!snapshot.hasData || (snapshot.data![0].isEmpty && snapshot.data![1].isEmpty)) {
                  return const Center(child: Text('Aucune livraison trouvée, pour l\'instant'));
                } else {
                  return Column(
                    children: snapshot.data!.map((livraisons) {
                      return Column(
                        children: livraisons
                            .where((livraison) {
                          String expediteurId = livraison["expediteur_id"].toString();
                          String userId = roleUser.id.toString();
                          return isSelected
                              ? expediteurId != userId
                              : expediteurId == userId;
                        })
                            .map((livraison) {
                          if (livraison["status"] == "terminee" || livraison["status"] == "annulee") {
                            return Commande(
                              status: " ${livraison["status"]} ",
                              titre: "Commande #${livraison["code"]} ",
                              itineraire:
                              "De : ${livraison["adresse_expedition"]} > ${livraison["adresse_destination"]}",
                              date: formaterDate(livraison["date"]!),
                              actions: [],
                              actionVoirPlus: () => ShowDetaille(context: context, livr: livraison).run(),
                            ).run();
                          } else {
                            return const SizedBox.shrink(); // ne rien afficher
                          }
                        })
                            .toList(),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: MenuNavigation(
        action: (index) {
          if (index == 2) {
            context.push('/profil');
          } else if (index == 1) {
            context.go('/PageHistorique');
          } else if (index == 0) {
            context.go('/home');
          }
        },
        currentIndex: _currentIndex,
      ).run(),
    );
  }
}
