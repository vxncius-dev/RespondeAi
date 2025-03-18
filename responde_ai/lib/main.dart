import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF22BF76),
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const RespondeAi());
}

class RespondeAi extends StatelessWidget {
  const RespondeAi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RespondeAi',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF22BF76),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String>? rankings;
  int highScore = 0;
  bool hasPlayed = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rankings = prefs.getStringList('rankings');
      highScore = prefs.getInt('highScore') ?? 0;
      hasPlayed = prefs.getBool('hasPlayed') ?? false;
      if (!hasPlayed && rankings != null) {
        prefs.setBool('hasPlayed', true);
        showRankingsDialog();
      }
    });
  }

  void showRankingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ranking"),
        content: SingleChildScrollView(
          child: Column(
            children: rankings!
                .map((rank) => Text(
                      rank,
                      style: const TextStyle(
                          fontFamily: 'FredokaOne', fontSize: 16),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse('https://github.com/vxncius-dev');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Não foi possível abrir o link';
      }
    } catch (e) {
      debugPrint('Erro ao abrir GitHub: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  const Text(
                    "RespondeAi",
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(mode: 'classic'),
                        ),
                      ).then((_) => loadData());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFd7693e),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        "Modo Clássico",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'FredokaOne',
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(mode: 'timer'),
                        ),
                      ).then((_) => loadData());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        "Timer (30s)",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'FredokaOne',
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: OverflowBox(
                      minWidth: 0.0,
                      maxWidth: double.infinity,
                      child: Image.asset(
                        'assets/cards.png',
                        width: MediaQuery.of(context).size.width * 1,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Recorde: $highScore",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'FredokaOne',
                      fontSize: 28,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: _launchGitHub,
                    child: const Text(
                      "Desenvolvido por Vxncius",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'FredokaOne',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
