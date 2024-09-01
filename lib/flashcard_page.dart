import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:ui';  // Import this for ImageFilter
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_page.dart';  // Import the SettingsPage
import 'dart:math'; // Import for shuffling the list

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
  bool _isAudioAutoPlay = false;  // Track auto-play setting
  bool _isRandomizeFlashcards = false;  // Track randomize flashcards setting
  Color? dominantColor;
  Color textColor = Colors.white;  // Default text color
  List<Map<String, String>> _shuffledItems = [];  // List to hold shuffled items

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadSettings();
    _setupFlashcards();
  }

  void _setupFlashcards() async {
    await _loadSettings();
    setState(() {
      _shuffledItems = List<Map<String, String>>.from(widget.items);
      if (_isRandomizeFlashcards && _shuffledItems.isNotEmpty) {
        _shuffledItems.shuffle(Random());
      }
      _currentIndex = (_shuffledItems.isNotEmpty && widget.initialIndex < _shuffledItems.length)
          ? widget.initialIndex
          : 0;
      _updatePaletteColor();
      if (_isAudioAutoPlay && _shuffledItems.isNotEmpty) {
        playSound(_shuffledItems[_currentIndex]['sound']!.replaceFirst('assets/', ''));
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAudioAutoPlay = (prefs.getBool('isAudioAutoPlay') ?? false);
      _isRandomizeFlashcards = (prefs.getBool('isRandomizeFlashcards') ?? false);
    });
  }

  void playSound(String soundPath) async {
    await _player.play(AssetSource(soundPath));
    setState(() {
      isPlaying = true;
    });
  }

  void pauseSound() async {
    await _player.pause();
    setState(() {
      isPlaying = false;
    });
  }

  void playPauseSound(String soundPath) {
    isPlaying ? pauseSound() : playSound(soundPath);
  }

  Future<void> _updatePaletteColor() async {
    if (_shuffledItems.isEmpty) return;
    String imagePath = _shuffledItems[_currentIndex]['image']!;
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
    if (_shuffledItems.isEmpty) return;
    await _player.stop();
    setState(() {
      isPlaying = false;  // Reset the play state when moving to next flashcard
      if (_currentIndex < _shuffledItems.length - 1) {
        _currentIndex++;
        _updatePaletteColor();
        if (_isAudioAutoPlay) {
          playSound(_shuffledItems[_currentIndex]['sound']!.replaceFirst('assets/', ''));
        }
      }
    });
  }

  void _showPreviousFlashcard() async {
    if (_shuffledItems.isEmpty) return;
    await _player.stop();
    setState(() {
      isPlaying = false;  // Reset the play state when moving to previous flashcard
      if (_currentIndex > 0) {
        _currentIndex--;
        _updatePaletteColor();
        if (_isAudioAutoPlay) {
          playSound(_shuffledItems[_currentIndex]['sound']!.replaceFirst('assets/', ''));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_shuffledItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.category),
          backgroundColor: CupertinoColors.activeBlue,  // Same color as the buttons
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: const IconThemeData(color: Colors.white),  // Set icon color to white
        ),
        body: const Center(
          child: Text(
            "No flashcards available.",
            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    }

    String imagePath = _shuffledItems[_currentIndex]['image']!;
    String soundPath = _shuffledItems[_currentIndex]['sound']!.replaceFirst('assets/', '');
    String itemName = _shuffledItems[_currentIndex]['name']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: CupertinoColors.activeBlue,  // Same color as the buttons
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white),  // Set icon color to white
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,  // Make the three-dot menu icon white
            ),
            onSelected: (String value) {
              if (value == 'Settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ).then((_) => _setupFlashcards());  // Reload settings when returning from settings page
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Settings'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            // Swiped left, show next flashcard
            _showNextFlashcard();
          } else if (details.primaryVelocity! > 0) {
            // Swiped right, show previous flashcard
            _showPreviousFlashcard();
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
                        child: _currentIndex < _shuffledItems.length - 1
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
