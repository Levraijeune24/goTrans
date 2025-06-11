import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';





class SignalementPagesf extends StatefulWidget {
  @override
  _SignalementPagesfState createState() => _SignalementPagesfState();
}

class _SignalementPagesfState extends State<SignalementPagesf> {
  LatLng? currentPosition;
  final MapController _mapController = MapController();
  Set<Marker> _markers = {};
  bool _isLoading = true;
  double _zoomLevel = 17.0;
  StreamSubscription<Position>? _positionStreamSubscription;
  LatLng? _lastPosition;
  bool _firstPositionReceived = false;

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Polyline? routePolyline;
  LatLng destination = LatLng(-4.322447, 15.307045); // Palais du Peuple, Kinshasa

  String _durationText = 'Calcul en cours...';
  String _currentLocationName = 'Position actuelle';
  String _destinationName = 'Palais du Peuple';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsAndStartTracking();
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissionsAndStartTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Les services de localisation sont désactivés');
        _showToast("Activez les services de localisation");
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showToast("Permission de localisation refusée");
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showToast("Permission de localisation définitivement refusée. Activez-la dans les paramètres");
        setState(() => _isLoading = false);
        return;
      }

      // Tout est bon, démarrer le tracking
      _determinePosition();
      _startPositionStream();

    } catch (e) {
      print('Erreur lors de la vérification des permissions: $e');
      setState(() => _isLoading = false);
    }
  }

  void _startPositionStream() async {
    print('Démarrage du stream de position avec une sensibilité de 1 mètre...');

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation, // Meilleure précision
      distanceFilter: 1, // Détection à partir de 1 mètre de déplacement
    );

    _positionStreamSubscription?.cancel(); // Annuler tout abonnement existant

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
          (Position position) {
        print('Nouvelle position reçue: ${position.latitude}, ${position.longitude}');
        _handleNewPosition(position);
      },
      onError: (error) {
        print('Erreur dans le stream de position: $error');
        if (error is LocationServiceDisabledException) {
          _showToast("Les services de localisation ont été désactivés");
        } else {
          _showToast("Erreur de localisation: ${error.toString()}");
        }
      },
      cancelOnError: false, // Ne pas annuler le stream en cas d'erreur
    );
  }


  void _handleNewPosition(Position position) {
    final newPosition = LatLng(position.latitude, position.longitude);
    final now = DateTime.now();

    print('Nouvelle position à ${now.hour}:${now.minute}:${now.second}');

    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );

      print('Distance depuis dernière position: ${distance.toStringAsFixed(2)} mètres');

      // Seulement mettre à jour si le déplacement est significatif
      if (distance >= 2) { // Utilisation de >= au lieu de >
        _showMovementToast(distance, newPosition);
        _updateMapPosition(newPosition);
        _lastPosition = newPosition; // Mettre à jour _lastPosition seulement après un déplacement significatif
      }
    } else {
      // Cas initial - première position
      _updateMapPosition(newPosition);
      _lastPosition = newPosition;
    }

    if (!_firstPositionReceived) {
      _firstPositionReceived = true;
      _updateMapPosition(newPosition);
    }
  }

  void _updateMapPosition(LatLng newPosition) {
    setState(() {
      currentPosition = newPosition;
      _isLoading = false;
    });

    _mapController.move(newPosition, _zoomLevel);
    _updateMarkers();
    getOSRMRoute();
  }

  void _showMovementToast(double distance, LatLng newPosition) {
    // Vérifier à nouveau la distance par sécurité
    if (distance >= 2) {
      Fluttertoast.showToast(
        msg: "Déplacement: ${distance.toStringAsFixed(2)} m\n"
            "Lat: ${newPosition.latitude.toStringAsFixed(6)}\n"
            "Lng: ${newPosition.longitude.toStringAsFixed(6)}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
    );
  }

  Future<void> _determinePosition() async {
    try {
      setState(() => _isLoading = true);

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(Duration(seconds: 5));

      print('Position actuelle obtenue: ${position.latitude}, ${position.longitude}');

      final newPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        currentPosition = newPosition;
        _isLoading = false;
      });

      // Force le repositionnement de la carte
      _mapController.move(newPosition, _zoomLevel);
      _updateMarkers();
      getOSRMRoute();

    } on TimeoutException {
      print('Timeout lors de la récupération de la position');
      _showToast("Timeout - Vérifiez votre connexion GPS");
      setState(() => _isLoading = false);
      _drawStraightLine();
    } catch (e) {
      print('Erreur lors de la récupération de la position: $e');
      _showToast("Erreur de localisation");
      setState(() => _isLoading = false);
      _drawStraightLine();
    }
  }

  void _updateMarkers() {
    setState(() {
      _markers = {
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
          ),
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
      };
    });
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
    if (currentPosition == null) return;

    setState(() {
      polylineCoordinates = [currentPosition!, destination];
      routePolyline = Polyline(
        points: polylineCoordinates,
        strokeWidth: 2,
        color: Colors.blue,
      );
    });
  }

  Future<void> getOSRMRoute() async {
    if (currentPosition == null) {
      print("Position actuelle non disponible");
      _drawStraightLine();
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
        final durationInSeconds = data['routes'][0]['duration'] as double;

        setState(() {
          _durationText = '${(durationInSeconds / 60).round()} min';
          polylineCoordinates = geometry
              .map((coord) => LatLng(coord[1] as double, coord[0] as double))
              .toList();

          routePolyline = Polyline(
            points: polylineCoordinates,
            strokeWidth: 4,
            color: Colors.blue,
          );
        });
      } else {
        print("Erreur OSRM: ${response.statusCode}");
        _drawStraightLine();
      }
    } catch (e) {
      print('Erreur OSRM: $e');
      _drawStraightLine();
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
              initialCenter: destination,
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
                } else {
                  _determinePosition();
                }
              },
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