import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../compenent/LivraisonCards.dart';
import '../../compenent/Navigation.dart';
import '../../compenent/ShowCodeConfirmationDialog.dart';
import '../../controller/LivraisonController.dart';
import '../../controller/LivreurController.dart';
import '../../controller/authController.dart';
import '../authentification/ProfilePage.dart';


class PageLivreur extends StatefulWidget {
  @override
  _PageLivreurState createState() => _PageLivreurState();
}

class _PageLivreurState extends State<PageLivreur> {
  late Future<List<Map<String, String>>> livraisonsFuture;
  LivraisonController _livraisonController = LivraisonController();
  late  TextEditingController codeController = TextEditingController();

  void _initialisationLivraison() async {
    await _livraisonController.init();

    var roleUser = await AuthController().getRole();
    setState(()  {
      livraisonsFuture = _livraisonController.getForLivreur(roleUser!.id);

    });
  }

  @override
  void initState() {
    super.initState();
    _initialisationLivraison();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Page d\'accueil livreur'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/map_image.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: livraisonsFuture,
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Probleme de connexion...'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text('Aucune livraisons pour vous maintanant'));
                  } else {

                    return ListView(
                      children: snapshot.data!.map((livraison) {

                        return livraison["status"] == "validee" ||
                            livraison["status"] == "en_cours" ||
                            livraison["status"] == "terminee"||
                            livraison["status"] == "validee"
                            ?
                        LivraisonsCard(expediteur: livraison["expediteur"]!,
                            destinateur: livraison["destinateur"]!,
                            id: livraison["id"]!,
                            moyen_transport: livraison["moyen_transport"]!,
                            status: livraison["status"]!,
                            date: livraison["date"]!,
                            liv: livraison,
                            isExpeditaire: true,

                            typeCl: 1,

                            Annuler: (id) {
                              setState(() {
                                _livraisonController.cancel(
                                    id, context);
                                _initialisationLivraison();
                              });
                            },
                            Confirmer: (id) {
                              ShowCodeConfirmationDialog(context: context,
                                  controller: codeController,
                                  idLivraison: id,
                                  liv: _livraisonController).run();
                            },
                            showInformation: (liv) {
                              Livreurcontroller().getDetailleLivraison(
                                  context, livraison["id_livreur"]!,
                                  livraison["id"]!);
                            }
                        ).run() : Center();
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: Navigation(context: context, type: 1).run()
    );
  }
}