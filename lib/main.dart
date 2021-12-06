import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//const String LOGOUT_URL = 'http://1.1.1.1';
const String LOGOUT_URL =
    'http://gateway.example.com/loginpages/autologout.shtml';
const String URL = 'http://gateway.example.com/loginpages/userlogin.shtml';
const Map<String, String> PARAMS = {'accesscode': '', 'vlan_id': '106'};

Future<bool> loginToWIFI(String username, String password) async {
  Map<String, String> params = {
    ...PARAMS,
    ...{'username': username, 'password': password}
  };
  try {
    http.Response resp = await _post(URL, params);
    String? loc = resp.headers['location'];
    if (loc != null) return !(loc.startsWith('error_user.shtml'));
    return false;
  } on http.ClientException {
  } catch (e) {}
  return false;
}

Future<bool> logoutOfWifi() async {
  try {
    http.Response resp = await _get(LOGOUT_URL);
    String? loc = resp.headers['Location'];
    if (loc != null)
      return !(loc
          .startsWith('gateway.example.com/loginpages/autologout.shtml'));
    return false;
  } on http.ClientException {
  } catch (e) {}
  return false;
}

Future<http.Response> _get(String url) {
  return http.get(Uri.parse(url));
}

Future<http.Response> _post(String url, Map<String, dynamic> body) {
  return http.post(Uri.parse(url), body: body);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Connect STW', home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class MyText extends Text {
  const MyText(String text)
      : super(text, style: const TextStyle(fontSize: 24.0));
}

class _MyHomePageState extends State<MyHomePage> {
  static const String _defaultSSID = 'STW_CU';
  static const String _defaultUsername = 'softwarica';
  static const String _defaultPassword = 'cov3ntry123';
  // Set(LinkedHashSet) is used cuz to prevent dupe & keep insertion order when iterating.
  final LinkedHashSet<String> _usernames =
      LinkedHashSet.from([_defaultUsername]);
  final LinkedHashSet<String> _passwords =
      LinkedHashSet.from(['cov3ntry123', 'c0v3ntry']);
  //String _ssid = _defaultSSID;
  //String _username = _defaultUsername;
  //String _password = _defaultPassword;
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static const double textFieldMargin = 15.0;
  final ButtonStyle btnStyle = ElevatedButton.styleFrom(
      primary: Colors.blue,
      textStyle: const TextStyle(fontSize: 24.0, letterSpacing: 0.8),
      padding: EdgeInsets.symmetric(horizontal: 46.0, vertical: 8.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50))));
  final ButtonStyle dangerousBtnStyle = ElevatedButton.styleFrom(
      primary: Colors.red,
      textStyle: const TextStyle(fontSize: 24.0, letterSpacing: 0.8),
      padding: EdgeInsets.symmetric(horizontal: 46.0, vertical: 8.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50))));

  @override
  void initState() {
    super.initState();
    _ssidController.addListener(() {});
    _usernameController.addListener(() {});
    _passwordController.addListener(() {});
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const MyText('FSL')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
        //padding: EdgeInsets.symmetric(vertical: 50.0),
        child: SingleChildScrollView(
            // takes as less space as possible
            child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTips(),
        _buildConnect(),
        _buildLoginLogoutButtons(context),
      ],
    )));
  }

  Widget _buildTips() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: const MyText('1. Connect to Wi-Fi.')),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: const MyText('2. Click Start Button at the end.')),
          ]));

  Widget _buildConnect() {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.all(textFieldMargin),
              child: TextField(
                  controller: _ssidController,
                  decoration: const InputDecoration(
                    //border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(10.0),
                    labelText: "Wi-Fi Name",
                  ))),
          Container(
              margin: const EdgeInsets.all(textFieldMargin),
              child: _buildChipsAndTextField(
                  _usernames, 'Username', _usernameController)),
          Container(
              margin: const EdgeInsets.all(textFieldMargin),
              child: _buildChipsAndTextField(_passwords, 'Password', _passwordController)
              )
        ]);
  }

  Widget _buildLoginLogoutButtons(BuildContext ctx) {
    return Container(
        child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_buildLoginButton(ctx), _buildLogoutButton(ctx)])));
  }

  Widget _textChip(String text, LinkedHashSet<String> chips) {
    return InputChip(
      key: ObjectKey(text),
      label: Text(text), // no const constructor due to dynamic text
      onDeleted: () {
        setState(() {
          chips.remove(text);
        });
      },
      //padding: const EdgeInsets.all(0.0),
    );
  }

  /* for both username and password fields */
  Widget _textField(String label, TextEditingController fieldController, LinkedHashSet<String> chips) {
    return TextField(
        controller: fieldController,
        decoration: InputDecoration(
          //border: const OutlineInputBorder(),
          //constraints: const BoxConstraints(maxHeight: 30),
          contentPadding: const EdgeInsets.all(10.0),
          label: Text(label),
        ),
        // not used cuz it would require having textFieldWidthFactor for each fields.
        /* 
        onChanged: (String text) {
          int len = text.characters.length;
          double widthFactor = (len / 40.0);
          // field width will not increase if its below a certain threshold.
          // and after expanding width will not decrease again.
          if (widthFactor < textFieldWidthFactor) return;
          if (widthFactor > 1.0) {
            widthFactor = 1.0;
          }
          setState(() {
            textFieldWidthFactor = widthFactor;
          });
        },
        */
        onSubmitted: (String text) {
          setState(() {
            chips.add(text);
            fieldController.text = '';
          });
        });
  }

  Widget _buildChipsAndTextField(LinkedHashSet<String> chips,
      String textFieldLabel, TextEditingController controller) {
    List<Widget> widgets = [];
    // add chips
    for (String text in chips) {
      // set keeps the order same in case of adding duplicate items. favors us.
      widgets.add(_textChip(text, chips));
    }

    // then add the text-field.
    widgets.add(_textField(textFieldLabel, controller, chips));

    // then wrap all whenever possible.
    return Wrap(
        spacing: 2.0, // gap betn chips
        runSpacing: -10.0, // gap betn lines
        children: widgets);
  }

  Widget _buildLoginButton(BuildContext ctx) {
    return Container(
        child: Center(
            child: ElevatedButton(
                style: btnStyle,
                onPressed: () async {
                  outer: for (String username in _usernames) {
                    for (String password in _passwords) {
                      bool success = await loginToWIFI(username, password);
                      if (success) {
                        _showSnackBar(ctx, 'Success');
                        break outer; // break outer loop which breaks both loops.
                      }
                      else
                        _showSnackBar(ctx, 'Try Again.');
                    }

                  }
                },
                // This is main button. Its width should be bigger.
                child: const MyText('  Start  '))));
  }

  Widget _buildLogoutButton(BuildContext ctx) {
    return Container(
        child: Center(
            child: ElevatedButton(
                style: dangerousBtnStyle,
                onPressed: () async {
                  bool success = await logoutOfWifi();
                  if (success)
                    _showSnackBar(ctx, 'Success');
                  else
                    _showSnackBar(ctx, 'Try Again.');
                },
                child: const MyText('Logout'))));
  }

  void _showSnackBar(BuildContext ctx, String msg) {
    final scaffold = ScaffoldMessenger.of(ctx);
    scaffold.showSnackBar(SnackBar(content: Text(msg)));
  }
}

void main() {
  runApp(const MyApp());
}
