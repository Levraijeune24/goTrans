import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../compenent/AppBarCostum.dart';
import '../../controller/LivraisonController.dart';


class SuivisColis extends StatefulWidget {

  String nom_livreur,numero_livreur,nom_type_livreur,immatriculation_livreur;

  // "nom_livreur":data['vehicule']?['livreurs']?[0]?['livreur']?['user']?['name'],
  // "numero_livreur":data['vehicule']?['livreurs']?[0]?['livreur']?['user']?['number_phone'],
  // "nom_type_livreur":data['vehicule']?['type_vehicule']?['nom_type'],
  // "immatriculation_livreur":data['vehicule']?['immatriculation'],

  late String id;
  SuivisColis(this.id,this.nom_livreur,this.numero_livreur,this.nom_type_livreur,this.immatriculation_livreur);

  @override
  _MapState createState() => _MapState(id,

      this.nom_livreur,this.numero_livreur,this.nom_type_livreur,this.immatriculation_livreur);
}


class _MapState extends State<SuivisColis> {

  String nom_livreur,numero_livreur,nom_type_livreur,immatriculation_livreur;


  late String id;
  LivraisonController _livraisonController=LivraisonController();
  LatLng? currentPosition;
  late  Map<String,dynamic> localisation;
  final MapController _mapController = MapController();
  Set<Marker> _markers = {};
  bool _isLoading = true;
  double _zoomLevel = 17.0;
  StreamSubscription<Position>? _positionStreamSubscription;

  bool _userMovedMap = false;

  bool _lacalisation = false;

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Polyline? routePolyline;

  LatLng mydestination = LatLng(-4.322447, 15.307045);// Palais du Peuple, Kinshasa

  // String _durationText = 'Calcul en cours...';
  // String _currentLocationName = 'Position actuelle';
  // String _destinationName = 'Palais du Peuple';

  _MapState(this.id,this.nom_livreur,
      this.numero_livreur,this.nom_type_livreur,
      this.immatriculation_livreur
      );


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

      if (!_userMovedMap) {
        _mapController.move(newPos, _zoomLevel); // Ne recentre que si l'utilisateur n’a pas déplacé la carte
      }

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


  Future<void> appelTempReel() async {

    Timer.periodic(Duration(seconds: 10), (timer) async {
      await _initialisationLivraison();
      if (mounted) {
        setState(() {
          mydestination = LatLng(localisation["latitude"], localisation["longitude"]);
        });

        _updateMarkers();
        getOSRMRoute(); // Recalculer l'itinéraire
      }
    });
  }


  Future<void>  ini()async{

    await _initialisationLivraison();
    await _checkPermissionsAndStartTracking();

  }
  @override
  void initState() {
    super.initState();

    ini().then((_) {
      _startPositionStream();
      appelTempReel(); // Démarrer la mise à jour régulière
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

        currentPosition = newPosition;
        _isLoading = false;

        _updateMarkers();
        getOSRMRoute();


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


  // detemination de ma position actuelle
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


  //modification du marker
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
         var  _durationText = '${(seconds ~/ 60)} min';
          _isLoading = true;

        });
      } else if (resp.statusCode == 504) {
        _showToast("Erreur de récupération d'itinéraire (${resp.statusCode})");
      } else {
      }
    } catch (e) {
      print('Erreur réseau ORS : $e');
    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBarCostum(context:context,libelle:"Suivis colis").run(),
        body: Stack(
        children: [

          (currentPosition == null || !_lacalisation) ?
            Center(child: CircularProgressIndicator()):
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition!,
              initialZoom: _zoomLevel,
                onPositionChanged: ( position, bool hasGesture) {
                  if (hasGesture) {
                    _userMovedMap = true;
                  }
                }
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
          blockArrive(context,nom_livreur,numero_livreur,
              nom_type_livreur,immatriculation_livreur),
          _lacalisation==false?
          Center(child: CircularProgressIndicator()):
              Center(child: Text(""),)

        ],
      ),
    );
  }

}


Widget blockArrive(BuildContext context,String nom,String numero,String type_vehicule, String immatriculation) {
  return Positioned(
    bottom: MediaQuery.of(context).size.height * 0.1, // Position en bas
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
          // Ligne du nom avec icônes
          Row(
            children: [
              const Icon(Icons.account_circle, color: Colors.orange, size: 30),
              const SizedBox(width: 10),
               Expanded(
                child: Text(
                  nom,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.message, color: Colors.orange, size: 24),
                onPressed: () {
                  // Action message
                },
              ),
              IconButton(
                icon: const Icon(Icons.phone, color: Colors.orange, size: 24),
                onPressed: () {
                  _callPhoneNumber(numero);
                  // Action téléphone
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Véhicule
       Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              "${type_vehicule} - ${immatriculation} ",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Téléphone
           Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              numero,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Bouton "Fin course"
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(73, 73, 73, 1.0), // Gris foncé
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // Action fin course
              },
              child: const Text(
                'Fin course',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
