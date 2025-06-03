import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../view/client/pageHistorique.dart';




class Navigation{

  BuildContext context;
  int type=0;


  Navigation({required this.context,this.type=0});


  run(){
    return BottomNavigationBar(
      backgroundColor: Colors.grey[200],
      elevation: 0,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Historique',
        ),

        BottomNavigationBarItem(

          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      currentIndex: 0,
      onTap: (index) {
        print(index);
        if(index==2){
            context.go('/profil');
        }else if(index==1){
          if(type==0){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PageHistorique()),
            );

          }

        }
        // Gérer la navigation ici
      },
    );
  }


}


