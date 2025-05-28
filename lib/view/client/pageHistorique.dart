import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:menji/view/client/pageHistorique.dart';
import '../../controller/LivraisonController.dart';
import '../../controller/TypeVehiculeController.dart';
import '../../controller/authController.dart';
import 'package:menji/compenent/ListeBlockTransport.dart';


class PageHistorique extends StatefulWidget {
  @override
  State<PageHistorique> createState() => PageHistoriqueState();
}

class PageHistoriqueState extends State<PageHistorique> {
  Typevehiculecontroller _typevehiculecontroller=Typevehiculecontroller();
  LivraisonController _livraisonController=LivraisonController();
  final TextEditingController codeController = TextEditingController();

  List<Map<String, String>> listes1 = [];
  List<Map<String, String>> listesLivraison1 = [];
  List<Map<String, String>> listesLivraisonDestinateur = [];

  bool isLoadingTypeVehicule = true;
  bool isLoadingLivraison = true;
  bool isLoadingLivraisonDestinateur = true;

  void _initialisationTypeVehicule() async {

    await _typevehiculecontroller.setToken();
    listes1 = await _typevehiculecontroller.AllTypeVehicule();
    setState(() {
      isLoadingTypeVehicule = false;
    });
  }

  void _initialisationLivraison() async {
    final roleUser= await AuthController().getRole();
    listesLivraison1 = await _livraisonController.AllLivraison(roleUser!.id);
    setState(() {
      isLoadingLivraison = false;
    });
  }

  void _initialisationLivraisonDestinateur() async {
    final roleUser= await AuthController().getRole();
    listesLivraisonDestinateur = await _livraisonController.AllLivraisonDestinateur(roleUser!.id);
    setState(() {
      isLoadingLivraisonDestinateur = false;
    });
  }



  @override
  void initState() {
    super.initState();
    _initialisationTypeVehicule();
    _initialisationLivraison();
    _initialisationLivraisonDestinateur();
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
                        isLoadingLivraison
                            ? Center(child: CircularProgressIndicator())
                            :
                        Column(
                          children: listesLivraison1.map((livraison) {
                            return (livraison["status"] =="annulee" || livraison["status"] =="terminee") ?_buildDeliveryCard(
                                livraison["expediteur"]!,
                                livraison["destinateur"]!,
                                livraison["moyen_transport"]!,
                                livraison["status"]!,
                                livraison["date"]!,
                                livraison["id"]!,
                                livraison
                            ):Center();
                          }).toList(),
                        ),
                        isLoadingLivraisonDestinateur?
                        Center(child: CircularProgressIndicator()):
                        Column(
                            children: listesLivraisonDestinateur.map((livraison) {

                              return (livraison["status"] =="annulee" || livraison["status"] =="terminee") ? _buildDeliveryCard(
                                  livraison["expediteur"]!,
                                  livraison["destinateur"]!,
                                  livraison["moyen_transport"]!,
                                  livraison["status"]!,
                                  livraison["date"]!,
                                  livraison["id"]!,
                                  livraison

                              ):Center();
                            }).toList())

                      ]
                  ),

                ) ,
          ],
        ),
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
          }else if(index==1){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PageHistorique()),
            );
          }
          // Gérer la navigation ici
        },
      ),
    );
  }

  Widget _buildDeliveryCard(
      String expediteur, String destinateur, String moyen_transport, String status,String date,String id,Map<String, String> liv) {
    Color statusColor =
    status == 'en_cours' ? Colors.blue : Colors.orange;
    statusColor = status == 'terminee' ? Colors.green : Colors.orange;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Titres
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expediteur', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Destinateur', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Moyen de transport', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(),
            // Données
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(expediteur),
                Text(destinateur),
                Text(moyen_transport),
                Text(date),
              ],
            ),
            Divider(),
            // Boutons d'action
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
                    _showCodeDetaille(context,liv);

                  },
                  child:Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text("plus d'informations", style: TextStyle(color: Colors.white)),
                  ) ,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}



void _showCodeDetaille(
    BuildContext context,
    Map<String, String> livr,
    ) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          Icon(Icons.local_shipping, color: Colors.blue),
          SizedBox(width: 10),
          Text(
            "Détails de la Livraison",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStyledRow(Icons.person, "Expéditeur :", livr["expediteur"] ?? "Inconnu"),
            SizedBox(height: 10),
            _buildStyledRow(Icons.person_outline, "Destinataire :", livr["destinateur"] ?? "Inconnu"),
            SizedBox(height: 10),
            _buildStyledRow(Icons.location_on, "Adresse d'expedition :", livr["adresse_expedition"] ?? "N/A"),
            SizedBox(height: 10),
            _buildStyledRow(Icons.location_on, "Adresse de destination :", livr["adresse_destination"] ?? "N/A"),
            SizedBox(height: 10),
            _buildStyledRow(Icons.qr_code, "Code Livraison :", "Non disponible"),
            SizedBox(height: 10),
            _buildStyledRow(Icons.date_range, "Date :", livr["date"] ?? "Non précisée"),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          icon: Icon(Icons.copy, color: Colors.blue),
          label: Text("Copier le code"),
          onPressed: () {
            final code = livr["code"] ?? "";
            Clipboard.setData(ClipboardData(text: code));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Code copié dans le presse-papiers")),
            );
          },
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.close),
          label: Text("Fermer"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

Widget _buildStyledRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: Colors.blueAccent),
      SizedBox(width: 10),
      Expanded(
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(text: "$label ", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: value),
            ],
          ),
        ),
      ),
    ],
  );
}
