import 'package:meta/meta.dart';

@immutable
abstract class WebsocketchannelEvent {}

class ConnectingChannelEvent extends WebsocketchannelEvent {}

class ClearMessageHistoryEvent extends WebsocketchannelEvent {}

class IncommingMessageEvent extends WebsocketchannelEvent {
  final String message;

  IncommingMessageEvent(this.message);
}

class ChannelErrorEvent extends WebsocketchannelEvent {
  final String errorMessage;

  ChannelErrorEvent(this.errorMessage);
}
