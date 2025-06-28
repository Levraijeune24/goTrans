import 'package:flutter/material.dart';

class MenuNavigation {
  final void Function(int) action;
  int currentIndex = 0;

  MenuNavigation({required this.action, required this.currentIndex});

  Widget run() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => action(index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      items: [
        itemButtonNavigation(
          chemin: "images/Icone_Home.png",
          numero: 0,
          label: 'Accueil',
          currentIndex: currentIndex,
        ),
        itemButtonNavigation(
          chemin: "images/historique.png",
          numero: 2,
          label: 'Historique',
          currentIndex: currentIndex,
        ),
        itemButtonNavigation(
          chemin: "images/Icone_Compte.png",
          numero: 1,
          label: 'Profil',
          currentIndex: currentIndex,
        ),
      ],
    );
  }
}

Widget _buildBottomNavIcon(String imagePath, int index, int currentIndex) {
  bool isSelected = index == currentIndex;


  return Image.asset(
    imagePath,
    width: isSelected ? 24 : 24,
    height: isSelected ? 24 : 24,
    color: isSelected ? Colors.orange : Colors.grey,
  );
}

BottomNavigationBarItem itemButtonNavigation({
  required String chemin,
  required String label,
  required int numero,
  required int currentIndex,
}) {
  return BottomNavigationBarItem(
    icon: _buildBottomNavIcon(chemin, numero, currentIndex),
    label: label,
  );
}
