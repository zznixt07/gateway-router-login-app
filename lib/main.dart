import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String LOGOUT_URL = 'http://1.1.1.1';
const String URL = 'http://gateway.example.com/loginpages/userlogin.shtml';
const Map<String, String> PARAMS = {
  'accesscode': '',
  'vlan_id': '106'
};

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
  } catch (e) {
  }
  return false;
}

Future<bool> logoutOfWifi() async {
  try {
    http.Response resp = await _get(LOGOUT_URL);
    String? loc = resp.headers['Location'];
    if (loc != null) return !(loc.startsWith('gateway.example.com/loginpages/autologout.shtml'));
    return false;
  } on http.ClientException {
  } catch (e) {
  }
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
  static const double textFieldMargin = 10.0;
  String _ssid = _defaultSSID;
  String _username = _defaultUsername;
  String _password = _defaultPassword;
  final TextEditingController _ssidController =
      TextEditingController(text: _defaultSSID);
  final TextEditingController _usernameController =
      TextEditingController(text: _defaultUsername);
  final TextEditingController _passwordController =
      TextEditingController(text: _defaultPassword);
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
    _ssidController.addListener(() => _ssid = _ssidController.text);
    _usernameController.addListener(() => _username = _usernameController.text);
    _passwordController.addListener(() => _password = _passwordController.text);
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
      appBar: AppBar(title: const MyText('Fast STW Login')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTips(),
        _buildConnect(),
        _buildLoginLogoutButtons(context),
      ],
    );
  }

  Widget _buildTips() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: const MyText('1. Connect to STW_CU')),
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
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(10.0),
                    labelText: "Wi-Fi Name",
                  ))),
          Container(
              margin: const EdgeInsets.all(textFieldMargin),
              child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(10.0),
                    labelText: "Username",
                  ))),
          Container(
              margin: const EdgeInsets.all(textFieldMargin),
              child: TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(10.0),
                    labelText: "Password",
                  )))
        ]);
  }

  Widget _buildLoginLogoutButtons(BuildContext ctx) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLoginButton(ctx),
            _buildLogoutButton(ctx)
          ]
        )
      )
    );
  }

  Widget _buildLoginButton(BuildContext ctx) {
    return Container(
        child: Center(
            child: ElevatedButton(
                style: btnStyle,
                onPressed: () async {
                  bool success = await loginToWIFI(_username, _password);
                  if (success) _showSnackBar(ctx, 'Success');
                  else _showSnackBar(ctx, 'Try Again.');
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
                  if (success) _showSnackBar(ctx, 'Success');
                  else _showSnackBar(ctx, 'Try Again.');
                },
                child: const MyText('Logout'))));
  }

  void _showSnackBar(BuildContext ctx, String msg) {
    final scaffold = ScaffoldMessenger.of(ctx);
    scaffold.showSnackBar(SnackBar(
        content: Text(msg)
      ));
  }

}

void main() {
  runApp(const MyApp());
}