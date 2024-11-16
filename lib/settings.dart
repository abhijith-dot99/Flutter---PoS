import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool showImages;
  final ValueChanged<bool> onShowImagesChanged;
  final bool a4;
  final ValueChanged<bool> ona4Changed;

  const SettingsPage({
    Key? key,
    required this.showImages,
    required this.onShowImagesChanged,
    required this.a4,
    required this.ona4Changed
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _showImages;
  late bool _a4;

  @override
  void initState() {
    super.initState();
    _showImages = widget.showImages;
    _a4 = widget.a4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(155, 239, 241, 241),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black54, // Set the back arrow color to white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text(
                'Show Images',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              value: _showImages,
              onChanged: (value) {
                setState(() {
                  _showImages = value;
                });
                widget.onShowImagesChanged(value);
              },
            ),
            SwitchListTile(
              title: const Text(
                'A4',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              value: _a4,
              onChanged: (value) {
                setState(() {
                  _a4 = value;
                });
                widget.ona4Changed(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
