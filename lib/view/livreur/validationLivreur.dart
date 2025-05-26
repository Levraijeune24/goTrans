import 'package:flutter/material.dart';

import '../../controller/LivraisonController.dart';

class PageValidation extends StatefulWidget {

  late String id_livraison;
 late  String id_livreur;


  PageValidation(this.id_livreur,this.id_livraison);

  @override
  _PageValidationState createState() => _PageValidationState(this.id_livreur,this.id_livraison);
}

class _PageValidationState extends State<PageValidation> {

  TextEditingController prixUnitaireController = TextEditingController();
  TextEditingController poidsController = TextEditingController();
  TextEditingController prixTotalController = TextEditingController();


  late String id_livraison;
  late  String id_livreur;
  late List<Map<String, String>> livraisons;
  bool isLoadingTypeVehicule=false;

  void initInfoLivraison() async{

    livraisons=await LivraisonController().ShowLivraisonLivreur(id_livreur , id_livraison);

    print(livraisons);

    setState(() {
      isLoadingTypeVehicule = true;
    });

  }

  _PageValidationState(this.id_livreur,this.id_livraison);


  @override
  void initState() {
    initInfoLivraison();
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Validation',
          style: TextStyle(color: Colors.orange),
        ),
      ),
      body:SingleChildScrollView(
        child:
       Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations clients',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            isLoadingTypeVehicule==false?CircularProgressIndicator():
            _buildInfoRow('Nom de l\'xpéditeur', livraisons[0]["nom_expediteur"]!, Icons.person),

            isLoadingTypeVehicule==false?CircularProgressIndicator():
            _buildInfoRow('Adresse de l\'expediteur', livraisons[0]["adresse_expedition"]!, Icons.location_on),

            isLoadingTypeVehicule==false?CircularProgressIndicator():
            _buildInfoRow('Téléphone de l\'expediteur ', livraisons[0]["tel_expedition"]!, Icons.phone),

            Divider(
              color: Colors.grey, // couleur de la ligne
              thickness: 1,       // épaisseur
              indent: 20,         // espace à gauche
              endIndent: 20,      // espace à droite
            ),

            isLoadingTypeVehicule==false?CircularProgressIndicator():
            _buildInfoRow('Nom du destinataire', livraisons[0]["nom_destinateur"]!, Icons.person),

            isLoadingTypeVehicule==false?CircularProgressIndicator():
            _buildInfoRow('Adresse du destinateur ', livraisons[0]["adresse_destination"]!, Icons.location_on),

            isLoadingTypeVehicule==false?CircularProgressIndicator():
            _buildInfoRow('Téléphone du destinateur', livraisons[0]["tel_destination"]!, Icons.phone),
            SizedBox(height: 20),
            Text(
              'Tarification',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildPricingRow('Prix unitaire', prixUnitaireController),
            _buildPricingRow('Poids', poidsController),
            _buildPricingRow('Prix total', prixTotalController),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {

                  LivraisonController().editLivraisonLivreur(context,livraisons[0]["id_livraison"]!, prixTotalController.text, prixTotalController.text);
                  // Vous pouvez ajouter ici une logique pour traiter la confirmation

                },
                child: Text('Confirmer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.all(10.0),
              width: 300,
              color: Colors.white,
              child: Text(value),
            ),
          ],
        ),
        Icon(icon),
      ],
    );
  }

  Widget _buildPricingRow(String label, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.only(top: 5.0, bottom: 10.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Container(
            width: 200,
            height: 40,
            child: TextField(
              keyboardType: TextInputType.number,
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Entrez $label',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }}



