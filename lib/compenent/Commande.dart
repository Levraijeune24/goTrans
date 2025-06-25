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


 Widget run() {
   return LayoutBuilder(
     builder: (context, constraints) {
       return Container(
         padding: const EdgeInsets.all(12),
         decoration: BoxDecoration(
           color:  Colors.white,
           borderRadius: BorderRadius.circular(12),
           boxShadow: [
             BoxShadow(
               color: Colors.grey.withOpacity(0.2),
               spreadRadius: 2,
               blurRadius: 5,
               offset: const Offset(0, 1),
             ),
           ],
         ),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             /// Titre, statut, et plus d’info
             Row(
               children: [
                 Expanded(
                   flex: 3,
                   child: Text(
                     titre,
                     style: const TextStyle(
                       fontWeight: FontWeight.bold,
                       fontSize: 13,
                     ),
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 Expanded(
                   flex: 2,
                   child: Text(
                     status,
                     style: const TextStyle(
                       color: Colors.blue,
                       fontWeight: FontWeight.bold,
                       fontSize: 11,
                     ),
                     textAlign: TextAlign.center,
                   ),
                 ),
                 Expanded(
                   flex: 3,
                   child: InkWell(
                     onTap: actionVoirPlus,
                     child: const Text(
                       "Plus d'info",
                       textAlign: TextAlign.end,
                       style: TextStyle(
                         fontWeight: FontWeight.bold,
                         color: Colors.orange,
                         fontSize: 11,
                       ),
                     ),
                   ),
                 ),
               ],
             ),

             const SizedBox(height: 10),

             /// Itinéraire
             Row(
               children: [
                 const Icon(Icons.location_on, size: 14, color: Colors.orange),
                 const SizedBox(width: 6),
                 Flexible(
                   child: Text(
                     itineraire,
                     style: const TextStyle(fontSize: 12),
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
               ],
             ),

             const SizedBox(height: 8),

             /// Date prévue
             Row(
               children: [
                 const Icon(Icons.calendar_today, size: 14, color: Colors.orange),
                 const SizedBox(width: 6),
                 Text(
                   'Date prévue : $date',
                   style: const TextStyle(fontSize: 12),
                 ),
               ],
             ),

             const SizedBox(height: 12),

             /// Actions dynamiques
             Wrap(
               spacing: 12,
               runSpacing: 8,
               children: actions,
             ),
           ],
         ),
       );
     },
   );
 }


}