
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vonage/config/open_tok_config.dart';
import 'package:flutter_vonage/publisher.dart';
import 'package:flutter_vonage/subscriber.dart';

class FlutterVonage {
  static const MethodChannel _channel =
      const MethodChannel('flutter_vonage');

  static Future<String> initSession({
    @required String apiKey,
    @required String sessionId,
    @required String token}) async {
    dynamic params = {
      'apiKey': apiKey,
      'sessionId': sessionId,
      'token': token
    };

    try {
      await _channel.invokeMethod('initSession', params);

    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static endSession() async {
    await _channel.invokeMethod('endSession');
  }
  static Widget PublisherView() {
    return Publisher();
  }
  static Widget SubscriberView() {
    return Subscriber();
  }
}
