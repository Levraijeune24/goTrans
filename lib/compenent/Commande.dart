import 'package:flutter/material.dart';

import 'ButtonClient.dart';



class Commande {

 late  String titre;
 late  String itineraire;
 late String date;
 late String status;
 late List<Widget> actions;

 final  VoidCallback actionVoirPlus;


 Commande({required this.titre,required this.itineraire,required this.status,
   required this.date,required this.actions,required this.actionVoirPlus});


   Container run(){

    return Container(
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
          Row(
            children: [
              Text(
                titre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Spacer(),
              Text(
                status,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Spacer(),
              InkWell(
                child:Text(
                  "Plus d'info",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 11,
                  ),
                ) ,
                onTap: actionVoirPlus,
              )
              ,
            ],

          ),

          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 10, color: Colors.orange),
              const SizedBox(width: 4),
               Text(
                itineraire,
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 10, color: Colors.orange),
              const SizedBox(width: 4),
               Text(
                'Date prévue : $date',
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children:actions.map((v){
              return Row(mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [v,  const SizedBox(width: 15)
                  ]);

            }).toList(),
          )

        ],
      ),
    );

  }

}