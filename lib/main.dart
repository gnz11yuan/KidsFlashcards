import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'flashcard_page.dart';  // Ensure the FlashcardPage is correctly imported

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Flashcards',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Kids Flashcards'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: CupertinoColors.activeBlue,  // Match the AppBar color to the buttons
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white),  // Set icon color to white
      ),
      body: const Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: ImageGridScreen(),
      ),
    );
  }
}

class ImageGridScreen extends StatelessWidget {
  const ImageGridScreen({super.key});

  final Map<String, List<Map<String, String>>> categories = const {
    'Pets': [
      {'name': 'Cat', 'image': 'assets/images/cat.webp', 'sound': 'assets/sounds/cat.wav'},
      {'name': 'Dog', 'image': 'assets/images/dog.webp', 'sound': 'assets/sounds/dog.wav'},
      {'name': 'Rabbit', 'image': 'assets/images/rabbit.webp', 'sound': 'assets/sounds/rabbit.wav'},
    ],
    'Wild Animals': [
      {'name': 'Lion', 'image': 'assets/images/lion.webp', 'sound': 'assets/sounds/lion.wav'},
      {'name': 'Elephant', 'image': 'assets/images/elephant.webp', 'sound': 'assets/sounds/elephant.wav'},
      {'name': 'Tiger', 'image': 'assets/images/tiger.webp', 'sound': 'assets/sounds/tiger.wav'},
    ],
    'Colors': [
      {'name': 'Red', 'image': 'assets/images/red.webp', 'sound': 'assets/sounds/red.wav'},
      {'name': 'Blue', 'image': 'assets/images/blue.webp', 'sound': 'assets/sounds/blue.wav'},
      {'name': 'Green', 'image': 'assets/images/green.webp', 'sound': 'assets/sounds/green.wav'},
    ],
    'Pets (Animated)': [
      {'name': 'Cat', 'image': 'assets/gifs/cat.gif', 'sound': 'assets/sounds/cat.wav'},
      {'name': 'Dog', 'image': 'assets/gifs/dog.gif', 'sound': 'assets/sounds/dog.wav'},
      {'name': 'Rabbit', 'image': 'assets/gifs/rabbit.gif', 'sound': 'assets/sounds/rabbit.wav'},
    ],
  };

  final List<Map<String, String>> mainImages = const [
    {'name': 'Pets', 'image': 'assets/images/Pets.webp'},
    {'name': 'Wild Animals', 'image': 'assets/images/Wild Animals.webp'},
    {'name': 'Colors', 'image': 'assets/images/Colors.webp'},
    {'name': 'Pets (Animated)', 'image': 'assets/images/Pets.webp'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns in the grid
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: mainImages.length,
        itemBuilder: (context, index) {
          String category = mainImages[index]['name']!;
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlashcardPage(
                    category: category,
                    items: categories[category]!,
                    initialIndex: 0,  // Corrected to match the constructor in FlashcardPage
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(
                    mainImages[index]['image']!,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(category, style: const TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
