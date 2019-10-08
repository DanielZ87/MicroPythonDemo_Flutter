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

  @override
  Widget build(BuildContext context) {
    var rotationMatrix = Matrix4.identity()..setEntry(3, 2, 0.001);

    var rotationValue =
        widget.rotationValueAccessor(widget.parsedMessage, _offset);

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
                ], color: widget.parsedMessage.color),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
