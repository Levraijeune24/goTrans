
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../compenent/ButtonClient.dart';
import '../../compenent/Commande.dart';
import '../../compenent/EnteteInfo.dart';
import '../../compenent/MenuNavgation.dart';
import '../../compenent/ShowCodeConfirmationDialog.dart';
import '../../compenent/TextBienvenue.dart';
import '../../compenent/showDetaille.dart';
import '../../controller/LivraisonController.dart';
import '../../controller/TypeVehiculeController.dart';
import '../../controller/authController.dart';
import '../../utils/elpers/elperDate.dart';
import '../../compenent/ListeBlockTransport.dart';

class PageAccueil extends StatefulWidget {
  const PageAccueil({Key? key}) : super(key: key);

  @override
  State<PageAccueil> createState() => PageAccueilState();
}

class PageAccueilState extends State<PageAccueil> {
  final _typeVehiculeController = Typevehiculecontroller();
  final _livraisonController = LivraisonController();
  final _codeController = TextEditingController();

  int _currentIndex = 0;
  bool _isSelected = true;
  bool _hasNewEntrant = false;

  double fontSize = 28;

  dynamic _roleUser;
  dynamic _nameUser;

  List<Map<String, String>> _typesVehicules = [];
  List<Map<String, String>> _livraisonsExpediteur = [];
  List<Map<String, String>> _livraisonsDestinataire = [];

  int _ancienNombreLivDes = 0;

  late Future<void> _pageInitFuture;

  @override
  void initState() {
    super.initState();
    _pageInitFuture = _initAll();
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) _checkNewEntrantLivraisons();
    });
  }

  Future<void> _checkNewEntrantLivraisons() async {
    await _livraisonController.init();
    final nouvelles = await _livraisonController.getForDestinataire(_roleUser!.id);
    setState(() {
      _hasNewEntrant = nouvelles.length > _ancienNombreLivDes;
    });
  }

  Future<void> _initLivraisons() async {
    await _livraisonController.init();
    _livraisonsExpediteur = await _livraisonController.getForExpeditaire(_roleUser!.id);
    _livraisonsDestinataire = await _livraisonController.getForDestinataire(_roleUser!.id);
    _ancienNombreLivDes = _livraisonsDestinataire.length;
  }

  Future<void> _initAll() async {
    await Future.wait([
      _typeVehiculeController.init(),
      _livraisonController.init(),
    ]);
    _typesVehicules = await _typeVehiculeController.fetchTypeVehicule();
    _roleUser = await AuthController().getRole();
    _nameUser = (await AuthController().getUser())!.name;
    await _initLivraisons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: Text('Accueil', style: TextStyle(color: Colors.white, fontSize: fontSize)),
        iconTheme: const IconThemeData(color: Colors.orange),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.orange),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _pageInitFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Problème de connexion.'));
          }
          return _buildMainContent();
        },
      ),
      bottomNavigationBar: MenuNavigation(
        action: (index) {
          switch (index) {
            case 0:
              context.go('/home?reload=${DateTime.now().millisecondsSinceEpoch}');
              break;
            case 1:
              context.push('/PageHistorique');
              break;
            case 2:
              context.push('/profil');
              break;
          }
        },
        currentIndex: _currentIndex,
      ).run(),
    );
  }

  Widget _buildMainContent() {

    final currentList = _isSelected ? _livraisonsDestinataire : _livraisonsExpediteur;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          TextBienvenue(name: _nameUser).run(),
          const SizedBox(height: 30),
          enteteInfo("Catégories", color: Colors.black, size: fontSize),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: Listeblocktransport(
                context: context,
                typeVehicules: _typesVehicules,
              ).Run(),
            ),
          ),
          const SizedBox(height: 30),
          enteteInfo("Mes livraisons", color: Colors.black, size: fontSize),
          const SizedBox(height: 15),
          Row(
            children: [
              ButtonClient(
                isnotwifiation: _hasNewEntrant,
                isSelected: _isSelected,
                libelle: "Entrant",
                height: 40,
                action: () => setState(() => _isSelected = true),
              ).run(),
              const SizedBox(width: 20),
              ButtonClient(
                isSelected: !_isSelected,
                libelle: "Sortant",
                height: 40,
                action: () => setState(() => _isSelected = false),
              ).run(),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                children: currentList
                    .where((liv) => liv["status"] != "annulee" && liv["status"] != "terminee")
                    .map((livraison) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Commande(
                    status: " ${livraison["status"]} ",
                    titre: "Commande #${livraison["code"]} ",
                    itineraire:
                    "De : ${livraison["adresse_expedition"]} > ${livraison["adresse_destination"]}",
                    date: formaterDate(livraison["date"]!),
                    actions: _buildActions(livraison),
                    actionVoirPlus: () => ShowDetaille(context: context, livr: livraison).run(),
                  ).run(),
                ))
                    .toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildActions(Map<String, String> livraison) {
    if (livraison["status"] != "en_cours") return [];

    return [
      ButtonClient(
        libelle: "Suivre",
        action: () => _livraisonController.Suivre(
          context,
          livraison["id"]!,
          livraison["nom_livreur"] ?? '',
          livraison["numero_livreur"] ?? '',
          livraison["nom_type_livreur"] ?? '',
          livraison["immatriculation_livreur"] ?? '',
        ),
      ).run(),
      if (livraison["expediteur_id"] == _roleUser.id.toString())
        ButtonClient(
          libelle: "Fin course",
          action: () => ShowCodeConfirmationDialog(
            context: context,
            controller: _codeController,
            idLivraison: livraison["expediteur_id"]!,
            liv: _livraisonController,
          ).run(),
        ).run(),
      ButtonClient(
        color: Colors.red,
        libelle: "Annuler",
        action: () async {
          await _livraisonController.cancel(livraison["id"]!, context);
          await _initLivraisons();
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vous avez annulé une livraison.")),
          );
        },
      ).run(),
    ];
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
