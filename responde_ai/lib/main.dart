import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'game_page.dart';
import 'audio_manager.dart';

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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<String>? rankings;
  int highScore = 0;
  bool hasPlayed = false;

  final AudioPlayer _effectPlayer = AudioPlayer();
  bool _isSoundEffectsOn = true;
  final List<String> _clickSounds = [
    'assets/sounds/clique1.wav',
    'assets/sounds/clique2.wav',
    'assets/sounds/clique3.wav',
    'assets/sounds/clique4.wav',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rankings = prefs.getStringList('rankings');
      highScore = prefs.getInt('highScore') ?? 0;
      hasPlayed = prefs.getBool('hasPlayed') ?? false;
      _isSoundEffectsOn = prefs.getBool('soundEffects') ?? true;
    });
    bool backgroundMusicOn = prefs.getBool('backgroundMusic') ?? true;
    AudioManager().setBackgroundMusicOn(backgroundMusicOn);
  }

  Future<void> _playClickSound() async {
    if (_isSoundEffectsOn) {
      final randomSound = _clickSounds[Random().nextInt(_clickSounds.length)];
      try {
        debugPrint('Tentando tocar som de clique: $randomSound');
        await _effectPlayer
            .play(AssetSource(randomSound.replaceFirst('assets/', '')));
        debugPrint('Som de clique tocado com sucesso');
      } catch (e) {
        debugPrint('Erro ao tocar som de clique: $e');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      AudioManager().pauseBackgroundMusic();
      debugPrint('Música pausada ao sair do app (HomeScreen)');
    } else if (state == AppLifecycleState.resumed) {
      AudioManager().playBackgroundMusic();
      debugPrint('Música retomada ao voltar ao app (HomeScreen)');
    }
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
            onPressed: () {
              _playClickSound();
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _launchGitHub() async {
    _playClickSound();
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

  void _showSettings() {
    bool tempBackgroundMusic = AudioManager().isBackgroundMusicOn;
    bool tempSoundEffects = _isSoundEffectsOn;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Configurações',
                  style: TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 24,
                    color: Color(0xFF22BF76),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Música de Fundo',
                      style: TextStyle(
                        fontFamily: 'FredokaOne',
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    Switch(
                      value: tempBackgroundMusic,
                      onChanged: (value) {
                        setModalState(() {
                          tempBackgroundMusic = value;
                        });
                        setState(() {
                          AudioManager().setBackgroundMusicOn(value);
                          _saveSettings();
                        });
                      },
                      activeColor: const Color(0xFF22BF76),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Efeitos Sonoros',
                      style: TextStyle(
                        fontFamily: 'FredokaOne',
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    Switch(
                      value: tempSoundEffects,
                      onChanged: (value) {
                        setModalState(() {
                          tempSoundEffects = value;
                        });
                        setState(() {
                          _isSoundEffectsOn = value;
                          _saveSettings();
                        });
                      },
                      activeColor: const Color(0xFF22BF76),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('backgroundMusic', AudioManager().isBackgroundMusicOn);
    await prefs.setBool('soundEffects', _isSoundEffectsOn);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _effectPlayer.dispose();
    super.dispose();
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
                  const Spacer(),
                  const SizedBox(height: 20),
                  const Text(
                    "RespondeAi",
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 60,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      _playClickSound();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(mode: 'classic'),
                        ),
                      ).then((_) => _loadSettings());
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
                      _playClickSound();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(mode: 'timer'),
                        ),
                      ).then((_) => _loadSettings());
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'FredokaOne',
                      fontSize: 28,
                    ),
                  ),
                  const Spacer(),
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
            Positioned(
              top: 10,
              right: 10,
              child: FloatingActionButton(
                onPressed: () {
                  _playClickSound();
                  _showSettings();
                },
                backgroundColor: const Color(0xFFd7693e),
                mini: true,
                child: const Icon(Icons.settings, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
