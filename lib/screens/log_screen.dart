import 'package:flutter/material.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class MyText extends Text {
  const MyText(String text)
      : super(text, style: const TextStyle(fontSize: 24.0));
}

class _LogScreenState extends State<LogScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MyText('🚀...'),
        backgroundColor: Colors.black,
      ),
      body: _buildOutputText(),
    );
  }


  Widget _buildOutputText() {
    return Text('hi');
  }

}
