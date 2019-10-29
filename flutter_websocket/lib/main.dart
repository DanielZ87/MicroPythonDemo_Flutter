import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_websocket/bloc/websocketchannel_bloc.dart';
import 'package:flutter_websocket/bloc/websocketchannel_event.dart';
import 'package:flutter_websocket/bloc/websocketchannel_state.dart';
import 'package:flutter_websocket/models/TimeLineMessage.dart';
import 'package:flutter_websocket/widgets/axisWidget.dart';
import 'package:flutter_websocket/widgets/settingsDialog.dart';
//import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart';
import 'package:flutter_websocket/models/MessageModel.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
      home: BlocProvider(
          builder: (context) => WebsocketchannelBloc(),
          child: MyHomePage(title: 'MicroPython Demo')),
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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  double _xOffset = 0;
  double _yOffset = 0;
  double _zOffset = 0;
  double _zoom = 1;

  WebsocketchannelBloc _getBloc(BuildContext context) =>
      BlocProvider.of<WebsocketchannelBloc>(context);

  // String _currentEndpoint = 'ws://echo.websocket.org';
  String _currentEndpoint = 'ws://${Uri.parse(window.location.href).host}:500';

  final TextEditingController _commandSendController = TextEditingController();

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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Flexible(
                  child:
                      BlocBuilder<WebsocketchannelBloc, WebsocketchannelState>(
                bloc: _getBloc(context),
                builder: (context, state) {
                  if (state is ErrorWebsocketchannelState) {
                    return buildError(state);
                  }

                  if (state is ConnectedWebsocketchannelState) {
                    return buildMessages(state.messages);
                  }

                  if (state is ConnectingWebsocketchannelState) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return Text(state.toString());
                },
              )),
              buildEchoControl()
            ],
          ),
        ),
      ),
    );
  }

  Row buildError(ErrorWebsocketchannelState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.error,
          color: Colors.red,
        ),
        Text(state.errorMessage),
      ],
    );
  }

  Visibility buildEchoControl() {
    return Visibility(
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
            ),
            Text('Zoom: $_zoom'),
            Slider(
              min: -1,
              max: 1,
              value: _zoom,
              onChanged: (newValue) {
                setState(() => _zoom = newValue);
                // sendManualValues();
              },
            )
          ],
        ),
      ),
    );
  }

  void sendManualValues() {
    print('Sending Echo-Values');
    widget.channel.sink.add('255,0;$_xOffset,$_yOffset,$_zOffset');
  }

  Widget buildMessages(List<TimeLineMessage> messages) {
    var parsedMessage =
        MessageModel(messages.isEmpty ? '' : messages.first.content);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var columnOccupyCount = constraints.maxWidth < 800 ? 2 : 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            buildAxis(parsedMessage),
            Flexible(
              flex: 1,
              child: StaggeredGridView.count(
                crossAxisCount: 2,
                // physics: NeverScrollableScrollPhysics(),
                staggeredTiles: [
                  // StaggeredTile.fit(columnCount),
                  StaggeredTile.fit(columnOccupyCount),
                  StaggeredTile.fit(columnOccupyCount),
                ],
                children: <Widget>[
                  // buildAxis(parsedMessage),
                  buildHistory(messages),
                  buildCommand()
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildCommand() {
    return new MinConstrainedCardTile(
        child: Align(
      alignment: Alignment.centerLeft,
      child: ListTile(
        title: TextFormField(
          controller: _commandSendController,
          decoration: InputDecoration(
              hintText: 'Command',
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  widget.channel.sink.add(_commandSendController.text);
                  setState(() {
                    _commandSendController.clear();
                  });
                },
              )),
        ),
      ),
    ));
  }

  Widget buildHistory(List<TimeLineMessage> messages) {
    return Align(
      alignment: Alignment.centerLeft,
      child: MinConstrainedCardTile(
        child: ExpansionTile(
          leading: Icon(Icons.timeline),
          trailing: Chip(
            avatar: Icon(Icons.history),
            label: Text('${messages.length}'),
            deleteIcon: Icon(
              Icons.clear,
              size: 20,
            ),
            onDeleted: messages.isEmpty
                ? null
                : () {
                    _getBloc(context).add(ClearMessageHistoryEvent());
                  },
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
    );
  }

  Widget buildAxis(MessageModel parsedMessage) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new AxisWidget(
              title: 'X  = ${parsedMessage.x.toInt()}',
              parsedMessage: parsedMessage,
              rotationValueAccessor: (message, offset) => message.x + offset.dy,
              rotate: (rotationValue, matrix) {
                matrix.rotateX(rotationValue);
              },
            ),
            new AxisWidget(
              title: 'Y = ${parsedMessage.y.toInt()}',
              parsedMessage: parsedMessage,
              rotationValueAccessor: (message, offset) => message.y + offset.dx,
              rotate: (rotationValue, matrix) {
                matrix.rotateY(rotationValue);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onConnect(String endpoint) {
    _getBloc(context).add(ConnectingChannelEvent());

    widget.channel = HtmlWebSocketChannel.connect(endpoint);
    widget.channel.stream.listen((onData) {
      _getBloc(context).add(IncommingMessageEvent(onData.toString()));
    }, onError: (error) {
      _getBloc(context).add(ChannelErrorEvent(error.toString()));
    });
  }

  @override
  void dispose() {
    widget.channel.sink.close();

    super.dispose();
  }
}

class MinConstrainedCardTile extends StatelessWidget {
  const MinConstrainedCardTile({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ConstrainedBox(
        child: child,
        constraints: BoxConstraints(minHeight: 60),
      ),
    );
  }
}
