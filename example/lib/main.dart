import 'package:flutter/material.dart';
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
