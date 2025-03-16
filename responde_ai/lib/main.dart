import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_page.dart';

void main() {
  runApp(const RespondeAi());
}

class RespondeAi extends StatefulWidget {
  const RespondeAi({super.key});

  @override
  _RespondeAiState createState() => _RespondeAiState();
}

class _RespondeAiState extends State<RespondeAi> {
  bool darkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  Future<void> _loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        darkMode = prefs.getBool('darkMode') ?? false;
        _isLoading = false;
      });
      _applySystemOverlay();
    }
  }

  Future<void> _saveDarkModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    _applySystemOverlay();
  }

  void _applySystemOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: darkMode ? const Color(0xFF16151A) : Colors.white,
        statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RespondeAi',
      theme: ThemeData(
        scaffoldBackgroundColor:
            darkMode ? const Color(0xFF16151A) : Colors.white,
      ),
      home: _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : HomeScreen(
              darkMode: darkMode,
              onDarkModeChanged: (value) {
                setState(() {
                  darkMode = value;
                });
                _saveDarkModePreference(value);
              },
            ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const HomeScreen(
      {super.key, required this.darkMode, required this.onDarkModeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "RespondeAi",
                style: TextStyle(
                  fontFamily: 'MonsterGame',
                  fontSize: 50,
                  color: darkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  debugPrint("Clicado!");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GamePage(darkMode: darkMode),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: darkMode ? Colors.white : const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    "Clique aqui",
                    style: TextStyle(
                      color: darkMode ? Colors.black : Colors.white,
                      fontFamily: 'FredokaOne',
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Switch(
                value: darkMode,
                onChanged: onDarkModeChanged,
              ),
              Text(darkMode ? "Modo Escuro" : "Modo Claro"),
            ],
          ),
        ),
      ),
    );
  }
}
