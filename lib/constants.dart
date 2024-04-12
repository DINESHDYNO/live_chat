import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';


class AppSnackBar{
  static void show(String title, String message,Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
      backgroundColor: color,
      colorText: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
    );

  }
}