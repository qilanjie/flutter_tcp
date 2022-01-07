import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_tcp/second_page.dart';
import 'package:flutter_tcp/stores/app.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          // primarySwatch: Colors.purple,
          fontFamily: 'cn'),
      routes: {
        "/second": (context) => SecondPage(),
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English, no country code
        Locale('cn', ''), // Spanish, no country code
      ],
      home: const MyHomePage(title: 'Flutter 演示主页'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final store = Get.put(AppModel());
  var textDelayTime = "";
  var textData="";
  var s = [0x5A, 0xA5, 0x05, 0x01,0x01,0x02,0x03, 0x5A];
  late Timer timer;
 late DateTime first;
  void _incrementCounter() {
    store.counter++;
  }

  @override
  void initState() {
    store.init();
    ServerSocket.bind('0.0.0.0', 2233).then((serverSocket) {
      serverSocket.listen((socket) {
        timer = Timer.periodic(Duration(seconds: 1), (timer) {
first=DateTime.now();
          socket.add(s);
        });
        socket.listen((rev) {
          //       print(rev);
          setState(() {
            textDelayTime= (DateTime.now().difference(first)).inMilliseconds.toString() ;
            textData=rev.toString();
          });
        }, onDone: () {

         timer.cancel();
        });
      });
    });
    // WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void activate() {
    print("activate");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        print("back");
        store.save("counter", store.counter);
        break;
      case AppLifecycleState.resumed:
        print("resumed");
        // TODO: Handle this case.
        break;
      case AppLifecycleState.inactive:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.detached:
        // TODO: Handle this case.

        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this); //销毁观察者
    store.save("counter", store.counter);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '你已经按了这么多次按钮了:',            ),
            Obx(() => Text(
                  store.counter.toString(),
                  style: Theme.of(context).textTheme.headline4,
                )),
            Text("延时(ms):$textDelayTime,     接收数据:$textData"),
            ElevatedButton(
                onPressed: () {
                  store.save("counter", store.counter);
                  Navigator.of(context).pushNamed("/second");
                },
                child: Text("跳转"))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: '增加',
        child: const Icon(Icons.network_check),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
