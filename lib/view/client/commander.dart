import 'package:flutter/material.dart';
import 'package:menji/controller/LivraisonController.dart';

import '../../controller/ClientController.dart';
import '../../controller/authController.dart';


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
  final _formKey = GlobalKey<FormState>();
  LivraisonController _livraisonController  =LivraisonController();
  ClientController _clientController= ClientController();

  List<Map<String,String>> clients=[];
  late bool isLoadingClient=true;


  late String selectedValueName;
  late String id_client;
  late final roleUser;



  final TextEditingController controllerAdresseExpediteur = TextEditingController();
  final TextEditingController controllerAdresseDestinateur = TextEditingController();
  final TextEditingController controllerNumeroDestinateur = TextEditingController();
  final TextEditingController controllerNomDestinateur = TextEditingController();
  final TextEditingController controllerNumeroExpediteur = TextEditingController();



  void _initialisationClients() async {

    roleUser= await AuthController().getRole();
    await _clientController.setToken();
    await _livraisonController.setToken();
    print('roleUser.id');
    print(roleUser.id);
    clients = await _clientController.getClient();

    selectedValueName=clients[0]["nom"]??"";
    id_client=clients[0]["id"]??"0";


    setState(() {
      isLoadingClient = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initialisationClients();

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
        title: Text('Commander', style: TextStyle(color: Colors.orange)),
      ),
      body:Form(
    key: _formKey,
    child: Column(
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
                        _buildValidatedTextField(controller: controllerAdresseExpediteur, label: 'Adresse', icon: Icons.person,type:TextInputType.text ),
                        SizedBox(height: 20),
                        _buildValidatedTextField(controller: controllerNumeroExpediteur, label: 'Numéro téléphone', icon: Icons.phone,type:TextInputType.phone ),
                        SizedBox(height: 20),
                        _sectionTitle('Destinataire'),
                        _buildValidatedTextField(controller: controllerAdresseDestinateur, label: 'Adresse', icon: Icons.location_on,type:TextInputType.text),
                        SizedBox(height: 20),

                      buildSearchableComboBox(
                        controller: controllerNomDestinateur,
                        label: "Clients",
                        options: clients.map((client) =>client).toList(),
                        onChanged: (String? id, String? nom) {
                          print("ID: $id, Nom: $nom");
                          setState(() {
                            id_client= id!;
                            selectedValueName = nom ?? "";
                          });
                        },
                      )
                        ,

                        SizedBox(height: 20),
                        _buildValidatedTextField(controller: controllerNumeroDestinateur, label: 'Numéro téléphone', icon: Icons.phone,type:TextInputType.phone),
                        SizedBox(height: 40),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {

                              print("ICICICI");

                              if (_formKey.currentState!.validate()) {
                                _livraisonController.storeLivraison(
                                  roleUser.id.toString(),
                                  id_client,
                                   controllerNomDestinateur.text,
                                  controllerAdresseExpediteur.text,
                                  controllerAdresseDestinateur.text,
                                  controllerNumeroDestinateur.text,
                                  controllerNumeroExpediteur.text,
                                  widget.recaPoid[1],
                                  context,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Veuillez remplir tous les champs obligatoires")),
                                );
                              }
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
      ));
  }

  Widget _buildValidatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType type,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: type,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le champ "$label" est requis';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        )
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
Widget buildSearchableComboBox({
  required String label,
  required List<Map<String, String>> options,
  required TextEditingController controller,
  required Function(String?, String?) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      const SizedBox(height: 5),
      Autocomplete<Map<String, String>>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<Map<String, String>>.empty();
          }
          return options.where((client) =>
              client["nom"]!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
        },
        displayStringForOption: (option) => option["nom"]!,
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          controller.text = textEditingController.text;
          return TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: label,
            ),
            onChanged: (text) {
              onChanged(null, text); // saisie libre
            },
          );
        },
        onSelected: (Map<String, String> selection) {
          controller.text = selection["nom"]!;
          onChanged(selection["id"], selection["nom"]);
        },
      ),
    ],
  );
}
