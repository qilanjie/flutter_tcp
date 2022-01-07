
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
class AppModel  extends GetxController {

  var _counter=0.obs;


  set counter(int value) {
    _counter.value = value;
  }

  int get counter => _counter.value ;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();



  init() async {
    final SharedPreferences prefs = await _prefs;

    _counter.value = prefs.getInt("counter")??0;
    print("store init");


  }
  save(String  name,dynamic value) async{
    final SharedPreferences prefs = await _prefs;
    var isOK = await prefs.setInt(name, value);
    if (isOK) {
      _counter.value= prefs.getInt(name)??0;
    }
  }




}