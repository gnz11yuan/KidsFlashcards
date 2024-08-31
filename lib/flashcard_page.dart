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

  void playSound(String soundPath) async {
    await _player.stop();
    await _player.play(AssetSource(soundPath));
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
    if (_currentIndex < widget.items.length - 1) {
      setState(() {
        _currentIndex++;
        _updatePaletteColor();
      });
    }
  }

  void _showPreviousFlashcard() async {
    await _player.stop();
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _updatePaletteColor();
      });
    }
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
      body: Stack(
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
                  color: dominantColor!.withOpacity(0.5),
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
                    playSound(soundPath);
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentIndex > 0)
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        color: CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.circular(8.0),
                        onPressed: _showPreviousFlashcard,
                        child: const Text('Previous'),
                      )
                    else
                      const SizedBox(width: 120), // Placeholder for spacing
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                      color: CupertinoColors.activeBlue,
                      borderRadius: BorderRadius.circular(8.0),
                      onPressed: () {
                        playSound(soundPath);
                      },
                      child: const Text('Play'),
                    ),
                    if (_currentIndex < widget.items.length - 1)
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        color: CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.circular(8.0),
                        onPressed: _showNextFlashcard,
                        child: const Text('Next'),
                      )
                    else
                      const SizedBox(width: 120), // Placeholder for spacing
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
