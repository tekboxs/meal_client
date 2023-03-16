import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

@pragma('vm:entry-point')
void isolate2(String arg) async {
  await Future.delayed(const Duration(seconds: 4));
  log('messagem from iso2');
}

@pragma('vm:entry-point')
void isolate1(String arg) async {
  await Future.delayed(const Duration(seconds: 2));
  log('messagem from iso1');
}

go() async {
  await Future.delayed(const Duration(seconds: 1));
  log('messagem from gooo');
}

@pragma('vm:entry-point')
computeFunction(String arg) async {
  await Future.delayed(const Duration(seconds: 1));
  log('messagem from $arg');
}

void save(val) async {
  await Future.delayed(const Duration(seconds: 2));
  print('saved $val');
}

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: theme,
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: AppWidget()));
  }
}

ThemeData theme = ThemeData(
    inputDecorationTheme:
        const InputDecorationTheme(filled: true, fillColor: Colors.red));

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      ElevatedButton(
        onPressed: () async {
          save('val1');
          save('val2');
          save('val3');
          save('val4');
          save('val5');

          log('message main');
        },
        child: const Text('Spawn isolates'),
      ),
      ElevatedButton(
        onPressed: () async {
          log('message main 2');
        },
        child: const Text('sss'),
      ),
      ElevatedButton(
        child: const Text('Check running isolates'),
        onPressed: () async {
          final isolates = await FlutterIsolate.runningIsolates;
          await showDialog(
              builder: (ctx) {
                return Center(
                    child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(5),
                        child: Column(
                            children: isolates
                                    .map((i) => Text(i))
                                    .cast<Widget>()
                                    .toList() +
                                [
                                  ElevatedButton(
                                      child: const Text("Close"),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      })
                                ])));
              },
              context: context);
        },
      ),
      ElevatedButton(
        child: const Text('Kill all running isolates'),
        onPressed: () async {
          await FlutterIsolate.killAll();
        },
      ),
      ElevatedButton(
        child: const Text('Run in compute function'),
        onPressed: () async {
          await flutterCompute(computeFunction, "foo");
        },
      ),
    ]);
  }
}
