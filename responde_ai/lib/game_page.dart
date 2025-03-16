import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GamePage extends StatelessWidget {
  final bool darkMode;

  const GamePage({super.key, required this.darkMode});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: darkMode ? const Color(0xFF16151A) : Colors.white,
        statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: const Text("Segunda Página"),
          backgroundColor: darkMode ? const Color(0xFF16151A) : Colors.white,
          foregroundColor: darkMode ? Colors.white : Colors.black,
        ),
        body: Container(
          padding: EdgeInsets.only(left: 30, right: 30, bottom: 140),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Aqui haverá a logica do app e os widgets necessarios",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkMode ? Colors.white : Colors.black,
                  fontFamily: 'FredokaOne',
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ));
  }
}
