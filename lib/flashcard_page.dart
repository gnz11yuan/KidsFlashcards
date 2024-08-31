import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class FlashcardPage extends StatelessWidget {
  final String category;
  final List<Map<String, String>> items;
  final int index;

  const FlashcardPage({
    super.key,
    required this.category,
    required this.items,
    required this.index,
  });

  void playSound(String soundPath) async {
    final player = AudioPlayer();
    await player.play(AssetSource(soundPath));
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = items[index]['image']!;
    String soundPath = items[index]['sound']!;
    String itemName = items[index]['name']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
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
                if (index > 0)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlashcardPage(
                            category: category,
                            items: items,
                            index: index - 1,
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
                if (index < items.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlashcardPage(
                            category: category,
                            items: items,
                            index: index + 1,
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
