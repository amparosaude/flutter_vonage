
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vonage/config/open_tok_config.dart';

class FlutterVonage {
  static const MethodChannel _channel =
      const MethodChannel('flutter_vonage');

  static Future<String> initSession() async {
    dynamic params = {
      'apiKey': OpenTokConfig.apiKey,
      'sessionId': OpenTokConfig.sessionID,
      'token': OpenTokConfig.token
    };

    try {
      await _channel.invokeMethod('initSession', params);

    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
