import 'package:flutter/material.dart';
import 'package:flutter_vonage/flutter_vonage.dart';
import 'multi_video.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Flutter Video SDK Samples"),
        ),
        body:
        Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[const SizedBox(), _updateView(context)],
            )
    ));
  }
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
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 25),
          child: GestureDetector(
            onTap: FlutterVonage.endSession(),
            child: Container(
              padding: EdgeInsets.all(15),
              child: Icon(
                Icons.phone,
                color: Colors.red,
                size: 32,
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
            ),
          ),
        ),
      ],
    ),
  );
}


Widget _updateView(BuildContext context) {
    return
      Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MultiVideo())
                    );
                  }, child: const Text("Multi Party Video Call")),

                ]),
          ]
      );
}
