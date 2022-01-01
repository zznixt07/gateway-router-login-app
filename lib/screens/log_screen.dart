import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // mixin syntax
import 'package:provider/provider.dart';


class LogStore with ChangeNotifier {
  String output = '';

  void appendLn(String text) {
    output += text + '\n';
    notifyListeners();
  }

}

class LogScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _buildOutputText(context),
      )
    );
  }

  Widget _buildOutputText(BuildContext context) {
    final logged = Provider.of<LogStore>(context).output;
    return Text(logged);
  }

}
