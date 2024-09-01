import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isAudioAutoPlay = false;
  bool _isRandomizeFlashcards = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAudioAutoPlay = (prefs.getBool('isAudioAutoPlay') ?? false);
      _isRandomizeFlashcards = (prefs.getBool('isRandomizeFlashcards') ?? false);
    });
  }

  _toggleAudioAutoPlay(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAudioAutoPlay = value;
      prefs.setBool('isAudioAutoPlay', _isAudioAutoPlay);
    });
  }

  _toggleRandomizeFlashcards(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isRandomizeFlashcards = value;
      prefs.setBool('isRandomizeFlashcards', _isRandomizeFlashcards);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CupertinoColors.activeBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),  // Make the back icon white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Play Audio Automatically'),
              subtitle: const Text('Toggle whether the audio plays automatically when a flashcard is shown'),
              value: _isAudioAutoPlay,
              onChanged: _toggleAudioAutoPlay,
              activeColor: CupertinoColors.activeBlue,
            ),
            SwitchListTile(
              title: const Text('Randomize Flashcards'),
              subtitle: const Text('Toggle whether to randomize flashcards order'),
              value: _isRandomizeFlashcards,
              onChanged: _toggleRandomizeFlashcards,
              activeColor: CupertinoColors.activeBlue,
            ),
          ],
        ),
      ),
    );
  }
}
