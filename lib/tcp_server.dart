import 'dart:async';
import 'dart:io';

class TcpServer {
  static String host = '0.0.0.0';
  static int port = 2233;
  static  Timer? timer;
  static  DateTime? first;
  static  late List<int> s;
  static  ServerSocket? mServersocket;
  static  Socket? mSocket;
  static  Stream<List<int>>? mStream;

  static initServerSocket() async {
    s=[0x5A, 0xA5, 0x05, 0x01,0x01,0x02,0x03, 0x5A];
     await ServerSocket.bind('0.0.0.0', 2233).then((serverSocket) {
      mServersocket = serverSocket;
      serverSocket.listen((socket) {
        mSocket=socket;
        timer = Timer.periodic(Duration(seconds: 1), (timer) {
          first = DateTime.now();
          socket.add(s);
        });
        mStream = socket.asBroadcastStream();//多次订阅的流 如果直接用socket.listen只能订阅一次
      }, onDone: () {
        timer?.cancel();mStream=null;
      });
    }).catchError((e) async{
      print('serverSocketException:$e');
      await Future.delayed(Duration(seconds: 1));
      initServerSocket();
    });
  }

  static void addParams(List<int> params) {
    mSocket?.add(params);
  }

  static void dispos() {
    mSocket?.close();
    mServersocket?.close();
  }
}
