import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class SignalementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignalementPage(),
    );
  }
}

class SignalementPage extends StatefulWidget {
  @override
  _SignalementPageState createState() => _SignalementPageState();
}

class _SignalementPageState extends State<SignalementPage> {
  LatLng? currentPosition;
  final MapController _mapController = MapController();
  Set<Marker> _markers = {};
  bool _isLoading = true;
  double _zoomLevel = 17.0;

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Polyline? routePolyline;
  LatLng destination = LatLng(-4.322447, 15.307045); // Palais du Peuple, Kinshasa

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Appel direct de la localisation au démarrage
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
      print('Longitude: ${position.longitude}');
      print('Altitude: ${position.altitude}');
      print('Précision: ${position.accuracy}m');
      print('========================');

      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      if (currentPosition != null) {
        _mapController.move(currentPosition!, _zoomLevel);
        await getOSRMRoute(); //Appel de la route une fois la position obtenue
      }
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

  void _drawStraightLine() {
    setState(() {
      polylineCoordinates = [currentPosition!, destination];
      routePolyline = Polyline(
        points: polylineCoordinates,
        strokeWidth: 2,
        color: Colors.orange,
      );
    });
  }

  Future<void> getOSRMRoute() async {
    if (currentPosition == null) {
      print("Position actuelle non disponible");
      _drawStraightLine(); // Tracer une ligne droite si pas de position
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/'
              '${currentPosition!.longitude},${currentPosition!.latitude};'
              '${destination.longitude},${destination.latitude}?'
              'overview=full&geometries=geojson'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['routes'][0]['geometry']['coordinates'] as List;

        setState(() {
          polylineCoordinates = geometry
              .map((coord) => LatLng(coord[1] as double, coord[0] as double))
              .toList();

          routePolyline = Polyline(
            points: polylineCoordinates,
            strokeWidth: 4,
            color: Colors.blue, // Couleur orange
          );
        });
      } else {
        print("Erreur OSRM: ${response.statusCode}");
        _drawStraightLine(); // Tracer une ligne droite en cas d'erreur
      }
    } catch (e) {
      print('Erreur OSRM: $e');
      _drawStraightLine(); // Tracer une ligne droite en cas d'exception
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1136),
      body: Stack(
        children: [
          if (_isLoading)
            Center(child: CircularProgressIndicator()),

          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: destination, // Centré sur le Palais du Peuple par défaut
              initialZoom: _zoomLevel,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (routePolyline != null)
                PolylineLayer(polylines: [routePolyline!]),
              MarkerLayer(
                markers: [
                  if (currentPosition != null)
                    Marker(
                      point: currentPosition!,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                    ),
                  Marker(
                    point: destination,
                    width: 40,
                    height: 40,
                    child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),

          // Bouton de localisation
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

          // Bouton de rafraîchissement de l'itinéraire
          Positioned(
            right: 15,
            bottom: 460,
            child: FloatingActionButton(
              mini: true,
              heroTag: 'refresh',
              onPressed: getOSRMRoute,
              child: Icon(Icons.refresh),
              backgroundColor: Colors.white,
            ),
          ),

          // Boutons de zoom
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

          // Bloc draggable
          Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: 0,
              right: 0,
              bottom: 0,
              child: DraggableScrollableSheet(
                snap: true,
                initialChildSize: 0.5,
                minChildSize: 0.3,
                maxChildSize: 1.0,
                builder: (BuildContext context, ScrollController scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: Offset(0, -5),
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
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2)),
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
                              label: 'Entrez l\'adresse ou utilisez maps',
                              hintText: 'Expéditeur',
                              icon: Icons.person,
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
                              label: 'Entrez l\'adresse ou utilisez maps',
                              hintText: 'Destinataire',
                              icon: Icons.location_on,
                            ),
                            SizedBox(height: 20),
                            _buildTextField(
                              label: 'Entrez votre nom',
                              hintText: 'Nom complet',
                              icon: Icons.person,
                            ),
                            SizedBox(height: 20),
                            _buildTextField(
                              label: 'Entrez votre numéro de téléphone',
                              hintText: 'Téléphone',
                              icon: Icons.phone,
                            ),
                            SizedBox(height: 40),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  _showAlertDialog(context);
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
              )
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String hintText, required IconData icon}) {
    return Row(
      children: [
        Expanded(
          child: TextField(
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
                child: Text("OK", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}