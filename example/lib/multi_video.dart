import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vonage/flutter_vonage.dart';
import 'package:flutter_vonage/publisher.dart';
import 'package:flutter_vonage/subscriber.dart';
import 'package:flutter_vonage_example/src/config/sdk_states.dart';
import 'package:permission_handler/permission_handler.dart';

class OpenTokConfig {
  static const String apiKey = "";
  static const String sessionID = "2_MX40NjYzMzg2Mn5-MTY2Nzc4OTgwNTE0MX5mTjZ1Zi8vTzZTamVWbGdqMDluRFg5UGF-fg";
  static const String token = "T1==cGFydG5lcl9pZD00NjYzMzg2MiZzaWc9OGNhNDE5MjdmN2E3ZGY2NzBiNmU1MzlmZjJiZDRiMzRhNzAwZTIxYzpzZXNzaW9uX2lkPTJfTVg0ME5qWXpNemcyTW41LU1UWTJOemM0T1Rnd05URTBNWDVtVGpaMVppOHZUelpUYW1WV2JHZHFNRGx1UkZnNVVHRi1mZyZjcmVhdGVfdGltZT0xNjY3Nzg5ODA1Jm5vbmNlPTAuMTYxODYyOTg4OTIyNDQyNzcmcm9sZT1wdWJsaXNoZXImZXhwaXJlX3RpbWU9MTY3MDI5NTQwNSZpbml0aWFsX2xheW91dF9jbGFzc19saXN0PQ==";
}

class MultiVideo extends StatelessWidget {
  const MultiVideo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Multi Party Video"),
        ),
        body: const CallWidget(title: 'Multi Party Video')
    );
  }
}

class CallWidget extends StatefulWidget {
  const CallWidget({Key key = const Key("any_key"), @required this.title}) : super(key: key);
  final String title;

  @override
  _CallWidgetState createState() => _CallWidgetState();
}

class _CallWidgetState extends State<CallWidget> {
  SdkState _sdkState = SdkState.loggedOut;

  static const platformMethodChannel = MethodChannel('com.vonage.multi_video');

  _CallWidgetState() {
    platformMethodChannel.setMethodCallHandler(methodCallHandler);
    initSession();
  }

  Future<dynamic> methodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'updateState':
        {
          setState(() {
            var arguments = 'SdkState.${methodCall.arguments}';
            _sdkState = SdkState.values.firstWhere((v) {
              return v.toString() == arguments;
            });
          });
        }
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  Future<void> requestPermissions() async {
    await [Permission.microphone, Permission.camera].request();
  }

  void initSession() async {
    await requestPermissions();
    await FlutterVonage.initSession(
      apiKey: OpenTokConfig.apiKey,
      sessionId: OpenTokConfig.sessionID,
      token: OpenTokConfig.token,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _updateView()
    );
  }


  Widget renderButtons() {
    return Container(
      margin: EdgeInsets.only(bottom: 34),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(
                Icons.mic_off_rounded,
                size: 32,
                color: Colors.red,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 25),
            child: GestureDetector(
              onTap: FlutterVonage.endSession,
              child: Container(
                padding: EdgeInsets.all(15),
                child: Icon(
                  Icons.phone,
                  size: 32,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(
                Icons.videocam_off,
                size: 32,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _updateView() {
    if (_sdkState == SdkState.loggedOut) {
      return ElevatedButton(
          onPressed: () {
            initSession();
          },
          child: const Text("Init session"));
    } else if (_sdkState == SdkState.wait) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_sdkState == SdkState.loggedIn) {
      return Container(
        width: double.maxFinite,
        child: Stack(
          children: [
            Subscriber(),
            Align(
              alignment: Alignment.bottomCenter,
              child: renderButtons(),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 90,
                height: 120,
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(2),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Publisher()),
              ),
            ),
          ],
        ),
      );
    } else {
      return const Center(child: Text("ERROR"));
    }
  }
}

