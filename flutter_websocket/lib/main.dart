import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_websocket/bloc/websocketchannel_bloc.dart';
import 'package:flutter_websocket/pages/mainPage.dart';
//import 'package:web_socket_channel/io.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
          child: new MainPage(title: 'MicroPython Demo')),
    );
  }
}
