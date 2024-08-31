import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:ui';  // Import this for ImageFilter

class FlashcardPage extends StatefulWidget {
  final String category;
  final List<Map<String, String>> items;
  final int initialIndex;

  const FlashcardPage({
    super.key,
    required this.category,
    required this.items,
    this.initialIndex = 0,
  });

  @override
  FlashcardPageState createState() => FlashcardPageState();
}

class FlashcardPageState extends State<FlashcardPage> {
  late AudioPlayer _player;
  late int _currentIndex;
  bool isPlaying = false;  // Track whether the audio is playing
  Color? dominantColor;
  Color textColor = Colors.white;  // Default text color

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _currentIndex = widget.initialIndex;
    _updatePaletteColor();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void playPauseSound(String soundPath) async {
    if (isPlaying) {
      await _player.pause();
    } else {
      await _player.play(AssetSource(soundPath));
    }
    setState(() {
      isPlaying = !isPlaying;  // Toggle play/pause state
    });
  }

  Future<void> _updatePaletteColor() async {
    String imagePath = widget.items[_currentIndex]['image']!;
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      AssetImage(imagePath),
    );
    setState(() {
      dominantColor = paletteGenerator.dominantColor?.color ?? Colors.grey;
      // Determine text color based on luminance
      textColor = (dominantColor!.computeLuminance() > 0.5) ? Colors.black : Colors.white;
    });
  }

  void _showNextFlashcard() async {
    await _player.stop();
    setState(() {
      isPlaying = false;  // Reset the play state when moving to next flashcard
      if (_currentIndex < widget.items.length - 1) {
        _currentIndex++;
        _updatePaletteColor();
      }
    });
  }

  void _showPreviousFlashcard() async {
    await _player.stop();
    setState(() {
      isPlaying = false;  // Reset the play state when moving to previous flashcard
      if (_currentIndex > 0) {
        _currentIndex--;
        _updatePaletteColor();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = widget.items[_currentIndex]['image']!;
    String soundPath = widget.items[_currentIndex]['sound']!.replaceFirst('assets/', '');
    String itemName = widget.items[_currentIndex]['name']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: CupertinoColors.activeBlue,  // Same color as the buttons
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white),  // Set icon color to white
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            // Swiped left, show next flashcard
            if (_currentIndex < widget.items.length - 1) {
              _showNextFlashcard();
            }
          } else if (details.primaryVelocity! > 0) {
            // Swiped right, show previous flashcard
            if (_currentIndex > 0) {
              _showPreviousFlashcard();
            }
          }
        },
        child: Stack(
          children: [
            // Blurry background with dominant color
            if (dominantColor != null)
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    color: dominantColor!.withOpacity(0.3),  // Reduced opacity for a more luminous effect
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    itemName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,  // Use dynamically determined text color
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      playPauseSound(soundPath);
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: SizedBox(
                      width: 500,
                      height: 500,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _currentIndex > 0
                            ? CupertinoButton(
                                padding: const EdgeInsets.all(20.0),  // Increase padding to match play button size
                                color: CupertinoColors.activeBlue,
                                borderRadius: BorderRadius.circular(50.0),  // Rounded button like the play button
                                onPressed: _showPreviousFlashcard,
                                child: const Icon(
                                  CupertinoIcons.back,  // iOS-style back arrow for Previous
                                  color: Colors.white,
                                  size: 40,  // Increase icon size to match play button
                                ),
                              )
                            : const SizedBox(width: 60), // Placeholder when button is hidden
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),  // 30% transparency black background
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.6),  // White glow effect
                                spreadRadius: 3,  // Updated spread radius
                                blurRadius: 1,    // Updated blur radius
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            padding: const EdgeInsets.all(20.0),  // Increase padding for a larger button
                            color: Colors.transparent,  // Make button itself transparent to use container's color
                            borderRadius: BorderRadius.circular(50.0),  // Rounded circular button
                            onPressed: () {
                              playPauseSound(soundPath);
                            },
                            child: Icon(
                              isPlaying ? CupertinoIcons.pause : CupertinoIcons.play_arrow_solid,
                              color: Colors.white,
                              size: 40,  // Increase icon size
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _currentIndex < widget.items.length - 1
                            ? CupertinoButton(
                                padding: const EdgeInsets.all(20.0),  // Increase padding to match play button size
                                color: CupertinoColors.activeBlue,
                                borderRadius: BorderRadius.circular(50.0),  // Rounded button like the play button
                                onPressed: _showNextFlashcard,
                                child: const Icon(
                                  CupertinoIcons.forward,  // iOS-style forward arrow for Next
                                  color: Colors.white,
                                  size: 40,  // Increase icon size to match play button
                                ),
                              )
                            : const SizedBox(width: 60), // Placeholder when button is hidden
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
