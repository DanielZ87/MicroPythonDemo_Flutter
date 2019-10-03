import 'dart:math';
import 'package:flutter/material.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;

  double _xOffset = 0;
  double _yOffset = 45;
  double _zOffset = 0;

  final TextEditingController _connectionController =
      TextEditingController(text: 'ws://echo.websocket.org');

  void _incrementCounter() {
    setState(() {
      _counter += 10;

      var green = max(255 - _counter, 0);

      var red = max(-255 + _counter, 0);

      widget.channel.sink.add('$red,$green,0');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextFormField(
              controller: _connectionController,
              decoration: InputDecoration(labelText: 'Endpoint'),
            ),
            RaisedButton(
              child: Text("Connect"),
              onPressed: _onConnect,
            ),
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
            ExpansionTile(
              title: Text('Manual correction'),
              children: <Widget>[
                Text('$_xOffset'),
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
                Slider(
                  min: -90,
                  max: 90,
                  value: _yOffset,
                  onChanged: (newValue) {
                    setState(() => _yOffset = newValue);

                    sendManualValues();
                  },
                ),
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
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
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
        var parsedMessage = MessageModel('${snapshot.data}');

        return Column(
          children: <Widget>[
            Text(
              snapshot.hasData
                  ? '${snapshot.data}'
                  : '${snapshot.connectionState}',
              style: TextStyle(color: parsedMessage.color),
            ),
            Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(vector.radians(parsedMessage.x))
                ..rotateX(vector.radians(parsedMessage.y))
                ..rotateZ(vector.radians(parsedMessage.z)),
              alignment: FractionalOffset.center,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 20.0,
                    spreadRadius: 5.0,
                    offset: Offset(
                      10.0,
                      10.0,
                    ),
                  )
                ], color: parsedMessage.color),
              ),
            ),
            Text(
              snapshot.hasError ? '${snapshot.error}' : '',
              style: TextStyle(color: Colors.red),
            ),
          ],
        );
      },
    );
  }

  void _onConnect() {
    setState(() {
      widget.channel = HtmlWebSocketChannel.connect(_connectionController.text);

      widget.channel.sink.add('255,0;45,0,0');
    });
  }

  @override
  void dispose() {
    widget.channel.sink.close();

    super.dispose();
  }
}
