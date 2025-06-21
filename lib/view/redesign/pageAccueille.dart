
import 'package:flutter/material.dart';
import 'package:menji/view/redesign/suivi.dart';

import 'commander.dart';
import 'historique.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}

// 1. Enum pour les types de véhicules
enum VehicleType { moto, camion, grosCamion }

// 2. Extension pour les propriétés de chaque type
extension VehicleTypeExtension on VehicleType {
  String get name {
    switch (this) {
      case VehicleType.moto:
        return 'Moto';
      case VehicleType.camion:
        return 'Camion';
      case VehicleType.grosCamion:
        return 'Gros Camion';
    }
  }

  String get description {
    switch (this) {
      case VehicleType.moto:
        return 'Véhicule à deux roues adapté pour la livraison rapide de colis légers ou de petits objets.';
      case VehicleType.camion:
        return 'Véhicule adapté pour le transport de charges moyennes en ville.';
      case VehicleType.grosCamion:
        return 'Véhicule lourd adapté pour le transport de grandes quantités ou charges lourdes.';
    }
  }

  String get imagePath {
    switch (this) {
      case VehicleType.moto:
        return 'images/Icone_moto2.png';
      case VehicleType.camion:
        return 'images/Icone_camion2.png';
      case VehicleType.grosCamion:
        return 'images/Icone_grosCamion2.png';
    }
  }

  String get tarif {
    switch (this) {
      case VehicleType.moto:
        return '1\$';
      case VehicleType.camion:
        return '15\$';
      case VehicleType.grosCamion:
        return '30\$';
    }
  }

  String get capacite {
    switch (this) {
      case VehicleType.moto:
        return '1 colis ou jusqu\'à 30 kg';
      case VehicleType.camion:
        return 'Jusqu\'à 20 colis ou 500 kg';
      case VehicleType.grosCamion:
        return 'Jusqu\'à 100 colis ou 2000 kg';
    }
  }

  String get vitesse {
    switch (this) {
      case VehicleType.moto:
        return '40-60 km/h';
      case VehicleType.camion:
        return '30-50 km/h';
      case VehicleType.grosCamion:
        return '20-40 km/h';
    }
  }
}

// 3. Classe principale (MainScreen)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final Color lightGreyF5 = const Color(0xFFF5F5F5);
  String userName = "Bob";
  int _notificationCount = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const PackageTrackerScreen(),
    const HistoryScreen(),
    const Placeholder(),
  ];

  Widget _buildBottomNavIcon(String imagePath, int index) {
    return Image.asset(
      imagePath,
      width: _currentIndex == index ? 30 : 24,
      height: _currentIndex == index ? 30 : 24,
      color: _currentIndex == index ? Colors.orange : Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Accueil',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Image.asset(
                  'images/Icone_notif.png',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _notificationCount++;
                  });
                },
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: _buildBottomNavIcon('images/Icone_Home.png', 0),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: _buildBottomNavIcon('images/Icone_Suivi.png', 1),
            label: 'Suivi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 24),
            activeIcon: Icon(Icons.history, size: 30, color: Colors.orange),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: _buildBottomNavIcon('images/Icone_Compte.png', 3),
            label: 'Profil',
          ),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedDeliveryIndex = 0;

  void _navigateToVehicleScreen(VehicleType vehicleType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleInfoScreen(vehicleType: vehicleType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 24),
                children: [
                  const TextSpan(
                    text: 'Bienvenu ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    ),
                  ),
                  TextSpan(
                    text: "Bob",
                    style: const TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.orange,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryItem(
                  context,
                  imagePath: 'images/Icone_moto.png',
                  label: 'Moto',
                  onTap: () => _navigateToVehicleScreen(VehicleType.moto),
                ),
                _buildCategoryItem(
                  context,
                  imagePath: 'images/Icone_camion.png',
                  label: 'Camion',
                  onTap: () => _navigateToVehicleScreen(VehicleType.camion),
                ),
                _buildCategoryItem(
                  context,
                  imagePath: 'images/Icone_grosCamion.png',
                  label: 'Gros camion',
                  onTap: () => _navigateToVehicleScreen(VehicleType.grosCamion),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Mes livraisons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Segoe UI',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDeliveryStatus(
                  'En cours',
                  isSelected: _selectedDeliveryIndex == 0,
                  onTap: () {
                    setState(() {
                      _selectedDeliveryIndex = 0;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildDeliveryStatus(
                  'Validée',
                  isSelected: _selectedDeliveryIndex == 1,
                  onTap: () {
                    setState(() {
                      _selectedDeliveryIndex = 1;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),



            // Nouveau bloc de commande en attente
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(245, 240, 250, 1.0),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 0.8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Commande #4578966- En attente de validation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 10, color: Colors.orange),
                      const SizedBox(width: 4),
                      const Text(
                        'De : Combe > Lingwala',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 10, color: Colors.orange),
                      const SizedBox(width: 4),
                      const Text(
                        'Date prévue : 04 Juin 2025 -09h00',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: 20,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.orange,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),

                  child:  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4), // Bords légèrement arrondis
                      color: Colors.orange,
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4), // Même arrondi que le container
                        ),
                      ),
                      onPressed: () {
                        // Action pour "Voir plus"
                      },
                      child: const Text(
                        'Voir plus',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
                ],
              ),
            ),
            //
            //

          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
      BuildContext context, {
        required String imagePath,
        required String label,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(//
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.only(top: 25),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(245, 240, 250, 1.0),
          borderRadius: BorderRadius.circular(12),

        ),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              height: 50,
              width: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 40, color: Colors.red);
              },
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Segoe UI',
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryStatus(
      String status, {
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        constraints: const BoxConstraints(minWidth: 100),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : const Color.fromRGBO(245, 240, 250, 1.0),
          borderRadius: BorderRadius.circular(8),

        ),
        child: Center(
          child: Text(
            status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}