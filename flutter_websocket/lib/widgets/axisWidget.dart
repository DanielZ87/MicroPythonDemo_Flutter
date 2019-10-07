import 'package:flutter/material.dart';
import 'package:flutter_websocket/models/MessageModel.dart';

class AxisWidget extends StatelessWidget {
  const AxisWidget({
    Key key,
    @required this.parsedMessage,
    @required this.rotate,
    @required this.title,
  }) : super(key: key);

  final MessageModel parsedMessage;
  final Function(MessageModel, Matrix4) rotate;
  final String title;

  @override
  Widget build(BuildContext context) {
    var rotationMatrix = Matrix4.identity()..setEntry(3, 2, 0.001);

    rotate(parsedMessage, rotationMatrix);

    return Column(
      children: <Widget>[
        Chip(
          label: Text('$title'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Transform(
            transform: rotationMatrix,
            alignment: FractionalOffset.center,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey[400],
                  blurRadius: 20.0,
                  spreadRadius: 3.0,
                  offset: Offset(
                    0.0,
                    10.0,
                  ),
                )
              ], color: parsedMessage.color),
            ),
          ),
        ),
      ],
    );
  }
}