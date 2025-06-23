import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:menji/view/client/pageHistorique.dart';
import '../../compenent/ButtonClient.dart';
import '../../compenent/Commande.dart';
import '../../compenent/Navigation.dart';
import '../../compenent/ShowCodeConfirmationDialog.dart';
import '../../compenent/TextBienvenue.dart';
import '../../compenent/showDetaille.dart';
import '../../controller/LivraisonController.dart';
import '../../controller/TypeVehiculeController.dart';
import '../../controller/authController.dart';
import 'package:menji/compenent/ListeBlockTransport.dart';
import 'package:menji/compenent/LivraisonCards.dart';

class PageAccueil extends StatefulWidget {
  @override
  State<PageAccueil> createState() => PageAccueilState();
}

class PageAccueilState extends State<PageAccueil> {
  Typevehiculecontroller _typevehiculecontroller=Typevehiculecontroller();

  LivraisonController _livraisonController=LivraisonController();
  final TextEditingController codeController = TextEditingController();

  late dynamic roleUser;
  late dynamic nameUser;

  List<Map<String, String>> TypesVehicules = [];
  List<Map<String, String>> listesLivraisonExpeditaire = [];
  List<Map<String, String>> listesLivraisonDestinateur = [];
  bool isLoadingTypeVehicule = true;
  bool isLoadingLivraison=false;

  void _initialisationTypeVehicule() async {

      await _typevehiculecontroller.init();
      TypesVehicules = await _typevehiculecontroller.fetchTypeVehicule();
      setState(() {
        isLoadingTypeVehicule = false;
      });
  }

  void _initialisationNom() async {

    nameUser=await AuthController().getUser();
    nameUser=nameUser.name;

    setState(() {
      isLoadingLivraison=true;
    });



  }

  Future<List<List<Map<String, String>>>> _initialisationLivraison() async {
    roleUser= await AuthController().getRole();

    await _livraisonController.init();
    listesLivraisonExpeditaire = await _livraisonController.getForExpeditaire(roleUser!.id);
    listesLivraisonDestinateur = await _livraisonController.getForDestinataire(roleUser!.id);
    return [listesLivraisonExpeditaire,listesLivraisonDestinateur];
  }



  @override
  void initState() {
    super.initState();
    _initialisationTypeVehicule();
    _initialisationLivraison();
    _initialisationNom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: Text('Accueil',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30
        ),),
        iconTheme: IconThemeData(color: Colors.orange),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.orange),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            isLoadingLivraison==false?Center(child: CircularProgressIndicator() ):

            TextBienvenue(
              name: nameUser
            ).run(),

            const SizedBox(height: 30),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Segoe UI',
                  ),
                ),
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


            SizedBox(height: 20),
            isLoadingTypeVehicule
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: Listeblocktransport(
                  context: context,
                  typeVehicules: TypesVehicules,
                ).Run(),
              ),
            ),
            SizedBox(height: 20),

            // Section "Mes livraisons"
            Row(
              children: [
                Text(
                  'Mes livraisons', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                ButtonClient(
                    isSelected: false,
                    libelle: "Entrant",
                    height: 40,
                    action: (){
                      setState(() {
                       // _selectedDeliveryIndex = 1;
                      });

                    }
                ).run(),
                const SizedBox(width: 20),

                ButtonClient(
                    libelle: "Sortant",
                    height: 40,
                    action: (){
                      setState(() {
                       // _selectedDeliveryIndex = 1;
                      });
                    }
                ).run(),
              ],
            ),
            SizedBox(height: 15),
             Container(
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                    children: [
                      FutureBuilder(
                          future: _initialisationLivraison(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else  if (snapshot.hasError) {
                              return Center(child: Text('Probleme de connexion'));
                            } else if (!snapshot.hasData || (snapshot.data![0]!.isEmpty && snapshot.data![1]!.isEmpty)) {
                              return Center(child: Text('Aucune livraison trouvée, pour l\'instant '));
                            } else {
                              return Column(
                                children:snapshot.data!.map((livraisons) {
                                  return Column(
                                      children: livraisons.map((livraison) {

                                        return (livraison["status"]!="annulee" && livraison["status"]!="terminee")?
                                        Commande(
                                            status:" ${ livraison["status"]} " ,
                                            titre: "Commande #${livraison["code"]} ",
                                            itineraire: "De : Combe > Lingwala",
                                            date: "04 Juin 2025 - 09h00", actions: [

                                          ButtonClient(
                                              libelle: "Suivre",
                                              action: (){
                                                _livraisonController.Suivre(context,livraison["id"]!);
                                              }
                                          ).run(),
                                          ButtonClient(
                                              libelle: "Fin course",
                                              action: (){
                                                livraison["expediteur_id"].toString()==roleUser.id.toString()?
                                                ShowCodeConfirmationDialog(context:context,controller:codeController,idLivraison:livraison["expediteur_id"].toString(),liv:_livraisonController).run()
                                                    :print("");
                                                //_livraisonController.confirm(context,livraison["expediteur_id"].toString(), livraison["code"].toString());
                                              }
                                          ).run()

                                        ], actionVoirPlus: () {
                                          ShowDetaille(context: context,livr: livraison).run();

                                        }
                                        ).run()

                                            :Center();
                                      }).toList()
                                  );
                                  }).toList()
                              );
                            }
                          },
                        ),
                    ]
                ),
              ) ),
          ],
        ),
      ),
      bottomNavigationBar: Navigation(context:context).run(),
    );
  }
}
