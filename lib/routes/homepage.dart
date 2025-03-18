import 'dart:math';

import 'package:demo_todo_with_flutter/routes/Games.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'Streak.dart';
import 'Learn.dart'; // Importiamo la pagina del negozio

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.greenAccent, // Sfondo verde chiaro
      body: Column(
        children: [
          // Barra superiore con pulsanti
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, size: 30),
                  onPressed: () {},
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(10), // Raggio degli angoli
                    boxShadow: [
                      // Opzionale: aggiunge un'ombra leggera
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10), // Spaziatura interna
                  child: const Text(
                    'Home Page',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Colore del testo
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline, size: 30),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          Expanded(

              child: Image.asset(
                'assets/images/plant/plant_happy.png',

                alignment: const Alignment(0.0, 0.4),
                width: 150,  // Set a smaller width
                height: 150, // Set a smaller height
                fit: BoxFit.contain, // Ensures the image keeps its aspect ratio
              ),

          ),



          // Menu inferiore con navigazione
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            color: Colors.green[700],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _bottomMenuButton(context, Icons.videogame_asset, 'Games',
                    const Games()), // Naviga alla pagina dei Giochi
                _bottomMenuButton(context, Icons.add_task, 'Streak',
                    const Streak()), // Naviga alla pagina delle Streak
                _bottomMenuButton(context, Icons.explore_rounded, 'Learn',
                    const Learn()), // Naviga alla pagina di apprendimento
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomMenuButton(BuildContext context, IconData icon, String label,
      Widget? page) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        },

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),

      ),
    );
  }
}

@override
bool shouldRepaint(CustomPainter oldDelegate) => false;
