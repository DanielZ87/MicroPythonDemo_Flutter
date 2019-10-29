import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_websocket/models/MessageModel.dart';
import 'package:vector_math/vector_math.dart' as vector;

class AxisWidget extends StatefulWidget {
  const AxisWidget({
    Key key,
    @required this.parsedMessage,
    @required this.rotate,
    @required this.rotationValueAccessor,
    @required this.title,
  }) : super(key: key);

  final MessageModel parsedMessage;
  final Function(double radians, Matrix4 matrix) rotate;
  final double Function(MessageModel, Offset) rotationValueAccessor;
  final String title;

  @override
  _AxisWidgetState createState() => _AxisWidgetState();
}

class _AxisWidgetState extends State<AxisWidget> {
  Offset _offset = Offset.zero;

  String getBoardImageFromAngle(double angleInDegrees) {
    return cos(vector.radians(angleInDegrees)) <= 0
        ? 'assets/images/PyBoardBack.png'
        : 'assets/images/PyBoard.png';
  }

  @override
  Widget build(BuildContext context) {
    var rotationMatrix = Matrix4.identity()..setEntry(3, 2, 0.00027);

    var rotationValue =
        widget.rotationValueAccessor(widget.parsedMessage, _offset);

    rotationValue =
        widget.parsedMessage.z < 0 ? 180 - rotationValue : rotationValue;

    widget.rotate(vector.radians(rotationValue), rotationMatrix);

    return Column(
      children: <Widget>[
        Chip(
          label: Text('${widget.title}'),
        ),
        GestureDetector(
          onDoubleTap: () => setState(() => _offset = Offset.zero),
          onPanUpdate: (details) => setState(() => _offset += details.delta),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Transform(
              transform: rotationMatrix,
              alignment: FractionalOffset.center,
              child: SizedBox(
                height: 300,
                // width: 100,
                child: Container(
                  child: Image.asset(
                    getBoardImageFromAngle(rotationValue),
                  ),
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Colors.grey[400],
                      blurRadius: 5.0,
                      spreadRadius: 3.0,
                      offset: Offset(
                        0.0,
                        5.0,
                      ),
                    )
                  ], color: widget.parsedMessage.color),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
