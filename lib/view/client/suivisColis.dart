import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import '../../controller/LivraisonController.dart';


class SuivisColis extends StatefulWidget {

  late String id;
  SuivisColis(this.id);

  @override
  _MapState createState() => _MapState(id);
}



class _MapState extends State<SuivisColis> {
  late String id;
  LivraisonController _livraisonController=LivraisonController();
  LatLng? currentPosition;
  late  Map<String,dynamic> localisation;
  final MapController _mapController = MapController();
  Set<Marker> _markers = {};
  bool _isLoading = true;
  double _zoomLevel = 17.0;
  StreamSubscription<Position>? _positionStreamSubscription;
  LatLng? _lastPosition;
  bool _firstPositionReceived = false;

  bool _lacalisation = false;

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Polyline? routePolyline;


  LatLng mydestination = LatLng(-4.322447, 15.307045);// Palais du Peuple, Kinshasa

  String _durationText = 'Calcul en cours...';
  String _currentLocationName = 'Position actuelle';
  String _destinationName = 'Palais du Peuple';

  _MapState(this.id);


  // les etats
  Future<void> _startPositionStream() async {
    final settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 1, // déclenchement quand la position change de ≥ 1 m
    );

    _positionStreamSubscription = Geolocator
        .getPositionStream(locationSettings: settings)
        .listen((position) {
      final newPos = LatLng(position.latitude, position.longitude);
      print('Position mise à jour: $newPos');

      setState(() {
        currentPosition = newPos;
      });

      _updateMarkers();
      _mapController.move(newPos, _zoomLevel);

      getOSRMRoute(); // ou fetchRouteORS()
    });
  }

  Future<void> _initialisationLivraison() async {

    await _livraisonController.init();
    localisation= await _livraisonController.getLocalisation(id);
    mydestination=LatLng(localisation["latitude"],localisation["longitude"]);

    setState(() {
      _lacalisation=true;
    });


  }

  Future<void>  inis()async{

    await _initialisationLivraison();
    await _checkPermissionsAndStartTracking();

  }
  @override
  void initState() {
    super.initState();
    inis().then((_) {
      _startPositionStream(); // ✅ lance le suivi GPS après l'initialisation
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

      Position position =  await Geolocator.getCurrentPosition();
      print('Position actuelle obtenue: ttt');
      final newPosition = LatLng(position.latitude, position.longitude);

      print([position.latitude, position.longitude]);

        currentPosition = newPosition;
        _isLoading = false;
        //_mapController.move(newPosition, _zoomLevel);

        print("hhhhhhhhh----");

      _updateMarkers();
      getOSRMRoute();


      //_startPositionStream();

    } catch (e) {
      print('Erreur lors de la vérification des permissions: $e');
      setState(() => _isLoading = false);
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

      Position position =  await Geolocator.getCurrentPosition();

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
    print("marker");
    print([currentPosition!.latitude,currentPosition!.longitude]);
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
          point: mydestination,
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
      polylineCoordinates = [currentPosition!, mydestination];
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

      return;
    }

    try {
      print([currentPosition!.latitude, currentPosition!.longitude]);
      print([mydestination.latitude, mydestination.longitude]);

      // 1. Construction de l'URI avec ta clé ORS
      const orsKey = '5b3ce3597851110001cf62486df9e0bde943474d815baa10e9dfab92';
      final uri = Uri.https(
        'api.openrouteservice.org',
        '/v2/directions/driving-car',
        {
          'api_key': orsKey,
          'start': '${currentPosition!.longitude},${currentPosition!.latitude}',
          'end': '${mydestination.longitude},${mydestination.latitude}',
        },
      );

      // 2. Appel HTTP avec timeout/fallback
      final resp = await http
          .get(uri)
          .timeout(
        const Duration(seconds: 20),
        onTimeout: () => http.Response('{"features":[]}', 504),
      );

      print("ORS RESPONSE STATUS: ${resp.statusCode}");

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);

        // 3. Extraire les coordonnées
        final coords = (data['features'][0]['geometry']['coordinates'] as List)
            .cast<List<dynamic>>()
            .map((c) => LatLng(c[1] as double, c[0] as double))
            .toList();

        // 4. Extraire la durée (elle est un double, pas un String)
        final seconds = (data['features'][0]['properties']['segments'][0]['duration'] as num).toDouble();

        setState(() {
          polylineCoordinates = coords;
          routePolyline = Polyline(points: coords, strokeWidth: 4, color: Colors.blue);
          _durationText = '${(seconds ~/ 60)} min';
          _isLoading = true;

          // 5. Centrer et zoomer la carte sur l'itinéraire

        });
      } else if (resp.statusCode == 504) {

      } else {

      }
    } catch (e) {
      print('Erreur réseau ORS : $e');
    }


  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text('Suivre mon colis'),
          iconTheme: IconThemeData(color: Colors.orange),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.orange),
              onPressed: () {},
            ),
          ],
        ),
      backgroundColor: const Color(0xFF0D1136),
      body: Stack(
        children: [

          FlutterMap(
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
          _lacalisation==false?
          Center(child: CircularProgressIndicator()):
              Center(child: Text(""),)

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