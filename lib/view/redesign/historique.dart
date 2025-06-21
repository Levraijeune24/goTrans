import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedDeliveryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
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
                  const SizedBox(width: 8),
                  _buildDeliveryStatus(
                    'Terminée',
                    isSelected: _selectedDeliveryIndex == 2,
                    onTap: () {
                      setState(() {
                        _selectedDeliveryIndex = 2;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildDeliveryStatus(
                    'All',
                    isSelected: _selectedDeliveryIndex == 3,
                    onTap: () {
                      setState(() {
                        _selectedDeliveryIndex = 3;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            //const Divider(),
            _buildDateSection(),


            // Section des dates

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
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : const Color.fromRGBO(245, 240, 250, 1.0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }


  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      )
                    ],
                  ),

                  child:  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.orange,
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {},
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOrderItem({
    required String orderNumber,
    required String status,
    required String from,
    required String to,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
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
          Text(
            'Commande $orderNumber- $status',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
              Text('De : $from > $to'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
              Text('Date prévue : $date'),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.orange,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () {},
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
        ],
      ),
    );
  }
}