import 'dart:async';

import 'package:flutter/material.dart';
import 'package:menji/controller/LivraisonController.dart';
import 'package:menji/view/client/pageAccueille.dart';
import '../../compenent/AppBarCostum.dart';
import '../../controller/ClientController.dart';
import '../../controller/authController.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class PageCommander extends StatefulWidget {
  final String nom_type;

  PageCommander(this.nom_type);
  @override
  _PageCommanderState createState() => _PageCommanderState();
}

class _PageCommanderState extends State<PageCommander> {
  LatLng? currentPosition;
  final MapController _mapController = MapController();
  Set<Marker> _markers = {};
  bool _isLoading = true;
  double _zoomLevel = 17.0;
  bool isCliqued = false;
  bool testEnvoiColis = false;

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Polyline? routePolyline;

  final _formKey = GlobalKey<FormState>();
  final LivraisonController _livraisonController = LivraisonController();
  final ClientController _clientController = ClientController();

  List<Map<String, String>> clients = [];
  bool isLoadingClient = true;

  String selectedValueName = '';
  dynamic id_client = null;
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
        _mapController.move(currentPosition!, _zoomLevel);
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
      appBar: AppBarCostum(context:context,libelle:"Commander").run(),
      body: Stack(
        children: [
          (currentPosition != null)
              ? FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition!,
              initialZoom: _zoomLevel,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
                tileBuilder: (context, widget, tile) {
                  return ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
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
                          const Icon(Icons.location_on, color: Colors.red, size: 60),
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
          )
              : Center(child: CircularProgressIndicator()),
          Positioned(
            right: 15,
            bottom: 520,
            child: FloatingActionButton(
              mini: true,
              heroTag: 'location',
              onPressed: _determinePosition,
              child: const Icon(Icons.my_location),
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
                  child: const Icon(Icons.add),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoomOut',
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
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
                  height: 180,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/map_image.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.5,
                    minChildSize: 0.3,
                    maxChildSize: 1.0,
                    builder: (BuildContext context, ScrollController scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(35),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Expéditeur
                              Row(
                                children: [
                                  Text(
                                    'Expéditeur',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Image.asset(
                                    "images/Icone_exp.png",
                                    width: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildCompactTextField(
                                controller: controllerAdresseExpediteur,
                                hintText: 'Adresse',
                              ),
                              const SizedBox(height: 8),
                              _buildCompactTextField(
                                controller: controllerNumeroExpediteur,
                                hintText: 'Numéro téléphone',
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),

                              // Section Destinataire
                              Row(
                                children: [
                                  Text(
                                    'Destinataire',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Image.asset(
                                    "images/Icone_exp.png",
                                    width: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (!isLoadingClient)
                                _buildCompactClientComboBox(
                                  id_client_encours: roleUser.id.toString(),
                                  controller: controllerNomDestinateur,
                                  onChanged: (String? id, String? nom) {
                                    setState(() {
                                      id_client = id ?? null;
                                      selectedValueName = nom ?? "";
                                    });
                                  },
                                  options: clients,
                                )
                              else
                                const Center(child: CircularProgressIndicator()),
                              const SizedBox(height: 8),
                              _buildCompactTextField(
                                controller: controllerAdresseDestinateur,
                                hintText: 'Adresse',
                              ),
                              const SizedBox(height: 8),

                              const SizedBox(height: 8),
                              _buildCompactTextField(
                                controller: controllerNumeroDestinateur,
                                hintText: 'Numéro téléphone',
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        isCliqued = true;
                                      });

                                      try {

                                        await _livraisonController.store(
                                          roleUser.id.toString(),
                                          id_client,
                                          selectedValueName,
                                          controllerAdresseExpediteur.text,
                                          controllerAdresseDestinateur.text,
                                          controllerNumeroDestinateur.text,
                                          controllerNumeroExpediteur.text,
                                          widget.nom_type,
                                          context,
                                          currentPosition!.longitude.toString()?? "",
                                          currentPosition!.latitude.toString()?? "",
                                          "444",
                                          "555",
                                        );

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => PageAccueil()),
                                        );

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("La livraison a été ajoutée avec succès !")),
                                        );
                                      } catch (e) {
                                        if (e.toString().contains('SocketException')) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Aucune connexion Internet. Vérifiez votre réseau."))
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Une erreur inattendue est survenue."))
                                          );
                                        }
                                      } finally {
                                        setState(() {
                                          isCliqued = false;
                                        });
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires")),
                                      );
                                    }
                                  },
                                  child: isCliqued == true
                                      ? Text("Chargement en cours...")
                                      : const Text(
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: "Segoe UI",
                                      ),
                                      'Commander'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: InputBorder.none,
          isDense: true,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Ce champ est requis';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCompactClientComboBox({
    required String id_client_encours,
    required TextEditingController controller,
    required Function(String?, String?) onChanged,
    required List<Map<String, String>> options,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Autocomplete<Map<String, String>>(
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
            decoration: InputDecoration(
              hintText: 'Nom',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: InputBorder.none,
              isDense: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            },
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
    );
  }
}