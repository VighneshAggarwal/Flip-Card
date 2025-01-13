//main.dart

import 'package:flutter/material.dart';
import 'package:flip_card/utils/game_logic.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Game _game = Game();
  List<AnimationController> _controllers = [];
  List<Animation<double>> _animations = [];
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playBackgroundMusic();
    _game.initGame();
    for (int i = 0; i < _game.cardCount; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      _controllers.add(controller);
      _animations.add(Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )));
    }
  }

void _playBackgroundMusic() async {
  try {
    await _audioPlayer.setSourceAsset('music/background.mp3');
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.resume();
    print('Background music started successfully');
  } catch (e) {
    print('Error playing background music: $e');
  }
}

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe55870),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Play And Earn Rewards",
                style: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns for 6 boxes
                  crossAxisSpacing: 24.0,
                  mainAxisSpacing: 24.0,
                  childAspectRatio: 1.0, // Ensures square-shaped boxes
                ),
                padding: const EdgeInsets.all(16.0),
                itemCount: _game.cardCount, // Display 6 boxes
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (_controllers[index].isDismissed) {
                        _controllers[index].forward();
                        setState(() {
                          _game.gameImg![index] = _game.card_list[index];
                          _game.matchCheck.add({index: _game.card_list[index]});
                        });
                        if (_game.matchCheck.length == 2) {
                          if (_game.matchCheck[0].values.first == _game.matchCheck[1].values.first) {
                            _game.matchCheck.clear();
                          } else {
                            Future.delayed(Duration(milliseconds: 500), () {
                              setState(() {
                                _game.gameImg![_game.matchCheck[0].keys.first] = _game.hiddenCardpath;
                                _game.gameImg![_game.matchCheck[1].keys.first] = _game.hiddenCardpath;
                                _controllers[_game.matchCheck[0].keys.first].reverse();
                                _controllers[_game.matchCheck[1].keys.first].reverse();
                                _game.matchCheck.clear();
                              });
                            });
                          }
                        }
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _animations[index],
                      builder: (context, child) {
                        final isFront = _animations[index].value < 0.5;
                        return Transform(
                          transform: Matrix4.rotationY(_animations[index].value * 3.1416),
                          alignment: Alignment.center,
                          child: isFront
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB46A),
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6.0,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: AssetImage(_game.hiddenCardpath),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB46A),
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6.0,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: AssetImage(_game.gameImg![index]),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
