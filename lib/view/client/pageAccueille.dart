import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:menji/view/client/pageHistorique.dart';
import '../../compenent/Navigation.dart';
import '../../compenent/ShowCodeConfirmationDialog.dart';
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

  List<Map<String, String>> TypesVehicules = [];
  List<Map<String, String>> listesLivraisonExpeditaire = [];
  List<Map<String, String>> listesLivraisonDestinateur = [];
  bool isLoadingTypeVehicule = true;

  void _initialisationTypeVehicule() async {

      await _typevehiculecontroller.init();
      TypesVehicules = await _typevehiculecontroller.fetchTypeVehicule();
      setState(() {
        isLoadingTypeVehicule = false;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Page d\'accueil'),
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
            Row(
              children: [
                Text(
                  'Moyen de transport',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20),
                Icon(Icons.directions_car, size: 24, color: Colors.orange),
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
                                        return (livraison["status"]!="annulee" || livraison["status"]!="terminee")? LivraisonsCard(expediteur:livraison["expediteur"]!,
                                            destinateur: livraison["destinateur"]!,id: livraison["id"]!,
                                            moyen_transport: livraison["moyen_transport"]!,status:livraison["status"]!,date: livraison["date"]!,liv:livraison,
                                            typeLivraison: livraison["expediteur_id"].toString()==roleUser.id.toString()?"sortant":"entrant",
                                            Annuler: (id){
                                              setState(() {
                                                _livraisonController.cancel(id,context);
                                                _initialisationLivraison();
                                              });
                                            },Confirmer: (id){
                                              livraison["expediteur_id"].toString()!=roleUser.id.toString()?
                                              ShowCodeConfirmationDialog(context:context,controller:codeController,idLivraison:id,liv:_livraisonController).run()
                                             :print("");
                                            },showInformation: (liv){
                                              ShowDetaille(context: context,livr: liv).run();
                                            },suivre: (){
                                              _livraisonController.Suivre(context,livraison["id"]!);
                                            }
                                        ).run():Center();
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
