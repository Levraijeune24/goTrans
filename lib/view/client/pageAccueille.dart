import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:menji/view/client/pageHistorique.dart';
import '../../compenent/ButtonClient.dart';
import '../../compenent/Commande.dart';
import '../../compenent/EnteteInfo.dart';
import '../../compenent/MenuNavgation.dart';
import '../../compenent/Navigation.dart';
import '../../compenent/ShowCodeConfirmationDialog.dart';
import '../../compenent/TextBienvenue.dart';
import '../../compenent/showDetaille.dart';
import '../../controller/LivraisonController.dart';
import '../../controller/TypeVehiculeController.dart';
import '../../controller/authController.dart';
import 'package:menji/compenent/ListeBlockTransport.dart';
import 'package:menji/compenent/LivraisonCards.dart';

import '../../utils/elpers/elperDate.dart';
import '../authentification/ProfilePage.dart';

class PageAccueil extends StatefulWidget {
  @override
  State<PageAccueil> createState() => PageAccueilState();
}

class PageAccueilState extends State<PageAccueil> {
  final Typevehiculecontroller _typevehiculecontroller = Typevehiculecontroller();
  final LivraisonController _livraisonController = LivraisonController();
  final TextEditingController codeController = TextEditingController();

  int _currentIndex = 0;
  bool isSelected = true;

  dynamic roleUser;
  dynamic nameUser;

  List<Map<String, String>> TypesVehicules = [];
  List<Map<String, String>> listesLivraisonExpeditaire = [];
  List<Map<String, String>> listesLivraisonDestinateur = [];

  late Future<void> pageInitFuture;

  @override
  void initState() {
    super.initState();
    pageInitFuture = _initAll();
  }

  Future<void> _initAll() async {
    await Future.wait([
      _typevehiculecontroller.init(),
      _livraisonController.init(),
    ]);

    TypesVehicules = await _typevehiculecontroller.fetchTypeVehicule();
    roleUser = await AuthController().getRole();
    nameUser = (await AuthController().getUser())!.name;

    listesLivraisonExpeditaire = await _livraisonController.getForExpeditaire(roleUser!.id);
    listesLivraisonDestinateur = await _livraisonController.getForDestinataire(roleUser!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text('Accueil', style: TextStyle(color: Colors.white, fontSize: 30)),
        iconTheme: const IconThemeData(color: Colors.orange),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.orange),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: pageInitFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors du chargement'));
          }
          return _buildMainContent();
        },
      ),
      bottomNavigationBar: MenuNavigation(
        action: (index) {
          if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageHistorique()));
          } else if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageAccueil()));
          }
        },
        currentIndex: _currentIndex,
      ).run(),
    );
  }

  Widget _buildMainContent() {
    final List<Map<String, String>> currentList = isSelected ? listesLivraisonDestinateur : listesLivraisonExpeditaire;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          TextBienvenue(name: nameUser).run(),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              enteteInfo("Categories"),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.orange,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: Listeblocktransport(
                context: context,
                typeVehicules: TypesVehicules,
              ).Run(),
            ),
          ),
          const SizedBox(height: 30),
          enteteInfo("Mes livraisons"),
          const SizedBox(height: 15),
          Row(
            children: [
              ButtonClient(
                isSelected: isSelected,
                libelle: "Entrant",
                height: 40,
                action: () => setState(() => isSelected = true),
              ).run(),
              const SizedBox(width: 20),
              ButtonClient(
                isSelected: !isSelected,
                libelle: "Sortant",
                height: 40,
                action: () => setState(() => isSelected = false),
              ).run(),
            ],
          ),
          const SizedBox(height: 15),
          Column(
            children: currentList
                .where((liv) => liv["status"] != "annulee" && liv["status"] != "terminee")
                .map((livraison) => Commande(
              status: " ${livraison["status"]} ",
              titre: "Commande #${livraison["code"]} ",
              itineraire: "De : Combe > Lingwala",
              date: formaterDate(livraison["date"]!),
              actions: [
                ButtonClient(
                  libelle: "Suivre",
                  action: () => _livraisonController.Suivre(
                    context,
                    livraison["id"]!,
                    livraison["nom_livreur"].toString(),
                    livraison["numero_livreur"].toString(),
                    livraison["nom_type_livreur"].toString(),
                    livraison["immatriculation_livreur"].toString(),
                  ),
                ).run(),
                livraison["status"] == "en_cours"
                    ? ButtonClient(
                  libelle: "Fin course",
                  action: () {
                    if (livraison["expediteur_id"].toString() == roleUser.id.toString()) {
                      ShowCodeConfirmationDialog(
                        context: context,
                        controller: codeController,
                        idLivraison: livraison["expediteur_id"].toString(),
                        liv: _livraisonController,
                      ).run();
                    }
                  },
                ).run()
                    : const SizedBox(),
              ],
              actionVoirPlus: () => ShowDetaille(context: context, livr: livraison).run(),
            ).run())
                .toList(),
          ),
        ],
      ),
    );
  }
}
