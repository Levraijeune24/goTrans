import 'package:flutter/material.dart';
import 'package:menji/controller/LivraisonController.dart';
import '../../controller/ClientController.dart';
import '../../controller/authController.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';


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
  LatLng currentPosition =LatLng(-4.322447, 15.307045);
  final MapController _mapController = MapController();
  Set<Marker> _markers = {};
  bool _isLoading = true;
  double _zoomLevel = 17.0;

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Polyline? routePolyline;
  LatLng destination = LatLng(-4.322447, 15.307045);
  final _formKey = GlobalKey<FormState>();
  final LivraisonController _livraisonController = LivraisonController();
  final ClientController _clientController = ClientController();

  List<Map<String, String>> clients = [];
  bool isLoadingClient = true;

  String selectedValueName = '';
  dynamic id_client =null;
  dynamic roleUser;

  final TextEditingController controllerAdresseExpediteur = TextEditingController();
  final TextEditingController controllerAdresseDestinateur = TextEditingController();
  final TextEditingController controllerNumeroDestinateur = TextEditingController();
  final TextEditingController controllerNomDestinateur = TextEditingController();
  final TextEditingController controllerNumeroExpediteur = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialisationClients();
    _determinePosition();
  }

  void _initialisationClients() async {
    await _livraisonController.init();
    await _clientController.init();
    roleUser = await AuthController().getRole();
    clients = await _clientController.getClient();

    setState(() {
      isLoadingClient = false;
    });
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Les services de localisation sont désactivés');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Les permissions de localisation sont refusées');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();

      print('=== COORDONNÉES GPS ===');
      print('Latitude: ${position.latitude}');
      print('Longitudes: ${position.longitude}');
      print('Altitude: ${position.altitude}');
      print('Précision: ${position.accuracy}m');
      print('========================');


      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(currentPosition, _zoomLevel);
        _isLoading = false;
      });

    } catch (e) {
      print('Erreur lors de la récupération de la position: $e');
      setState(() => _isLoading = false);
    }
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel += 1;
      _mapController.move(_mapController.camera.center, _zoomLevel);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel -= 1;
      _mapController.move(_mapController.camera.center, _zoomLevel);
    });
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
      body:
          Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: currentPosition!, // Centré sur le Palais du Peuple par défaut
                  initialZoom: _zoomLevel,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.app',
                    tileBuilder: (context, widget, tile) {
                      return ColorFiltered(
                        colorFilter: ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0,      0,      0,      1, 0,
                        ]),
                        child: widget,
                      );
                    },
                  ),
                  MarkerLayer(
                    markers: [
                      if (currentPosition != null)
                        Marker(
                          point: currentPosition!,
                          width: 60,
                          height: 60,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.location_on, color: Colors.red, size: 60),
                              Positioned(
                                top: 15,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 15,
                bottom: 520,
                child: FloatingActionButton(
                  mini: true,
                  heroTag: 'location',
                  onPressed: _determinePosition,
                  child: Icon(Icons.my_location),
                  backgroundColor: Colors.white,
                ),
              ),

              Positioned(
                right: 15,
                bottom: 400,
                child: Column(
                  children: [
                    FloatingActionButton(
                      mini: true,
                      heroTag: 'zoomIn',
                      onPressed: _zoomIn,
                      child: Icon(Icons.add),
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: 10),
                    FloatingActionButton(
                      mini: true,
                      heroTag: 'zoomOut',
                      onPressed: _zoomOut,
                      child: Icon(Icons.remove),
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
              ),

              Form(
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
                                  _buildValidatedTextField(controller: controllerAdresseExpediteur, label: 'Adresse', icon: Icons.person, type: TextInputType.text),
                                  SizedBox(height: 20),
                                  _buildValidatedTextField(controller: controllerNumeroExpediteur, label: 'Numéro téléphone', icon: Icons.phone, type: TextInputType.phone),
                                  SizedBox(height: 20),
                                  _sectionTitle('Destinataire'),
                                  _buildValidatedTextField(controller: controllerAdresseDestinateur, label: 'Adresse', icon: Icons.location_on, type: TextInputType.text),
                                  SizedBox(height: 20),
                                  if (!isLoadingClient)
                                    buildSearchableComboBox(
                                      id_client_encours: roleUser.id.toString(),
                                      controller: controllerNomDestinateur,
                                      label: "Client destinataire",
                                      options: clients,
                                      onChanged: (String? id, String? nom) {
                                        setState(() {
                                          print(nom);
                                          id_client = id ?? null;
                                          selectedValueName = nom ?? "";
                                        });
                                      },
                                    )
                                  else
                                    Center(child: CircularProgressIndicator()),
                                  SizedBox(height: 20),
                                  _buildValidatedTextField(controller: controllerNumeroDestinateur, label: 'Numéro téléphone', icon: Icons.phone, type: TextInputType.phone),
                                  SizedBox(height: 40),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          _livraisonController.storeLivraison(
                                            roleUser.id.toString(),
                                            id_client,
                                            selectedValueName,
                                            controllerAdresseExpediteur.text,
                                            controllerAdresseDestinateur.text,
                                            controllerNumeroDestinateur.text,
                                            controllerNumeroExpediteur.text,
                                            widget.recaPoid[1],
                                            context,
                                              currentPosition.longitude.toString(),
                                            currentPosition.latitude.toString(),
                                            "34343444",
                                            "666e6r6r6"
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
              ),



            ],
          )

      ,
    );
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
  required String id_client_encours,
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
          client["id"] != id_client_encours &&
              client["nom"]!.toLowerCase().contains(textEditingValue.text.toLowerCase()));
        },
        displayStringForOption: (option) => '${option["nom"]} (${option["email"]})',
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          return TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le champ "$label" est requis';
              }
              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: label,
            ),
            onChanged: (text) {
              onChanged(null, text);
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
