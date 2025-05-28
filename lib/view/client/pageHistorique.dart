import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controller/LivraisonController.dart';
import '../../controller/LivreurController.dart';
import '../../controller/authController.dart';
import '../authentification/ProfilePage.dart';



class PageHistorique extends StatefulWidget {
  @override
  _PageHistoriqueState createState() => _PageHistoriqueState();
}

class _PageHistoriqueState extends State<PageHistorique> {
  late Future<List<Map<String, String>>> livraisonsFuture;
  late final roleUser;

  void _initialisationLivraison() async {
     roleUser = await AuthController().getRole();

     setState(() {
       livraisonsFuture = LivraisonController()
         .AllLivraison(roleUser.id) as Future<List<Map<String, String>>>;
     });

  }
  // void _initialisationLivraisonDestinateur() async {
  //   final roleUser= await AuthController().getRole();
  //   listesLivraisonDestinateur = await _livraisonController.AllLivraisonDestinateur(roleUser!.id);
  //   print("00000000000");
  //   setState(() {
  //     isLoadingLivraisonDestinateur = false;
  //   });
  // }

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
          backgroundColor: Colors.white,
          title: Text('Page historique'),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.orange),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.orange),
              onPressed: () {},
            ),
            SizedBox(width: 20),
          ],
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
                    return Center(child: Text('Aucune livraison trouvée.'));
                  } else {
                    return ListView(
                      children: snapshot.data!.map((livraison) {
                        return _buildDeliveryCard(
                            livraison["expediteur"] ?? '',
                            livraison["destinateur"] ?? '',
                            livraison["status"] ?? '',
                            livraison["date"] ?? '',
                            livraison["id_livraison"] ?? '',
                            livraison["id_livreur"] ?? ''
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.grey[200],
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Historique',
            ),

            BottomNavigationBarItem(

              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          currentIndex: 0,
          onTap: (index) {
            print(index);
            if(index==2){


              context.go('/profil');

            }
            // Gérer la navigation ici
          },
        )
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

                  },
                  child:Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text("Plus des detailles",
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
