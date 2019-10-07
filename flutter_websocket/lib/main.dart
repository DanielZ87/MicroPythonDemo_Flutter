import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' as prefix0;
//import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'models/MessageModel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Welcome'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  WebSocketChannel channel;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _xOffset = 0;
  double _yOffset = 0;
  double _zOffset = 0;

  String _currentEndpoint = 'ws://echo.websocket.org';

  void _showSettingsDialog() async {
    var endpoint = await showDialog<String>(
        context: context,
        builder: (context) {
          return new SettingsDialog(
            connection: _currentEndpoint,
          );
        });

    _onConnect(endpoint);

    setState(() {
      _currentEndpoint = endpoint;
    });
  }

  @override
  void initState() {
    super.initState();

    _onConnect(_currentEndpoint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          ButtonBar(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.settings), onPressed: _showSettingsDialog),
            ],
          )
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Response:',
                    ),
                    getResponseWidget(widget.channel)
                  ],
                ),
              ),
              Visibility(
                visible: _currentEndpoint.contains("echo"),
                child: ExpansionTile(
                  title: Text('Echo control'),
                  children: <Widget>[
                    Text('X: $_xOffset'),
                    Slider(
                      min: -90,
                      max: 90,
                      value: _xOffset,
                      onChanged: (newValue) {
                        setState(() {
                          _xOffset = newValue;
                        });
                        sendManualValues();
                      },
                    ),
                    Text('Y: $_yOffset'),
                    Slider(
                      min: -90,
                      max: 90,
                      value: _yOffset,
                      onChanged: (newValue) {
                        setState(() => _yOffset = newValue);
                        sendManualValues();
                      },
                    ),
                    Text('Z: $_zOffset'),
                    Slider(
                      min: -90,
                      max: 90,
                      value: _zOffset,
                      onChanged: (newValue) {
                        setState(() => _zOffset = newValue);
                        sendManualValues();
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSettingsDialog,
        child: Icon(Icons.settings),
      ),
    );
  }

  void sendManualValues() {
    widget.channel.sink.add('255,0;$_xOffset,$_yOffset,$_zOffset');
  }

  Widget getResponseWidget(WebSocketChannel channel) {
    if (channel == null) {
      return Text('Please connect first');
    }

    return StreamBuilder(
      stream: widget.channel.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error,
                color: Colors.red,
              ),
              Text('${snapshot.error}'),
            ],
          );
        }

        var parsedMessage = MessageModel('${snapshot.data}');

        return Column(
          children: <Widget>[
            Text(
              snapshot.hasData
                  ? '${snapshot.data}'
                  : '${snapshot.connectionState}',
              style: TextStyle(color: parsedMessage.color),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new AxisWidget(
                  title: 'Y = ${parsedMessage.y.toInt()}',
                  parsedMessage: parsedMessage,
                  rotate: (message, matrix) {
                    matrix.rotateX(vector.radians(message.y));
                  },
                ),
                new AxisWidget(
                  title: 'X  = ${parsedMessage.x.toInt()}',
                  parsedMessage: parsedMessage,
                  rotate: (message, matrix) {
                    matrix.rotateY(vector.radians(message.x));
                  },
                ),
                new AxisWidget(
                  title: 'Z = ${parsedMessage.z.toInt()}',
                  parsedMessage: parsedMessage,
                  rotate: (message, matrix) {
                    matrix.rotateZ(vector.radians(message.z));
                  },
                )
              ],
            ),
          ],
        );
      },
    );
  }

  void _onConnect(String endpoint) {
    setState(() {
      widget.channel = HtmlWebSocketChannel.connect(endpoint);

      //widget.channel.sink.add('255,0;45,0,0');
    });
  }

  @override
  void dispose() {
    widget.channel.sink.close();

    super.dispose();
  }
}

class SettingsDialog extends StatelessWidget {
  SettingsDialog({
    Key key,
    @required String connection,
  }) : super(key: key) {
    controller.text = connection;
  }

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Settings'),
      contentPadding: const EdgeInsets.all(10),
      children: <Widget>[
        TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Endpoint'),
        ),
        RaisedButton(
          child: Text("Connect"),
          onPressed: () {
            Navigator.pop(context, controller.text);
          },
        )
      ],
    );
  }
}

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
