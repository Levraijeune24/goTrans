import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:menji/controller/LivraisonController.dart';
import 'package:menji/view/client/pageAccueille.dart';
import '../../compenent/AppBarCostum.dart';
import '../../controller/ClientController.dart';
import '../../controller/authController.dart';

class PageCommander extends StatefulWidget {
  final String nom_type;

  const PageCommander(this.nom_type, {super.key});

  @override
  State<PageCommander> createState() => _PageCommanderState();
}

class _PageCommanderState extends State<PageCommander> {
  LatLng? currentPosition;
  final MapController _mapController = MapController();
  double _zoomLevel = 17.0;
  bool isCliqued = false;
  bool isLoadingClient = true;

  final _formKey = GlobalKey<FormState>();
  final LivraisonController _livraisonController = LivraisonController();
  final ClientController _clientController = ClientController();

  List<Map<String, String>> clients = [];
  String selectedValueName = '';
  dynamic id_client;
  dynamic roleUser;

  final controllerAdresseExpediteur = TextEditingController();
  final controllerAdresseDestinateur = TextEditingController();
  final controllerNumeroDestinateur = TextEditingController();
  final controllerNomDestinateur = TextEditingController();
  final controllerNumeroExpediteur = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _livraisonController.init();
    await _clientController.init();
    roleUser = await AuthController().getRole();
    clients = await _clientController.getClient();
    await _determinePosition();
    setState(() => isLoadingClient = false);
  }

  Future<void> _determinePosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(currentPosition!, _zoomLevel);
      });
    } catch (e) {
      debugPrint('Erreur position: $e');
    }
  }

  void _zoom(bool zoomIn) {
    setState(() {
      _zoomLevel += zoomIn ? 1 : -1;
      _mapController.move(_mapController.camera.center, _zoomLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBarCostum(context: context, libelle: "Commander").run(),
      body: Stack(
        children: [
          currentPosition != null
              ? FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition!,
              initialZoom: _zoomLevel,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                  Marker(
                    point: currentPosition!,
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.location_on,
                        color: Colors.red, size: 60),
                  )
                ],
              )
            ],
          )
              : const Center(child: CircularProgressIndicator()),
          _buildFloatingButtons(),
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
                Expanded(child: _buildDraggableForm())
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons() => Positioned(
    right: 15,
    bottom: 400,
    child: Column(
      children: [
        FloatingActionButton(
          mini: true,
          onPressed: () => _zoom(true),
          child: const Icon(Icons.add),
          backgroundColor: Colors.white,
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          mini: true,
          onPressed: () => _zoom(false),
          child: const Icon(Icons.remove),
          backgroundColor: Colors.white,
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          mini: true,
          onPressed: _determinePosition,
          child: const Icon(Icons.my_location),
          backgroundColor: Colors.white,
        ),
      ],
    ),
  );

  Widget _buildDraggableForm() => DraggableScrollableSheet(
    initialChildSize: 0.5,
    minChildSize: 0.3,
    maxChildSize: 1.0,
    builder: (context, scrollController) => Container(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Expéditeur'),
            _buildCompactTextField(controllerAdresseExpediteur, 'Adresse'),
            const SizedBox(height: 8),
            _buildCompactTextField(controllerNumeroExpediteur, 'Numéro téléphone',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildSectionTitle('Destinataire'),
            isLoadingClient
                ? const Center(child: CircularProgressIndicator())
                : _buildClientComboBox(),
            const SizedBox(height: 8),
            _buildCompactTextField(controllerAdresseDestinateur, 'Adresse'),
            const SizedBox(height: 8),
            _buildCompactTextField(controllerNumeroDestinateur, 'Numéro téléphone',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isCliqued ? "Chargement..." : 'Commander',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: "Segoe UI",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildSectionTitle(String title) => Row(
    children: [
      Text(title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(width: 8),
      Image.asset("images/Icone_exp.png", width: 20),
    ],
  );

  Widget _buildCompactTextField(TextEditingController controller, String hintText,
      {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
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
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: InputBorder.none,
          isDense: true,
        ),
        validator: (value) =>
        (value == null || value.trim().isEmpty) ? 'Ce champ est requis' : null,
      ),
    );
  }

  Widget _buildClientComboBox() => _buildCompactClientComboBox(
    id_client_encours: roleUser.id.toString(),
    controller: controllerNomDestinateur,
    onChanged: (id, nom) {
      setState(() {
        id_client = id;
        selectedValueName = nom ?? "";
      });
    },
    options: clients,
  );

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
        optionsBuilder: (text) {
          return text.text.isEmpty
              ? const Iterable<Map<String, String>>.empty()
              : options.where((client) =>
          client["id"] != id_client_encours &&
              client["nom"]!
                  .toLowerCase()
                  .contains(text.text.toLowerCase()));
        },
        displayStringForOption: (option) =>
        '${option["nom"]} (${option["email"]})',
        fieldViewBuilder: (context, textEditingController, focusNode, _) {
          return TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: const InputDecoration(
              hintText: 'Nom',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: InputBorder.none,
              isDense: true,
            ),
            validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'Ce champ est requis' : null,
            onChanged: (text) => onChanged(null, text),
          );
        },
        onSelected: (selection) {
          controller.text = selection["nom"]!;
          onChanged(selection["id"], selection["nom"]);
        },
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez remplir tous les champs.")));
      return;
    }

    setState(() => isCliqued = true);
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
        currentPosition?.longitude.toString() ?? "",
        currentPosition?.latitude.toString() ?? "",
        "",
        "",
      );

      if (!mounted) return;
      Navigator.push(
          context, MaterialPageRoute(builder: (_) =>  PageAccueil()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("La livraison a été ajoutée avec succès !")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().contains('SocketException')
              ? "Aucune connexion Internet."
              : "Une erreur inattendue est survenue.")));
    } finally {
      setState(() => isCliqued = false);
    }
  }
}
