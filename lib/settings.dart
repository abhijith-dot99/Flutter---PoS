import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool showImages;
  final ValueChanged<bool> onShowImagesChanged;

  const SettingsPage({
    Key? key,
    required this.showImages,
    required this.onShowImagesChanged,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _showImages;

  @override
  void initState() {
    super.initState();
    _showImages = widget.showImages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1f2029),
      appBar: AppBar(
        backgroundColor: const Color(0xff2c2f36),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the back arrow color to white
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
                  color: Colors.white,
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
          ],
        ),
      ),
    );
  }
}
