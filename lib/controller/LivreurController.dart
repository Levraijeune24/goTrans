
import 'package:flutter/material.dart';
import 'package:menji/view/client/pageAccueille.dart';
import '../serviceAu/local_storage_service.dart';
import '../services/ApiServiceLivraison.dart';
import '../view/livreur/pageAccueilleLivreur.darT';
import '../view/livreur/validationLivreur.dart';


class Livreurcontroller {


  void InitLivreur(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PageLivreur()),
    );
  }

  void  getDetailleLivraison(BuildContext context,String id_livreur ,String id_livraison) async {




    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PageValidation(id_livreur ,id_livraison)),
    );

  }
}
