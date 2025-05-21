

import 'package:flutter/material.dart';



class BlockMoyenTransport {

  String image;
  String title;
  String description;
  BuildContext context;
  final VoidCallback onPressed;


  BlockMoyenTransport(this.onPressed, {  required this.context,required this.image,required this.title, required this.description});


  Widget Run(){


    return GestureDetector(
      onTap: () {

        this.onPressed();

      },
      child: _buildCard(
        this.image,
        this.title,
        this.description
      ),
    );


  }
  Widget _buildCard(String imagePath, String title, String subtitle) {
    return Container(
      width: 250,
      height: 300,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 160,
              height: 160,
              fit: BoxFit.contain,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            Icon(Icons.arrow_forward, color: Colors.orange, size: 24),
          ],
        ),
      ),
    );
  }

}