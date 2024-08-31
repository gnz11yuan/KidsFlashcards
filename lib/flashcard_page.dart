import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class FlashcardPage extends StatefulWidget {
  final String category;
  final List<Map<String, String>> items;
  final int index;

  const FlashcardPage({
    super.key,
    required this.category,
    required this.items,
    required this.index,
  });

  @override
  _FlashcardPageState createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
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

  @override
  Widget build(BuildContext context) {
    String imagePath = widget.items[widget.index]['image']!;
    String soundPath = widget.items[widget.index]['sound']!.replaceFirst('assets/', '');
    String itemName = widget.items[widget.index]['name']!;

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
            SizedBox(
              width: 500,
              height: 500,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.index > 0)
                  ElevatedButton(
                    onPressed: () {
                      _player.stop();  // Stop sound when navigating away
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlashcardPage(
                            category: widget.category,
                            items: widget.items,
                            index: widget.index - 1,
                          ),
                        ),
                      );
                    },
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
                if (widget.index < widget.items.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      _player.stop();  // Stop sound when navigating away
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlashcardPage(
                            category: widget.category,
                            items: widget.items,
                            index: widget.index + 1,
                          ),
                        ),
                      );
                    },
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
