import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, rootBundle;
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class GamePage extends StatefulWidget {
  final String mode;
  const GamePage({super.key, required this.mode});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Random _random = Random();
  List<dynamic>? questions;
  List<int> questionOrder = [];
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  int score = 0;
  final int _duration = 30;
  final CountDownController _controller = CountDownController();
  List<String>? shuffledOptions;
  bool skipUsed = false;
  bool revealUsed = false;
  bool eliminateUsed = false;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    String jsonString = await rootBundle.loadString('assets/questions.json');
    questions = jsonDecode(jsonString);
    resetGame();
    _shuffleQuestions();
    _shuffleCurrentOptions();
    setState(() {
      if (widget.mode == 'timer') {
        Future.delayed(const Duration(milliseconds: 500), () {
          _controller.start();
        });
      }
    });
  }

  void resetGame() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      selectedAnswer = null;
      skipUsed = false;
      revealUsed = false;
      eliminateUsed = false;
      _shuffleQuestions();
      _shuffleCurrentOptions();
      if (widget.mode == 'timer') _controller.restart(duration: _duration);
    });
  }

  void _shuffleQuestions() {
    questionOrder = List.generate(questions!.length, (index) => index)
      ..shuffle(_random);
  }

  void _shuffleCurrentOptions() {
    shuffledOptions =
        List.from(questions![questionOrder[currentQuestionIndex]]['options'])
          ..shuffle(_random);
  }

  void checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      if (widget.mode == 'timer') _controller.pause();

      bool isCorrect =
          answer == questions![questionOrder[currentQuestionIndex]]['answer'];
      if (isCorrect) {
        score += 5;
        Future.delayed(const Duration(seconds: 1), () {
          nextQuestion();
        });
      } else {
        saveScore();
        showResult();
      }
    });
  }

  void skipQuestion() {
    if (!skipUsed) {
      setState(() {
        skipUsed = true;
        if (widget.mode == 'timer') _controller.pause();
        nextQuestion();
      });
    }
  }

  void revealAnswer() {
    if (!revealUsed) {
      setState(() {
        revealUsed = true;
        selectedAnswer =
            questions![questionOrder[currentQuestionIndex]]['answer'];
        if (widget.mode == 'timer') _controller.pause();
        Future.delayed(const Duration(seconds: 1), () {
          nextQuestion();
        });
      });
    }
  }

  void eliminateOptions() {
    if (!eliminateUsed) {
      setState(() {
        eliminateUsed = true;
        var correctAnswer =
            questions![questionOrder[currentQuestionIndex]]['answer'];
        shuffledOptions = shuffledOptions!
            .where((option) => option == correctAnswer || Random().nextBool())
            .take(2)
            .toList();
      });
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions!.length - 1) {
      currentQuestionIndex++;
      selectedAnswer = null;
      _shuffleCurrentOptions();
      if (widget.mode == 'timer') _controller.restart(duration: _duration);
      setState(() {});
    } else {
      saveScore();
      showResult();
    }
  }

  Future<void> saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    int highScore = prefs.getInt('highScore') ?? 0;
    if (score > highScore) {
      await prefs.setInt('highScore', score);
    }
    List<String> rankings = prefs.getStringList('rankings') ?? [];
    rankings.add('$score - ${DateTime.now().toString().substring(0, 19)}');
    rankings.sort((a, b) =>
        int.parse(b.split(' - ')[0]).compareTo(int.parse(a.split(' - ')[0])));
    if (rankings.length > 5) rankings = rankings.sublist(0, 5);
    await prefs.setStringList('rankings', rankings);
  }

  void showResult() {
    if (widget.mode == 'timer') _controller.pause();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                "Fim do Jogo!",
                style: TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                selectedAnswer != null &&
                        selectedAnswer !=
                            questions![questionOrder[currentQuestionIndex]]
                                ['answer']
                    ? "Você errou e perdeu!"
                    : "Você fez $score pontos!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 18,
                    color: Colors.black54),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      resetGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      "Jogar Novamente",
                      style: TextStyle(
                          fontFamily: 'FredokaOne',
                          color: Colors.white,
                          fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      "Sair",
                      style: TextStyle(
                          fontFamily: 'FredokaOne',
                          color: Colors.white,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions == null || shuffledOptions == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    var currentQuestion = questions![questionOrder[currentQuestionIndex]];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF22BF76),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            saveScore();
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color(0xFF22BF76),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.mode == 'timer')
                  CircularCountDownTimer(
                    duration: _duration,
                    initialDuration: 0,
                    controller: _controller,
                    width: 100,
                    height: 100,
                    ringColor: Colors.grey[300]!,
                    fillColor: Colors.redAccent,
                    backgroundColor: Colors.transparent,
                    strokeWidth: 12.0,
                    strokeCap: StrokeCap.round,
                    textStyle: const TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 22,
                      color: Colors.white,
                    ),
                    isReverse: true,
                    isTimerTextShown: true,
                    autoStart: false,
                    onComplete: () {
                      saveScore();
                      showResult();
                    },
                  ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    currentQuestion['question'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ...shuffledOptions!.map<Widget>((option) {
                  return GestureDetector(
                    onTap: selectedAnswer == null
                        ? () => checkAnswer(option)
                        : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: selectedAnswer == option
                            ? (option == currentQuestion['answer']
                                ? Colors.lightGreen
                                : Colors.redAccent)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedAnswer == option
                                ? (option == currentQuestion['answer']
                                    ? Icons.check_circle
                                    : Icons.cancel)
                                : Icons.circle_outlined,
                            color: selectedAnswer == null
                                ? Colors.blueAccent
                                : Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontFamily: 'FredokaOne',
                                fontSize: 20,
                                color: selectedAnswer == null
                                    ? Colors.black87
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.skip_next,
                      label: 'Pular',
                      isDisabled: skipUsed,
                      onPressed: skipQuestion,
                      color: Colors.orange,
                    ),
                    _buildActionButton(
                      icon: Icons.delete_sweep,
                      label: 'Eliminar',
                      isDisabled: eliminateUsed,
                      onPressed: eliminateOptions,
                      color: Colors.red,
                    ),
                    _buildActionButton(
                      icon: Icons.visibility,
                      label: 'Dica',
                      isDisabled: revealUsed,
                      onPressed: revealAnswer,
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    "Pontuação: $score",
                    style: const TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isDisabled,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: Icon(
        icon,
        color: Colors.white,
      ),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? Colors.grey : color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}
