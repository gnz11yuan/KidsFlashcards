import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _currentIndex = widget.initialIndex;  // Start with the initial index
  }

  @override
  void dispose() {
    _player.dispose();  // Dispose of the player when the widget is removed
    super.dispose();
  }

  void playSound(String soundPath) async {
    await _player.stop();  // Stop any sound that's currently playing
    await _player.play(AssetSource(soundPath));  // Play the new sound
  }

  void _showNextFlashcard() async {
    await _player.stop(); // Stop sound when navigating to the next flashcard
    if (_currentIndex < widget.items.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _showPreviousFlashcard() async {
    await _player.stop(); // Stop sound when navigating to the previous flashcard
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
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
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              itemName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  ElevatedButton(
                    onPressed: _showPreviousFlashcard,
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox(width: 100), // Placeholder for spacing
                ElevatedButton(
                  onPressed: () {
                    playSound(soundPath);
                  },
                  child: const Text('Play'),
                ),
                if (_currentIndex < widget.items.length - 1)
                  ElevatedButton(
                    onPressed: _showNextFlashcard,
                    child: const Text('Next'),
                  )
                else
                  const SizedBox(width: 100), // Placeholder for spacing
              ],
            ),
          ],
        ),
      ),
    );
  }
}
