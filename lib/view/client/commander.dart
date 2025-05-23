import 'package:flutter/material.dart';
import 'package:menji/controller/LivraisonController.dart';


class MyApps extends StatelessWidget {
  final List<String> recaPoid;

  MyApps(this.recaPoid);

  @override
  Widget build(BuildContext context) {
    return PageCommander(recaPoid);
  }
}

class PageCommander extends StatefulWidget {
  final List<String> recaPoid;

  PageCommander(this.recaPoid);

  @override
  _PageCommanderState createState() => _PageCommanderState();
}

class _PageCommanderState extends State<PageCommander> {
  final TextEditingController controllerAdresseExpediteur = TextEditingController();
  final TextEditingController controllerAdresseDestinateur = TextEditingController();
  final TextEditingController controllerNumeroDestinateur = TextEditingController();
  final TextEditingController controllerNomDestinateur = TextEditingController();
  final TextEditingController controllerNumeroExpediteur = TextEditingController();

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
        title: Text('Commander', style: TextStyle(color: Colors.orange)),
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Récap : ${widget.recaPoid[0]}',
                          style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        _sectionTitle('Expéditeur'),
                        _buildTextField(controller: controllerAdresseExpediteur, label: 'Adresse', icon: Icons.person),
                        SizedBox(height: 20),
                        _buildTextField(controller: controllerNumeroExpediteur, label: 'Numéro téléphone', icon: Icons.phone),
                        SizedBox(height: 20),
                        _sectionTitle('Destinataire'),
                        _buildTextField(controller: controllerAdresseDestinateur, label: 'Adresse', icon: Icons.location_on),
                        SizedBox(height: 20),
                        _buildTextField(controller: controllerNomDestinateur, label: 'Nom complet', icon: Icons.person),
                        SizedBox(height: 20),
                        _buildTextField(controller: controllerNumeroDestinateur, label: 'Téléphone', icon: Icons.phone),
                        SizedBox(height: 40),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              LivraisonController().storeLivraison(
                                controllerAdresseExpediteur.text,
                                controllerAdresseDestinateur.text,
                                controllerNumeroDestinateur.text,
                                controllerNumeroExpediteur.text,
                                widget.recaPoid[1],
                                context,
                              );
                            },
                            child: Text('Commander'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        SizedBox(width: 10),
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
