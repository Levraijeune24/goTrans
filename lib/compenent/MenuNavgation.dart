
import 'package:flutter/material.dart';



class MenuNavigation {

  final void Function(int) action;

  int currentIndex =0;

  MenuNavigation({required this.action,required this.currentIndex});



 Widget run (){
     return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
      action(index);
      },
      type: BottomNavigationBarType.fixed,
      items: [
        itemButtonNavigation(
            chemin: "images/Icone_Home.png",
            numero: 0, label: 'Accueil'
        ),

        itemButtonNavigation(
            chemin: "images/historique.png",
            numero: 2, label: 'Historique'
        ),
        itemButtonNavigation(
            chemin: "images/Icone_Compte.png",
            numero: 1, label: 'Profil'
        ),

      ],
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      );
}

}

Widget _buildBottomNavIcon(String imagePath, int index) {
  return Image.asset(
    imagePath,
    width:  24,
    height: 24,
    color: Colors.grey,
  );
}



BottomNavigationBarItem itemButtonNavigation({
   required String chemin,required String label,required int numero
}){

  return  BottomNavigationBarItem(
    icon: _buildBottomNavIcon(chemin, numero),
    label: label,
  );

}
