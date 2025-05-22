import 'package:flutter/material.dart';
import 'package:menji/controller/LivraisonController.dart';


class MyApps extends StatelessWidget {

  List<String> recaPoid;
  MyApps(this.recaPoid);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commander',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: PageCommander(recaPoid),
    );
  }
}

class PageCommander extends StatefulWidget {
  List<String> recaPoid;
  PageCommander(this.recaPoid);
  @override
  _PageCommanderState createState() => _PageCommanderState(this.recaPoid);
}

class _PageCommanderState extends State<PageCommander> {
  List<String> recaPoid;
  _PageCommanderState(this.recaPoid);
  final TextEditingController controllerAdresseExpediteur = TextEditingController();
  final TextEditingController controllerAdresseDestinateur = TextEditingController();
  final TextEditingController controllerNumeroDestinateur = TextEditingController();
  final TextEditingController controllerNomDestinateur = TextEditingController();
  final TextEditingController controllerNumeroExpediteur=TextEditingController();


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
        title: Row(
          children: [
            Text(
              'Commander',
              style: TextStyle(color: Colors.orange),
            ),
          ],
        ),
        centerTitle: false,
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
            child: DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 1.0,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'recap :  '+recaPoid[0],
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Adresse de destination',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Expéditeur',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildTextField(
                            controller: controllerAdresseExpediteur,
                            label: 'Entrez l\'adresse ou utilisez maps',
                            hintText: 'Expéditeur',
                            icon: Icons.person,
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            controller: controllerNumeroExpediteur,
                            label: 'Entrez le numero de expediteur',
                            hintText: 'Expéditeur',
                            icon: Icons.phone,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Destinataire',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildTextField(
                            controller: controllerAdresseDestinateur,
                            label: 'Entrez l\'adresse ou utilisez maps',
                            hintText: 'Destinataire',
                            icon: Icons.location_on,
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            controller: controllerNomDestinateur,
                            label: 'Entrez votre nom',
                            hintText: 'Nom complet',
                            icon: Icons.person,
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            controller: controllerNumeroDestinateur,
                            label: 'Entrez votre numéro de téléphone',
                            hintText: 'Téléphone',
                            icon: Icons.phone,
                          ),
                          SizedBox(height: 40),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                // print([controllerAdresseExpediteur.text,
                                // controllerAdresseDestinateur.text,
                                //   controllerNomDestinateur.text,
                                //   controllerNumeroDestinateur.text
                                // ]
                                // );
                                 LivraisonController(context).storeLivraison(controllerAdresseExpediteur.text,
                                     controllerAdresseDestinateur.text,
                                     controllerNumeroDestinateur.text,
                                     controllerNumeroExpediteur.text,
                                     recaPoid[1]

                                 );


                              },
                              child: Text('Commander'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String hintText, required IconData icon,required controller}) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller:controller ,
            decoration: InputDecoration(
              labelText: label,
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ],
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text("Votre demande est en attente..."),
          actions: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: TextButton(
                child: Text("OK", style: TextStyle(color: Colors.white)), // Texte blanc pour le bouton
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
              ),
            ),
          ],
        );
      },
    );
  }
}