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

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAudioAutoPlay = (prefs.getBool('isAudioAutoPlay') ?? false);
    });
  }

  _toggleAudioAutoPlay(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAudioAutoPlay = value;
      prefs.setBool('isAudioAutoPlay', _isAudioAutoPlay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: CupertinoColors.activeBlue,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Play Audio Automatically'),
              subtitle: const Text('Toggle whether the audio plays automatically when a flashcard is shown'),
              value: _isAudioAutoPlay,
              onChanged: _toggleAudioAutoPlay,
              activeColor: CupertinoColors.activeBlue,
            ),
            // Add more settings options as needed
          ],
        ),
      ),
    );
  }
}
