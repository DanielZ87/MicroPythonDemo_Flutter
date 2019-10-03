import 'package:flutter/material.dart';

class MessageModel {
  Color color = Colors.black;
  double x = 0;
  double y = 0;
  double z = 0;

  MessageModel(String message) {
    if (message == null || message.isEmpty) {
      return;
    }

    var components = message.split(";");

    if (components.length < 2) {
      return;
    }

    var colorComponents = components[0].split(",");
    var axisComponents = components[1].split(",");

    if (colorComponents.length < 2 || axisComponents.length < 3) {
      return;
    }

    color = Color.fromARGB(
        255, int.parse(colorComponents[0]), int.parse(colorComponents[1]), 0);
    x = double.parse(axisComponents[0]);
    y = double.parse(axisComponents[1]);
    z = double.parse(axisComponents[2]);
  }
}
