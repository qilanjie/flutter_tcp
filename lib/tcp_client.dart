import 'dart:io';

class TcpClient{
  static String host='0.0.0.0';
  static int  port=2233;
static     Socket?  mSocket;
  static      Stream<List<int>>?  mStream;
  static initSocket() async{
    await Socket.connect(host,port).then((Socket socket)  {
      mSocket = socket;
      mStream=mSocket?.asBroadcastStream();      //多次订阅的流 如果直接用socket.listen只能订阅一次
    }).catchError((e) {
      print('connectException:$e');
      initSocket();
    });
  }

  static void  addParams(List<int> params){
    mSocket?.add(params);
  }

  static void dispos(){
    mSocket?.close();
  }
}