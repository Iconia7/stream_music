import 'package:get/get.dart';
import 'package:project/views/screens/login.dart';

class LoginController extends GetxController {
  var name = "".obs;
  var a = 0.obs;

  input(sname, num1) {
    name.value = sname;
    pass.value = num1; 
  }
}