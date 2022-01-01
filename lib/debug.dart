import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/log_screen.dart' show LogStore;

class debug {
  static Locator? read;
  
  debug(String text) {
    print(text);
    if (read != null) {
      //Provider.of<LogStore>(read!, listen: false).appendLn(text);
      read!<LogStore>().appendLn(text);
    }
  }

  static void init(Locator ctx) {
    read = ctx;
  }

}


//void debug(BuildContext ctx, String text) {
//  Provider.of<LogStore>(ctx, listen: false).appendLn(text);
//  print(text);
//}
