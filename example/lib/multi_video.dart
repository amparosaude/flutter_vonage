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
    print('CHECOU AQUI');
    print(methodCall.method);
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
    await FlutterVonage.initSession();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _updateView()
    );
  }

  Widget _updateView() {
    print('>>>>>>>>>>>>>>');
    print(_sdkState);
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

