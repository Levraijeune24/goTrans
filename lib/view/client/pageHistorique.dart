import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:menji/view/client/pageHistorique.dart';
import '../../compenent/LivraisonCards.dart';
import '../../compenent/Navigation.dart';
import '../../controller/LivraisonController.dart';
import '../../controller/TypeVehiculeController.dart';
import '../../controller/authController.dart';
import 'package:menji/compenent/ListeBlockTransport.dart';


class PageHistorique extends StatefulWidget {
  @override
  State<PageHistorique> createState() => PageHistoriqueState();
}

class PageHistoriqueState extends State<PageHistorique> {

  LivraisonController _livraisonController=LivraisonController();
  final TextEditingController codeController = TextEditingController();
  late dynamic roleUser;

  List<Map<String, String>> listes1 = [];
  List<Map<String, String>> listesLivraison1 = [];
  List<Map<String, String>> listesLivraisonDestinateur = [];
  List<Map<String, String>> listesLivraisonExpeditaire = [];


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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Mes historiques'),
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
            // Section "Mes livraisons"
            Row(
              children: [
                Text(
                  'Mes livraisons',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20),
                Icon(Icons.local_shipping, size: 24, color: Colors.orange),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.orange, size: 24),
                  onPressed: _initialisationLivraison,
                ),
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
                                        children: livraisons.map((livraison) {
                                          return  LivraisonsCard(expediteur:livraison["expediteur"]!,
                                              destinateur: livraison["destinateur"]!,id: livraison["id"]!,
                                              moyen_transport: livraison["moyen_transport"]!,status:livraison["status"]!,date: livraison["date"]!,liv:livraison,
                                              typeLivraison: livraison["expediteur_id"]!=roleUser.id?"sortant":"entrant",

                                              Annuler: (id){
                                                setState(() {
                                                  _livraisonController.cancel(id,context);
                                                  _initialisationLivraison();
                                                });
                                              },Confirmer: (id){

                                              },showInformation: (liv){

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
      bottomNavigationBar: Navigation(context:context).run(),
    );
  }
}



