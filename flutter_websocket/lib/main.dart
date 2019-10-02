import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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

  final TextEditingController _connectionController =
      TextEditingController(text: 'ws://echo.websocket.org');

  void _incrementCounter() {
    setState(() {
      _counter++;
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
                  getStreamBuilder(widget.channel)
                ],
              ),
            ),
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

  Widget getStreamBuilder(WebSocketChannel channel) {
    if (channel == null) {
      return Text('Please connect first');
    }

    return StreamBuilder(
      stream: widget.channel.stream,
      builder: (context, snapshot) {
        return Column(
          children: <Widget>[
            Text(snapshot.hasData
                ? '${snapshot.data}'
                : '${snapshot.connectionState}'),
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
      widget.channel = IOWebSocketChannel.connect(_connectionController.text);

      //widget.channel.sink.add('Hello');
    });
  }

  @override
  void dispose() {
    widget.channel.sink.close();

    super.dispose();
  }
}
