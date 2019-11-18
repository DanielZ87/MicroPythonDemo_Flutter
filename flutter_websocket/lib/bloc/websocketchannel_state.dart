import 'package:flutter_websocket/models/timeLineMessage.dart';
import 'package:meta/meta.dart';

@immutable
abstract class WebsocketchannelState {}

class InitialWebsocketchannelState extends WebsocketchannelState {
  final String message = 'Not connected';
}

class ConnectingWebsocketchannelState extends WebsocketchannelState {
  final String message = 'Waiting for message';
}

class ConnectedWebsocketchannelState extends WebsocketchannelState {
  final List<TimeLineMessage> messages;

  ConnectedWebsocketchannelState(this.messages);
}

class ErrorWebsocketchannelState extends WebsocketchannelState {
  final String errorMessage;

  ErrorWebsocketchannelState(this.errorMessage);
}
