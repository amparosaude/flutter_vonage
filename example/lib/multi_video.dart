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
  static const String sessionID = "1_MX40NjYzMzg2Mn5-MTY2ODExNTk1ODk3Mn4rZXFZcTRBSnJteDlvU09iYnlGTHpSQUF-fg";
  static const String token = "T1==cGFydG5lcl9pZD00NjYzMzg2MiZzaWc9ODhjMTczMmFmNzYzOTdmOGJmM2YyZTMwZWI5NGM4NjJmNjdhYjYxYTpzZXNzaW9uX2lkPTFfTVg0ME5qWXpNemcyTW41LU1UWTJPREV4TlRrMU9EazNNbjRyWlhGWmNUUkJTbkp0ZURsdlUwOWlZbmxHVEhwU1FVRi1mZyZjcmVhdGVfdGltZT0xNjY4MTE1OTU5Jm5vbmNlPTAuOTkxNTg0MDI0OTI2MTA4MyZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNjcwNjIxNTU4JmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9";
}

class MultiVideo extends StatelessWidget {
  const MultiVideo({Key key}) : super(key: key);
  static bool cameraStatus = true;
  static bool microphoneStatus = true;

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
  int subscibersSize = 0;
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
          print(_sdkState);
        }
        break;
      case 'updateSubscribers':
        subscibersSize = methodCall.arguments;
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
            onTap: changeMicrophoneStatus,
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
            onTap: changeCameraStatus,
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

  void changeCameraStatus() {
    if (MultiVideo.cameraStatus) {
      FlutterVonage.disableCamera();
      MultiVideo.cameraStatus = false;
      return;
    }
    FlutterVonage.enableCamera();
    MultiVideo.cameraStatus = true;
  }
  void changeMicrophoneStatus() {
    if (MultiVideo.microphoneStatus) {
      FlutterVonage.disableMicrophone();
      MultiVideo.microphoneStatus = false;
      return;
    }
    FlutterVonage.enableMicrophone();
    MultiVideo.microphoneStatus = true;
  }
}

