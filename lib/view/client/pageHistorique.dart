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

  LivraisonController _livraisonController=LivraisonController();
  final TextEditingController codeController = TextEditingController();
  late dynamic roleUser;


  late var _currentIndex=0;

  List<Map<String, String>> listes1 = [];
  List<Map<String, String>> listesLivraison1 = [];
  List<Map<String, String>> listesLivraisonDestinateur = [];
  List<Map<String, String>> listesLivraisonExpeditaire = [];

  bool isSelected=true;




  bool isLoadingTypeVehicule = true;
  bool isLoadingLivraison = true;
  bool isLoadingLivraisonDestinateur = true;


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
    _initialisationLivraison();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBarCostum(context:context,libelle:"Mon historique").run(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section "Mes livraisons"
            Row(
              children: [
                enteteInfo("Mes livraisons"),
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                ButtonClient(
                    isSelected: isSelected,
                    libelle: "Entrant",
                    height: 40,
                    action: (){
                      setState(() {
                        isSelected=!isSelected;
                      });

                    }
                ).run(),
                const SizedBox(width: 20),

                ButtonClient(
                  isSelected: !isSelected,
                    libelle: "Sortant",
                    height: 40,
                    action: (){
                      setState(() {
                        isSelected=!isSelected;
                      });
                    }
                ).run(),

                const SizedBox(width: 20),

                ButtonClient(
                  isSelected: false,
                    libelle: "All",
                    height: 40,
                    action: (){
                      setState(() {
                        // _selectedDeliveryIndex = 1;
                      });
                    }
                ).run(),
              ],
            ),
            SizedBox(height: 10),
          SingleChildScrollView(
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
                                        children: livraisons.where((livraison){
                                          String expediteurId = livraison["expediteur_id"].toString();
                                          String userId = roleUser.id.toString();

                                          return isSelected
                                              ? expediteurId != userId
                                              : expediteurId == userId;
                                        }).map((livraison) {
                                          return  Commande(
                                              status:" ${ livraison["status"]} " ,
                                              titre: "Commande #${livraison["code"]} ",
                                              itineraire: "De : Combe > Lingwala",
                                              date: formaterDate(livraison["date"]!), actions: [

                                            livraison["status"] == "en_cours"?
                                            ButtonClient(
                                                libelle: "Fin course",
                                                action: (){
                                                  livraison["expediteur_id"].toString()==roleUser.id.toString()?
                                                  ShowCodeConfirmationDialog(context:context,controller:codeController,idLivraison:livraison["expediteur_id"].toString(),liv:_livraisonController).run()
                                                      :print("");
                                                  //_livraisonController.confirm(context,livraison["expediteur_id"].toString(), livraison["code"].toString());
                                                }
                                            ).run():Center()

                                          ], actionVoirPlus: () {
                                            ShowDetaille(context: context,livr: livraison).run();

                                          }
                                          ).run();
                                        }).toList()
                                    );
                                  }).toList()
                              );
                            }
                          },
                        ),
                      ]
                  ),

                ) ,
          ],
        ),
      ),
      bottomNavigationBar: MenuNavigation(
        action: (index){
      if(index==2){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      }
      else if(index==1){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PageHistorique()),
        );
      }
      else if(index==0){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PageAccueil()),
        );

      }
    },
    currentIndex: _currentIndex
    ).run(),
    );
  }
}



