import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;


class LocalisationclientPage extends StatefulWidget {
  LatLng? positionClient;
  LocalisationclientPage(this.positionClient);
  @override
  _LocalisationclientPageState createState() => _LocalisationclientPageState(this.positionClient);
}

class _LocalisationclientPageState extends State<LocalisationclientPage> {
  LatLng? positionClient= LatLng(-4.322447, 15.307045);
  LatLng currentPosition =LatLng(-4.322447, 15.307045);
  final MapController _mapController = MapController();
  Set<Marker> _markers = {};
  bool _isLoading = true;
  double _zoomLevel = 17.0;

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Polyline? routePolyline;
  LatLng destination = LatLng(-4.322447, 15.307045); // Palais du Peuple, Kinshasa

  String _durationText = '19 mins'; // Valeur initiale
  String _currentLocationName = 'MY HOME'; // Comme sur votre capture
  String _destinationName = 'MES COLLEAGUE'; // Comme sur votre capture


  _LocalisationclientPageState(this.positionClient);
  @override
  void initState() {
    super.initState();
    currentPosition=this.positionClient!; // Appel direct de la localisation au démarrage
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
        currentPosition = this.positionClient!;
        _isLoading = false;
      });

      if (currentPosition != null) {
        _mapController.move(this.positionClient!, _zoomLevel);
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
        color: Colors.blue, // Changé de orange à gris
      );
    });
  }

  Future<void> getOSRMRoute() async {
    if (currentPosition == null) {
      print("Position actuelles non disponible");
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
        final durationInSeconds = data['routes'][0]['duration'] as double;
        setState(() {
          _durationText = '${(durationInSeconds / 60).round()} min';
        });
      }

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
            color: Colors.blue, // Changé de bleu à gris
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
      appBar: AppBar(
        title: Text('Localisation client'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition, // Centré sur le Palais du Peuple par défaut
              initialZoom: _zoomLevel,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
                // Ajout d'un filtre pour désaturer les couleurs
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
              if (routePolyline != null)
                PolylineLayer(polylines: [routePolyline!]),
              MarkerLayer(
                markers: [
                  if (currentPosition != null)
                    Marker(
                      point: currentPosition!,
                      width: 60, // Augmenté de 40 à 60
                      height: 60, // Augmenté de 40 à 60
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 60), // Augmenté de 40 à 60
                          Positioned(
                            top: 15, // Ajusté pour le nouveau size
                            child: Container(
                              width: 16, // Légèrement augmenté
                              height: 16, // Légèrement augmenté
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
                          // Point bleu en bas de la position actuelle
                          Positioned(
                            bottom: 0, // Positionné en bas
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
                    ),
                  //
                  //
                  Marker(
                    point: currentPosition!,
                    width: 150, // Largeur suffisante pour les deux éléments
                    height: 250,
                    child: Stack(
                      children: [
                        // Position du cercle bleu avec le temps (19 min)
                        Positioned(
                          left: 0,
                          child: Container(
                            width: 80,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue,
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _durationText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),


                  //
                  //
                  Marker(
                    point: destination,
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
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