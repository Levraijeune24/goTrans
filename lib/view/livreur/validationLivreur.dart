import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../controller/LivraisonController.dart';
import 'localisationClient.dart';



class PageValidation extends StatefulWidget {
  final String id_livraison;
  final String id_livreur;

  PageValidation(this.id_livreur, this.id_livraison);

  @override
  _PageValidationState createState() => _PageValidationState();
}

class _PageValidationState extends State<PageValidation> {
  late StreamSubscription<Position> _positionStreamSubscription;
  LatLng destination = LatLng(-4.322447, 15.307045);
  Position? _lastPosition;

  bool isState=false;


  final poidsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final LivraisonController _livraisonController = LivraisonController();

  int prixTotal = 1;
  List<Map<String, String>> livraisons = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initInfoLivraison();
  }


  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    super.dispose();
  }


  Future<void> initInfoLivraison() async {
    await _livraisonController.init();
    livraisons = await _livraisonController.ShowForLivreur(
      widget.id_livreur,
      widget.id_livraison,
    );
    setState(() {

      if(livraisons[0]["status"]=="en_cours" || livraisons[0]["status"]=="terminee"){
        isState=true;
      }

    });

    if (livraisons.isNotEmpty) {
      setState(() {
        destination = LatLng(
          double.tryParse(livraisons[0]["expedition_latitude"] ?? "-4.322447")!,
          double.tryParse(livraisons[0]["expedition_longitude"] ?? "15.307045")!,
        );
        isLoading = true;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar("La localisation est désactivée");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar("Permission refusée");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar("Permission définitivement refusée");
      return;
    }

    _showSnackBar("nous avons active votre position ...");




      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 3,
        ),
      ).listen((Position position) {
        if (_lastPosition == null ||
            Geolocator.distanceBetween(
              _lastPosition!.latitude,
              _lastPosition!.longitude,
              position.latitude,
              position.longitude,
            ) >= 1) {

          setState(() {
            _livraisonController.setLocalisation(
              position.longitude,
              position.latitude,
              widget.id_livraison,
            );
            //_showSnackBar("longitude :${position.longitude},  latitude :${position.latitude}");
            _lastPosition = position;
          });
        }
      });

  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Validation', style: TextStyle(color: Colors.orange)),
      ),
      body: isLoading
          ? Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Informations clients'),
              _buildInfoRow('Nom de l\'expéditeur', livraisons[0]["expediteur"] ?? "", Icons.person),
              _buildInfoRow(
                'Adresse de l\'expéditeur',
                livraisons[0]["adresse_expedition"] ?? "",
                Icons.location_on,
                action: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocalisationclientPage(destination),
                  ),
                ),
              ),
              _buildInfoRow('Téléphone de l\'expéditeur', livraisons[0]["tel_expedition"] ?? "", Icons.phone),
              Divider(),
              _buildInfoRow('Nom du destinataire', livraisons[0]["destinateur"] ?? "", Icons.person),
              _buildInfoRow('Adresse du destinataire', livraisons[0]["adresse_destination"] ?? "", Icons.location_on),
              _buildInfoRow('Téléphone du destinataire', livraisons[0]["tel_destination"] ?? "", Icons.phone),
              SizedBox(height: 20),

              Row(
                children: [_sectionTitle('Tarification'),livraisons[0]["status"]!="terminee"? ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isState=false;
                    });

                  },
                  icon: Icon(Icons.edit),
                  label: Text("modification"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ):Center()],
              )

              ,
              _buildRow('Type :: ${livraisons[0]["nom_type"]}',c:Colors.red, ' entre ${livraisons[0]["kilo_initiale"]}kg et ${livraisons[0]["kilo_final"]}kg '),

              _buildRow('Prix unitaire', '${livraisons[0]["tarif"]} Fc'),
              isState==false?
              _buildPricingRow('Entrer le poids', poidsController, () {
                final poids = int.tryParse(poidsController.text) ?? 0;
                final tarif = int.tryParse(livraisons[0]["tarif"] ?? "0") ?? 0;
                setState(() {
                  prixTotal = poids * tarif;
                });
              }):_buildRow('Poid estime', '${livraisons[0]["kilo"].toString()} Fc'),
              isState==false?
              _buildRow('Prix total', '$prixTotal Fc'):
              _buildRow('Prix total', '${livraisons[0]["montant"].toString()} Fc')
              ,
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: Icon(Icons.my_location),
                label: Text("activer ma position actuelle"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed:isState==false? () {
                    if (_formKey.currentState!.validate()) {
                      _livraisonController.editLivraisonLivreur(
                        context,
                        livraisons[0]["id"] ?? "",
                        prixTotal.toString(),
                        poidsController.text,
                      );
                    } else {
                      _showSnackBar("Veuillez remplir tous les champs obligatoires");
                    }
                  }:null,
                  child: Text('Confirmer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
      )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {VoidCallback? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.all(10.0),
            width: 300,
            color: Colors.white,
            child: Text(value),
          ),
        ]),
        if (action != null)
          InkWell(onTap: action, child: Icon(icon))
        else
          Icon(icon),
      ],
    );
  }

  Widget _buildPricingRow(String label, TextEditingController controller, VoidCallback onChanged) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.only(top: 5.0, bottom: 10.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Container(
            width: 200,
            height: 40,
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: controller,
              onChanged: (value) => onChanged(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le champ "$label" est requis';
                }
                final number = num.tryParse(value);
                if (number == null || number < 0) {
                  return 'Veuillez entrer un nombre positif svp';
                }
                num? min = num.tryParse(livraisons[0]["kilo_initiale"]!) ; // Limite minimale
                num ?  max =num.tryParse(livraisons[0]["kilo_final"]!) ; // Limite maximale

                if (number < min! || number > max!) {
                  return 'Le poid entre $min Kg et $max Kg';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Entrez $label',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String text,{Color c=Colors.black}) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold,color: c, fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: c),
            ),
          ),
        ],
      ),
    );
  }
}
