import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../compenent/LivraisonCards.dart';
import '../../compenent/Navigation.dart';
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
  LivraisonController _livraisonController=LivraisonController();
  late final roleUser;
  final TextEditingController codeController = TextEditingController();

  void _initialisationLivraison() async {
    await _livraisonController.init();

    roleUser = await AuthController().getRole();
    setState(() {
      livraisonsFuture = _livraisonController.AllLivraisonLivreur(roleUser.id) ;
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
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Aucune livraisons pour vous maintanant'));
                } else {
                  return ListView(
                    children: snapshot.data!.map((livraison) {
                      return livraison["status"]=="validee" || livraison["status"]=="en_cours" || livraison["status"]=="terminee" ?


                      LivraisonsCard(expediteur:livraison["expediteur"]!,
                          destinateur: livraison["destinateur"]!,id: livraison["id"]!,
                          moyen_transport: livraison["moyen_transport"]!,status:livraison["status"]!,date: livraison["date"]!,liv:livraison,

                          typeCl: 1,

                          Annuler: (id){
                            setState(() {
                              _livraisonController.annulerLivraison(id,context);
                              _initialisationLivraison();
                            });
                          },Confirmer: (id){
                            _showCodeConfirmationDialog(context,codeController,id,_livraisonController);
                          },showInformation: (liv){
                            Livreurcontroller().getDetailleLivraison(context,livraison["id_livreur"]! , livraison["id"]! );
                          }
                      ).run():Center();





                    }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
        bottomNavigationBar: Navigation(context:context,type: 1).run()
    );
  }

  Widget _buildDeliveryCard(String expediteur, String destinateur, String status,
      String date, String id_livraison, String id_livreur) {
    Color statusColor =
    status == 'en_cours' ? Colors.blue : Colors.orange;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expediteur', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Destinateur', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(expediteur),
                Text(destinateur),
                Text(date),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text("Statut : $status",
                      style: TextStyle(color: Colors.white)),
                ),
                InkWell(
                  onTap: (){
                    Livreurcontroller().getDetailleLivraison(context,id_livreur , id_livraison);

                  },
                  child:Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text("Detailles",
                        style: TextStyle(color: Colors.white)),
                  ) ,
                )
                ,
              ],
            ),
          ],
        ),
      ),
    );
  }
}



void _showCodeConfirmationDialog(
    BuildContext context,
    TextEditingController controller,
    String idLivraison,
    LivraisonController liv,

    ) {

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Confirmation"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Entrez le code de validation :"),
          SizedBox(height: 10),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Code de validation",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text("Annuler"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text("Valider"),
          onPressed: () async {
            String code = controller.text;

            liv.confirmerLivraison(context,idLivraison, controller.text);

          },
        ),
      ],
    ),
  );
}