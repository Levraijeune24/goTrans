import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:menji/utils/elpers/elperDate.dart';
import 'package:menji/utils/elpers/elperLivraisons.dart';
import '../serviceAu/local_storage_service.dart';

class ApiServiceLivraison {
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  String get adresse => "https://gotrans.menjidrc.com/";

  String? token;

  Future<void> init() async {
    token = await LocalStorageService().getToken();
  }

  Future<bool> SaveLivraison(
      dynamic id_expediteur,
      dynamic id_destinateur,
      dynamic nom,
      dynamic adresseExpedition,
      dynamic adresseDestination,
      dynamic telephoneDestination,
      dynamic telephoneExpedition,
      dynamic moyenTransport,
      dynamic longitude_expedition,
      dynamic latitude_expedition,
      dynamic longitude_destination,
      dynamic latitude_destination,
      ) async {
    bool isStore = false;

    final url = Uri.parse(adresse + 'api/livraison/store');

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        "adresse_expedition": adresseExpedition,
        "tel_expedition": telephoneExpedition,
        "adresse_destination": adresseDestination,
        "tel_destination": telephoneDestination,
        'nom_destination': nom,
        "date": dateDuJour(),
        "code": genererCodeLivraison(),
        "status": "en_attente",
        "montant": "",
        "Kilo_total": "",
        "client_expediteur_id": id_expediteur,
        "client_destinateur_id": id_destinateur,
        "moyen_transport": moyenTransport,
        "longitude_expedition": longitude_expedition,
        "latitude_expedition": latitude_expedition,
        "longitude_destination": longitude_destination,
        "latitude_destination": latitude_destination
      }),
    );

    if (response.statusCode == 200) {
      isStore = true;
    }

    return isStore;
  }

  Future<List<Map<String, String>>> getLivraisonExpediteur(int id) async {
    List<Map<String, String>> livraisons = [];

    final url = Uri.parse(adresse + 'api/livraison/getLivraisonExpediteur/$id');

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      data["data"].forEach((livraison) {
        livraisons.add({
          "id": livraison["id"].toString(),
          "status": livraison["status"],
          "date": livraison["date"],
          "code": livraison["code"],
          "nom_livreur": livraison['vehicule']?['livreurs']?[0]?['livreur']?['user']?['name'] ?? "",
          "numero_livreur": livraison['vehicule']?['livreurs']?[0]?['livreur']?['user']?['number_phone'] ?? "",
          "nom_type_livreur": livraison['vehicule']?['type_vehicule']?['nom_type'] ?? "",
          "immatriculation_livreur": livraison['vehicule']?['immatriculation'] ?? "",
          "adresse_expedition": livraison["expedition"]["adresse"],
          "expediteur_id": livraison["expediteur"]["id"].toString(),
          "adresse_destination": livraison["destination"]["adresse"],
          "moyen_transport": livraison["moyen_transport"],
          "expediteur": livraison["expediteur"]?["user"]?["name"] ?? "",
          "destinateur": livraison["destinateur"]?["user"]?["name"] ?? "${livraison["destination"]["nom_destination"]} (n'esxiste pas)",
        });
      });
    }

    return livraisons;
  }

  Future<List<Map<String, String>>> getLivraisonDestinateur(int id) async {
    List<Map<String, String>> livraisons = [];

    final url = Uri.parse(adresse + 'api/livraison/getLivraisonDestinateur/$id');

    final response = await http.get(url, headers: _headers);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      data["data"].forEach((livraison) {
        livraisons.add({
          "id": livraison["id"].toString(),
          "status": livraison["status"],
          "date": livraison["date"],
          "code": livraison["code"],
          "adresse_expedition": livraison["expedition"]["adresse"],
          "adresse_destination": livraison["destination"]["adresse"],
          "nom_livreur": livraison['destinateur']['vehicule']?['livreurs']?[0]?['livreur']?['user']?['name'] ?? "",
          "numero_livreur": livraison['vehicule']?['livreurs']?[0]?['livreur']?['user']?['number_phone'] ?? "",
          "nom_type_livreur": livraison['vehicule']?['type_vehicule']?['nom_type'] ?? "",
          "immatriculation_livreur": livraison['vehicule']?['immatriculation'] ?? "",
          "moyen_transport": livraison["moyen_transport"],
          "expediteur_id": livraison["expediteur"]["id"].toString(),
          "expediteur": livraison["expediteur"]?["user"]?["name"] ?? "",
          "destinateur": livraison["destinateur"]?["user"]?["name"] ?? "${livraison["destination"]["nom_destination"]} (n'esxiste pas)",
        });
      });
    }

    return livraisons;
  }

  Future<List<Map<String, String>>> getLivraisonLivreur(int id) async {
    List<Map<String, String>> livraisons = [];

    final url = Uri.parse(adresse + 'api/livraison/getLivraisonLivreur/$id');

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      data["data"].forEach((livraison) {
        livraisons.add({
          "id": livraison["id"].toString(),
          "id_livreur": livraison["vehicule"]["livreurs"][0]["livreur"]["id"].toString(),
          "status": livraison["status"],
          "date": livraison["date"],
          "code": livraison["code"],
          "kilo": livraison["kilo_total"].toString(),
          "adresse_expedition": livraison["expedition"]["adresse"],
          "adresse_destination": livraison["destination"]["adresse"],
          "moyen_transport": livraison["moyen_transport"],
          "expediteur": livraison["expediteur"]?["user"]?["name"] ?? "",
          "destinateur": livraison["destinateur"]?["user"]?["name"] ?? "${livraison["destination"]["nom_destination"]} (n'esxiste pas)",
        });
      });
    }
    return livraisons;
  }

  Future<List<Map<String, String>>> showLivraisonLivreur(String id_livreur, String id_livraison) async {
    List<Map<String, String>> livraisons = [];

    final url = Uri.parse(adresse + 'api/livraison/showLivraisonLivreur/$id_livreur/$id_livraison');

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      data["data"].forEach((livraison) {
        livraisons.add({
          "id": livraison["id"].toString(),
          "id_livreur": livraison["vehicule"]["livreurs"][0]["id"].toString(),
          "tarif": livraison["vehicule"]["type_vehicule"]["tarif"]["prix_tarif"].toString(),
          "status": livraison["status"],
          "expedition_longitude": livraison["expedition"]["longitude"].toString(),
          "expedition_latitude": livraison["expedition"]["latitude"].toString(),
          "date": livraison["date"],
          "montant": livraison["montant"].toString(),
          "code": livraison["code"],
          "kilo_initiale": livraison["vehicule"]["type_vehicule"]["kilo_initiale"].toString(),
          "kilo_final": livraison["vehicule"]["type_vehicule"]["kilo_final"].toString(),
          "nom_type": livraison["vehicule"]["type_vehicule"]["nom_type"].toString(),
          "kilo": livraison["kilo_total"].toString(),
          "adresse_expedition": livraison["expedition"]["adresse"],
          "tel_expedition": livraison["expedition"]["tel_expedition"] ?? "",
          "tel_destination": livraison["destination"]["tel_destination"] ?? "",
          "adresse_destination": livraison["destination"]["adresse"],
          "moyen_transport": livraison["moyen_transport"],
          "expediteur": livraison["expediteur"]?["user"]?["name"] ?? "",
          "destinateur": livraison["destinateur"]?["user"]?["name"] ?? "${livraison["destination"]["nom_destination"]} (n'esxiste pas)",
        });
      });
    }
    return livraisons;
  }

  Future<String> annuler(String id) async {
    final url = Uri.parse(adresse + 'api/livraison/cancel/$id');

    final response = await http.get(url, headers: _headers);

    final data = jsonDecode(response.body);

    return data;
  }

  Future<String> editLivraisonLivreur(String id_livraison, String montant, String kilo) async {
    final url = Uri.parse(adresse + 'api/livraison/en_cours');

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        "id": id_livraison,
        "montant": montant,
        "poid": kilo
      }),
    );

    final data = jsonDecode(response.body);

    return data;
  }

  Future<List<Map<String, String>>> getClient() async {
    List<Map<String, String>> clients = [];

    final url = Uri.parse(adresse + 'api/user/clients');

    final response = await http.get(url, headers: _headers);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      data["data"].forEach((client) {
        clients.add({
          "id": client["id"].toString(),
          "nom": client["user"]["name"],
          "email": client["user"]["email"],
        });
      });
    }
    return clients;
  }

  Future<String> confirmerLivraison(String id_livraison, String codeLivraison) async {
    final url = Uri.parse(adresse + 'api/livraison/terminer');

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        "id": id_livraison,
        "codeLivraison": codeLivraison
      }),
    );

    final data = jsonDecode(response.body);

    return data;
  }

  Future<String> setLocalisation(dynamic longitude, dynamic latitude, dynamic id_livraison) async {
    final url = Uri.parse(adresse + 'api/localisation/setLocalisation');
    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          "longitude": longitude,
          "latitude": latitude,
          "livraison_id": id_livraison
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
      }
    } catch (e) {
      // ignore error silently or log as needed
    }

    return "OK";
  }

  Future<Map<String, dynamic>> getLocalisation(String id) async {
    Map<String, dynamic> localisation = {};

    final url = Uri.parse(adresse + 'api/localisation/getLocalisation');
    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          "livraison_id": id.toString()
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        localisation["latitude"] = data["localisation"]["latitude"];
        localisation["longitude"] = data["localisation"]["longitude"];
      }
    } catch (e) {
      // ignore error silently or log as needed
    }

    return localisation;
  }
}
