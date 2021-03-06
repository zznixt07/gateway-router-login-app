import 'dart:io';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:flash/flash.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:provider/provider.dart';
import 'session.dart' show Session;
import 'screens/log_screen.dart';
import 'debug.dart';
import 'utils.dart'
    show
        loginToWIFI,
        logoutOfWIFI,
        LocalStore,
        getAppVer,
        latestGHRelease,
        BasicRelease,
        versionToInt;

const String ORIGIN_REPO = 'zznixt07/gateway-router-login-app';
final LogStore logstore = LogStore();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Quick Connect',
        home: ChangeNotifierProvider<LogStore>(
            create: (context) => logstore, child: MyHomePage()));
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
  bool checkForUpdates = LocalStore.getBool('_checkUpdates') ?? true;
  // these are used as key for k-v db store.
  static const usernameFieldLabel = 'Username';
  static const passwordFieldLabel = 'Password';
  // Set(LinkedHashSet) is used cuz to prevent dupe & keep insertion order when iterating.
  final LinkedHashSet<String> _usernames =
      LinkedHashSet.from(LocalStore.getList('_${usernameFieldLabel}') ?? []);
  final LinkedHashSet<String> _passwords =
      LinkedHashSet.from(LocalStore.getList('_${passwordFieldLabel}') ?? []);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static const double textFieldMargin = 15.0;
  final ButtonStyle btnStyle = ElevatedButton.styleFrom(
      primary: Colors.blue,
      textStyle: const TextStyle(fontSize: 24.0, letterSpacing: 0.8),
      padding: EdgeInsets.symmetric(horizontal: 46.0, vertical: 10.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50))));
  final ButtonStyle dangerousBtnStyle = ElevatedButton.styleFrom(
      primary: Colors.red,
      textStyle: const TextStyle(fontSize: 24.0, letterSpacing: 0.8),
      padding: EdgeInsets.symmetric(horizontal: 46.0, vertical: 10.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50))));
  final ButtonStyle bwBtnStyle =
      ElevatedButton.styleFrom(primary: Colors.black);

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() {});
    _passwordController.addListener(() {});
    if (checkForUpdates) _checkUpdates();
    debug.init(context.read);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const MyText('????...'),
        backgroundColor: Colors.black,
      ),
      endDrawer: Drawer(child: _buildDrawer(context)),
      body: _buildBody(context),
    )));
  }

  Widget _buildDrawer(BuildContext context) =>
      ListView(padding: EdgeInsets.zero, children: <Widget>[
        DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Drawer Head')),
        ListTile(
            leading: Icon(Icons.message),
            onTap: () {
              // close the drawer first
              Navigator.pop(context);

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChangeNotifierProvider<LogStore>.value(
                              value: logstore, child: LogScreen())));
            },
            title: Text('Logs')),
      ]);

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
        //padding: EdgeInsets.symmetric(vertical: 50.0),
        child: Container(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTips(),
        _buildConnect(context),
        _buildLoginLogoutButtons(context),
      ],
    )));
  }

  Widget _buildTips() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: const MyText('Fast Gateway Login.')),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: const Text('Text fields support multiple values.')),
            Container(
                //margin: const EdgeInsets.all(textFieldMargin),
                child: ElevatedButton(
                    style: bwBtnStyle,
                    child: const Text('Enable Wifi'),
                    onPressed: () async {
                      await WiFiForIoTPlugin.setEnabled(true);
                    })),
          ]));

  Widget _buildConnect(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.all(textFieldMargin),
              child: _buildChipsAndTextField(
                  _usernames, usernameFieldLabel, _usernameController)),
          Container(
              margin: const EdgeInsets.all(textFieldMargin),
              child: _buildChipsAndTextField(
                  _passwords, passwordFieldLabel, _passwordController))
        ]);
  }

  Widget _buildLoginLogoutButtons(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 30.0),
        child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              _buildLoginButton(context),
              _buildLogoutButton(context)
            ])));
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
    );
  }

  /* for both username and password fields */
  Widget _textField(String label, TextEditingController fieldController,
      LinkedHashSet<String> chips) {
    return TextField(
      controller: fieldController,
      decoration: InputDecoration(
        //border: const OutlineInputBorder(),
        //constraints: const BoxConstraints(maxHeight: 30),
        contentPadding: const EdgeInsets.all(5.0),
        label: Text(label),
      ),
      onSubmitted: (String text) {
        setState(() {
          chips.add(text);
          // set field to blank text
          fieldController.text = '';
        });
      },
    );
  }

  Widget _buildChipsAndTextField(LinkedHashSet<String> chips,
      String textFieldLabel, TextEditingController controller) {
    List<Widget> widgets = [];
    // add chips
    for (String text in chips) {
      // set keeps the order same in case of adding duplicate items. favors us.
      widgets.add(_textChip(text, chips));
    }

    // update db everytime this widget renders.
    LocalStore.setList('_${textFieldLabel}', chips.toList());

    // then add the text-field.
    widgets.add(_textField(textFieldLabel, controller, chips));

    // then wrap all whenever possible.
    return Wrap(
        spacing: 2.0, // gap betn chips
        runSpacing: -10.0, // gap betn lines
        children: widgets);
  }

  Widget _buildLoginButton(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        child: Center(
            child: ElevatedButton(
                style: btnStyle,
                onPressed: () async {
                  // check if input cred fields have any texts. if it has, add it to chips.
                  if (_usernameController.text != '') {
                    setState(() {
                      _usernames.add(_usernameController.text);
                      // dont erase text.
                    });
                  }

                  // repeat above for password field.
                  if (_passwordController.text != '') {
                    setState(() {
                      _passwords.add(_passwordController.text);
                    });
                  }

                  outer:
                  for (String username in _usernames) {
                    for (String password in _passwords) {
                      String info = 'Trying ${username}, ${password}';
                      //_showSnackBar(context, info);
                      bool success = await loginToWIFI(username, password);
                      if (success) {
                        _showSnackBar(context, 'Success: ${info}',
                            bgcolor: Colors.green.shade900);
                        break outer; // break outer loop which breaks both loops.
                      } else
                        _showSnackBar(context, 'Error: ${info}',
                            bgcolor: Colors.grey.shade900);
                    }
                  }
                },
                // This is main button. Its width should be bigger.
                child: const MyText('  Login  '))));
  }

  Widget _buildLogoutButton(BuildContext context) {
    //final LogStore logClass = Provider.of<LogStore>(context, listen: false);
    //final LogStore logClass = context.read<LogStore>();
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        child: Center(
            child: ElevatedButton(
                style: dangerousBtnStyle,
                onPressed: () async {
                  debug('logging out');
                  bool success = await logoutOfWIFI();
                  if (success)
                    _showSnackBar(context, 'Logout Success',
                        bgcolor: Colors.green.shade900);
                  else
                    _showSnackBar(context, 'Logout failed',
                        bgcolor: Colors.grey.shade900);
                },
                child: const MyText('Logout'))));
  }

  void _showSnackBar(BuildContext context, String msg,
      {Color bgcolor = Colors.transparent, int duration = 1}) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(
        backgroundColor: bgcolor,
        content: Text(msg),
        duration: Duration(seconds: duration)));
  }

  Future<void> _checkUpdates() async {
    String currVer = await getAppVer();
    BasicRelease? release = await latestGHRelease(ORIGIN_REPO);
    if (release == null) return;
    debug('release found');
    String originVer = release.tag;
    String url = release.downloadUrl.toString();
    if (versionToInt(originVer) > versionToInt(currVer)) {
      debug('new update available from $url');
      context.showFlashDialog(
          persistent: true,
          title: const Text('Update available'),
          content: Text(
              'A new version of the app is available. Upgrade from v$currVer to $originVer?'),
          negativeActionBuilder: (context, controller, _) {
            return TextButton(
              onPressed: () {
                controller.dismiss();
              },
              child: Text('No'),
            );
          },
          positiveActionBuilder: (context, controller, _) {
            return TextButton(
                onPressed: () async {
                  bool launched = await url_launcher.launch(url);
                  if (!launched) {
                    debug('Cannot launch url: $url');
                    _showSnackBar(context, 'Cannot launch url: $url',
                        bgcolor: Colors.black, duration: 2);
                  }
                  controller.dismiss();
                },
                child: Text('Yes'));
          });
    }
  }
}

Future<void> main() async {
  // SharedPreferences fails without this.
  WidgetsFlutterBinding.ensureInitialized();
  // init key-value db before running app.
  await LocalStore.init();
  runApp(const MyApp());
}
