import 'dart:io';
import 'dart:convert';
import 'package:connstw/models/release/asset.dart';
import 'package:connstw/models/release/release.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'session.dart' show Session;


const String LOGIN_URL = 'http://gateway.example.com/loginpages/userlogin.shtml';
const String LOGIN_FAIL_PATH = 'error_user.shtml';
//const String LOGOUT_URL = 'http://1.1.1.1';sme
const String LOGOUT_URL =
    'http://gateway.example.com/loginpages/autologout.shtml';
const String LOGOUT_FAIL_URL = 'gateway.example.com/loginpages/autologout.shtml';
const Map<String, String> PARAMS = {'accesscode': '', 'vlan_id': '106'};


Future<bool> loginToWIFI(String username, String password) async {
  print('Trying ${username}, ${password} ');
  Map<String, String> params = {
    ...PARAMS,
    ...{'username': username, 'password': password}
  };
  try {
    Session sess = Session();
    HttpClientResponse? resp;
    try {
      resp = await sess.post(LOGIN_URL, body: params);
    } finally {
      sess.close(resp);
    }
    // even tho response is closed/drained. it can still be read.
    for (RedirectInfo redirect in resp.redirects) {
      String locHeader = redirect.location.toString();
      print('LOCATION: ${locHeader}');
      if (locHeader.startsWith(LOGIN_FAIL_PATH)) return false;
    }
    // HttpClient doesn't seem to redirect even on 302. check location header again.
    String? locHeader = resp.headers.value(HttpHeaders.locationHeader);
    if (locHeader != null) {
      if (locHeader.startsWith(LOGIN_FAIL_PATH)) return false;
    }

    return true;
  } catch (e) {}
  return false;
}

Future<bool> logoutOfWIFI() async {
  try {
    Session sess = Session();
    HttpClientResponse? resp;
    try {
      resp = await sess.get(LOGOUT_URL);
    } finally {
      sess.close(resp);
    }

    for (RedirectInfo redirect in resp.redirects) {
      String locHeader = redirect.location.toString();
      if (locHeader.startsWith(LOGOUT_FAIL_URL)) return true;
    }
    return true;
  } catch (e) {}
  return false;
}


Future<BasicRelease?> latestGHRelease(String repoName) async {
  String originReleaseUrl = 'https://api.github.com/repos/$repoName/releases/latest';
  String? contents;
  Session sess = Session();
  try {
    contents = await sess.getAndText(originReleaseUrl);
  }
  catch (e) {}
  finally {
    sess.close();
  }
  if (contents != null) {
    Release release = Release.fromJson(jsonDecode(contents));
    String? tag = release.tagName;
    String? url;
    for (Asset asset in release.assets) {
      if (asset.contentType == 'application/vnd.android.package-archive') {
        url = asset.browserDownloadUrl;
        break;
      }
    }
    if (tag != null && url != null) {
      return BasicRelease(tag, Uri.parse(url));
    }
  }
  return null;
}

class BasicRelease {
  late final String tag;
  late final Uri downloadUrl;
  BasicRelease(this.tag, this.downloadUrl);
}

class LocalStore {
  static const ukey = 'fast_gateway_login';
  static SharedPreferences? _prefs;

  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static setString(String key, String val) {
    _prefs?.setString(ukey + key, val);
    print('setting string: ${val}');
  }

  static String? getString(String key) {
    print('getting string with key: ${ukey + key}');
    return _prefs?.getString(ukey + key);
  }

  static setList(String key, List<String> val) {
    _prefs?.setStringList(ukey + key, val);
    print('setting list: ${val}');
  }

  static List<String>? getList(String key) {
    print('getting list with key: ${ukey + key}');
    return _prefs?.getStringList(ukey + key);
  }
}