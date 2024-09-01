import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'flashcard_page.dart';
import 'settings_page.dart'; // Import the settings page

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
        backgroundColor: CupertinoColors.activeBlue,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white, // Make the three-dot menu icon white
            ),
            onSelected: (String value) {
              if (value == 'Settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
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
      body: Container(
        color: Colors.white,  // Set the background color to white
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: mainImages.length,
            itemBuilder: (context, index) {
              String category = mainImages[index]['name']!;
              String image = mainImages[index]['image']!;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlashcardPage(
                        category: category,
                        items: categories[category]!,
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black45,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.asset(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,  // Match the width of the image
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          color: Colors.black.withOpacity(0.5),  // Add a slight black overlay for text readability
                          child: Text(
                            category,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,  // Slightly decrease text size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

final Map<String, List<Map<String, String>>> categories = {
  'Pets': [
    {'name': 'Cat', 'image': 'assets/images/cat.webp', 'sound': 'assets/sounds/cat.wav'},
    {'name': 'Dog', 'image': 'assets/images/dog.webp', 'sound': 'assets/sounds/dog.wav'},
    {'name': 'Rabbit', 'image': 'assets/images/rabbit.webp', 'sound': 'assets/sounds/rabbit.wav'},
    {'name': 'Parrot', 'image': 'assets/images/parrot.webp', 'sound': 'assets/sounds/parrot.wav'},
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
    {'name': 'Parrot', 'image': 'assets/gifs/parrot.gif', 'sound': 'assets/sounds/parrot.wav'},
  ],
};

final List<Map<String, String>> mainImages = [
  {'name': 'Pets', 'image': 'assets/images/Pets.webp'},
  {'name': 'Wild Animals', 'image': 'assets/images/Wild Animals.webp'},
  {'name': 'Colors', 'image': 'assets/images/Colors.webp'},
  {'name': 'Pets (Animated)', 'image': 'assets/images/Pets.webp'},
];
