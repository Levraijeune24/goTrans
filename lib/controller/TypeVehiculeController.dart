
import 'package:menji/services/ApiServiceLivraison.dart';

import '../services/ApiServiceTypeVehicule.dart';




class Typevehiculecontroller {


  late ApiServiceTypeVehicule v;

  Future<void> init () async {
    v = ApiServiceTypeVehicule();
    await v.init();

  }


  Future<List<Map<String,String>>> fetchTypeVehicule() async{

    final typeVehicules= await v.fetchTypeVehicules();
    return typeVehicules;
  }


}

