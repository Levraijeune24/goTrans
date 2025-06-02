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
  int prixTotalController =1;
  final _formKey = GlobalKey<FormState>();


  late String id_livraison;
  late  String id_livreur;
  late List<Map<String, String>> livraisons;
  bool isLoadingTypeVehicule=false;

  void initInfoLivraison() async{

    livraisons=await LivraisonController().ShowLivraisonLivreur(id_livreur , id_livraison);
    print("pppppppppppppp");
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
      body:Form(
        child:SingleChildScrollView(
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
                _buildInfoRow('Nom de l\'xpéditeur', livraisons[0]["expediteur"] ?? "", Icons.person),

                 isLoadingTypeVehicule==false?CircularProgressIndicator():
                 _buildInfoRow('Adresse de l\'expediteur', livraisons[0]["adresse_expedition"]!?? "", Icons.location_on),

                 isLoadingTypeVehicule==false?CircularProgressIndicator():
                 _buildInfoRow('Téléphone de l\'expediteur ', livraisons[0]["tel_expedition"]!?? "", Icons.phone),

                Divider(
                  color: Colors.grey, // couleur de la ligne
                  thickness: 1,       // épaisseur
                  indent: 20,         // espace à gauche
                  endIndent: 20,      // espace à droite
                ),

                 isLoadingTypeVehicule==false?CircularProgressIndicator():
                 _buildInfoRow('Nom du destinataire', livraisons[0]["destinateur"]!?? "", Icons.person),

                 isLoadingTypeVehicule==false?CircularProgressIndicator():
                 _buildInfoRow('Adresse du destinateur ', livraisons[0]["adresse_destination"]!?? "", Icons.location_on),

                 isLoadingTypeVehicule==false?CircularProgressIndicator():
                 _buildInfoRow('Téléphone du destinateur', livraisons[0]["tel_destination"]!?? "", Icons.phone),
                 SizedBox(height: 20),
                Text(
                  'Tarification',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Form(
                  key:_formKey ,
                    child: Column(
                  children: [

                    isLoadingTypeVehicule==false?CircularProgressIndicator():
                    _buildRow('Prix unitaire',livraisons[0]["tarif"]!+" Fc"),

                    _buildPricingRow('Entrer le poids', poidsController,(){

                      setState(() {
                        prixTotalController=int.parse(poidsController.text)*int.parse(livraisons[0]["tarif"].toString());
                      });
                    }),
                    _buildRow('Prix total', prixTotalController.toString()+"  Fc"),
                  ],
                )),

                SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {



                        print([livraisons[0]["id"]!,
                          prixTotalController.toString(), poidsController.text]);

                        LivraisonController().editLivraisonLivreur(context,livraisons[0]["id"]!,
                            prixTotalController.toString(), poidsController.text);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Veuillez remplir tous les champs obligatoires")),
                        );
                      }


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
        ) ,
      )  );
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

  Widget _buildPricingRow(String label, TextEditingController controller,Function set) {
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
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: controller,
              onChanged: (value) {

                set();

              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le champ "$label" est requis';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Entrez $label',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            )
            ,
          ),
        ],
      ),
    );
  }}



Widget _buildRow(String label, String text) {
  return Container(
    padding: const EdgeInsets.all(10.0),
    margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}




