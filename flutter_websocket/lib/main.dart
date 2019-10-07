import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart' as prefix0;
import 'package:flutter_websocket/widgets/axisWidget.dart';
import 'package:flutter_websocket/widgets/settingsDialog.dart';
//import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'models/MessageModel.dart';
import 'models/TimeLineMessage.dart';

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

  List<TimeLineMessage> messages = [];

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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              getResponseWidget(widget.channel),
              Visibility(
                visible: _currentEndpoint.contains("echo"),
                child: Card(
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void sendManualValues() {
    widget.channel.sink.add('0,0;$_xOffset,$_yOffset,$_zOffset');
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

        var rawMessage = '${snapshot.data}';
        var parsedMessage = MessageModel(rawMessage);

        if (snapshot.hasData) {
          messages.insert(0, TimeLineMessage(rawMessage));
          messages = messages.take(100).toList();
        }

        return Column(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new AxisWidget(
                      title: 'X  = ${parsedMessage.x.toInt()}',
                      parsedMessage: parsedMessage,
                      rotate: (message, matrix) {
                        matrix.rotateY(vector.radians(message.x));
                      },
                    ),
                    new AxisWidget(
                      title: 'Y = ${parsedMessage.y.toInt()}',
                      parsedMessage: parsedMessage,
                      rotate: (message, matrix) {
                        matrix.rotateX(vector.radians(message.y));
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
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Card(
                child: ExpansionTile(
                  leading: Icon(Icons.timeline),
                  trailing: Chip(
                    avatar: Icon(Icons.history),
                    label: Text('${messages.length}'),
                  ),
                  title: Text(
                      '${messages.isEmpty ? 'No data received yet' : messages[0].content}'),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        height: 310,
                        child: ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(Icons.history),
                              title: Text(
                                '${messages[index].content}',
                                maxLines: 1,
                              ),
                              subtitle: Text('${messages[index].timeStamp}'),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
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
