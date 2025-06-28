import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../compenent/AppBarCostum.dart';
import '../../controller/LivraisonController.dart';

class SuivisColis extends StatefulWidget {
  final String id;
  final String nom_livreur;
  final String numero_livreur;
  final String nom_type_livreur;
  final String immatriculation_livreur;

  const SuivisColis(
      this.id,
      this.nom_livreur,
      this.numero_livreur,
      this.nom_type_livreur,
      this.immatriculation_livreur,
      {Key? key})
      : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<SuivisColis> {
  final LivraisonController _livraisonController = LivraisonController();
  final MapController _mapController = MapController();

  LatLng? currentPosition;
  LatLng? mydestination;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  double _zoomLevel = 17.0;
  bool _userMovedMap = false;
  bool _localisationReady = false;
  bool _showLivreurInfo = true; // Affiché par défaut

  List<LatLng> polylineCoordinates = [];
  Polyline? routePolyline;

  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    await _initDestination();
    await _checkPermissionsAndStartTracking();
    _startDestinationUpdateTimer();
  }

  Future<void> _initDestination() async {
    await _livraisonController.init();
    final localisation = await _livraisonController.getLocalisation(widget.id);
    setState(() {
      mydestination = LatLng(localisation["latitude"], localisation["longitude"]);
      _localisationReady = true;
    });
  }

  void _startDestinationUpdateTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _initDestination();
      _updateMarkers();
      _getOSRMRoute();
    });
  }

  Future<void> _checkPermissionsAndStartTracking() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showToast("Activez les services de localisation");
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      _showToast("Permission de localisation refusée");
      setState(() => _isLoading = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    currentPosition = LatLng(position.latitude, position.longitude);
    _updateMarkers();
    _getOSRMRoute();
    _startPositionStream();

    setState(() {
      _isLoading = false;
      _showLivreurInfo = true; // S’assurer que le bloc est visible au démarrage
    });
  }

  void _startPositionStream() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    ).listen((position) {
     // currentPosition = LatLng(position.latitude, position.longitude);
      //if (!_userMovedMap) _mapController.move(currentPosition!, _zoomLevel);
      _updateMarkers();
      _getOSRMRoute();
    });
  }

  void _updateMarkers() {
    setState(() {
      _markers = {
        if (currentPosition != null)
          Marker(
            point: currentPosition!,
            width: 60,
            height: 60,
            child: const Icon(Icons.location_on, color: Colors.red, size: 60),
          ),
        if (mydestination != null)
          Marker(
            point: mydestination!,
            width: 30,
            height: 30,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showLivreurInfo = !_showLivreurInfo;
                });
              },
              child: const Icon(Icons.person, color: Colors.blue, size: 30),
            ),
          ),
      };
    });
  }

  Future<void> _getOSRMRoute() async {
    if (currentPosition == null || mydestination == null) return;

    final uri = Uri.https(
      'api.openrouteservice.org',
      '/v2/directions/driving-car',
      {
        'api_key': '5b3ce3597851110001cf62486c4ca0b38dfb97685ac039e8d0096b8b461e4defe6a093bedfd5c9a3',
        'start': '${currentPosition!.longitude},${currentPosition!.latitude}',
        'end': '${mydestination!.longitude},${mydestination!.latitude}',
      },
    );

    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 20));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final coords = (data['features'][0]['geometry']['coordinates'] as List)
            .map((c) => LatLng(c[1], c[0]))
            .toList();
        setState(() {
          polylineCoordinates = coords;
          routePolyline = Polyline(points: coords, strokeWidth: 4, color: Colors.blue);
        });
      }
    } catch (e) {
      print('Erreur ORS : $e');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCostum(context: context, libelle: "Suivis colis").run(),
      body: Stack(
        children: [
          if (currentPosition == null || !_localisationReady)
            const Center(child: CircularProgressIndicator())
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: currentPosition!,
                initialZoom: _zoomLevel,
                onPositionChanged: (pos, hasGesture) {
                  if (hasGesture) _userMovedMap = true;
                },
                onTap: (_, __) {
                  setState(() {
                    _showLivreurInfo = !_showLivreurInfo;
                  });
                },
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
                if (routePolyline != null)
                  PolylineLayer(polylines: [routePolyline!]),
                MarkerLayer(markers: _markers.toList()),
              ],
            ),
          Positioned(
            right: 15,
            bottom: 520,
            child: FloatingActionButton(
              mini: true,
              heroTag: 'location',
              onPressed: () {
                if (currentPosition != null) {
                  _mapController.move(currentPosition!, _zoomLevel);
                }
              },
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
                  onPressed: () => setState(() => _zoomLevel++),
                  child: const Icon(Icons.add),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoomOut',
                  onPressed: () => setState(() => _zoomLevel--),
                  child: const Icon(Icons.remove),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
          if (_showLivreurInfo)
            blockArrive(
              context,
              widget.nom_livreur,
              widget.numero_livreur,
              widget.nom_type_livreur,
              widget.immatriculation_livreur,
            ),
        ],
      ),
    );
  }
}

Widget blockArrive(BuildContext context, String nom, String numero, String typeVehicule, String immatriculation) {
  return Positioned(
    bottom: MediaQuery.of(context).size.height * 0.1,
    left: 0,
    right: 0,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_circle, color: Colors.orange, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  nom,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.message, color: Colors.orange),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.phone, color: Colors.orange),
                onPressed: () => _callPhoneNumber(numero),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("$typeVehicule - $immatriculation", style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 10),
          Text(numero, style: const TextStyle(fontSize: 16, color: Colors.red)),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF494949),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {},
              child: const Text('Fin course', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _callPhoneNumber(String phoneNumber) async {
  final Uri url = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Impossible d\'ouvrir le téléphone pour appeler $phoneNumber';
  }
}
