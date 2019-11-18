import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_websocket/models/timeLineMessage.dart';
import './bloc.dart';

class WebsocketchannelBloc
    extends Bloc<WebsocketchannelEvent, WebsocketchannelState> {
  List<TimeLineMessage> _messages = [];

  @override
  WebsocketchannelState get initialState => InitialWebsocketchannelState();

  @override
  Stream<WebsocketchannelState> mapEventToState(
    WebsocketchannelEvent event,
  ) async* {
    if (event is ConnectingChannelEvent) {
      yield ConnectingWebsocketchannelState();
    } else if (event is ClearMessageHistoryEvent) {
      _messages.clear();
      yield ConnectedWebsocketchannelState(_messages);
    } else if (event is IncommingMessageEvent) {
      _messages.insert(0, TimeLineMessage(event.message));
      _messages = _messages.take(100).toList();
      yield ConnectedWebsocketchannelState(_messages);
    } else if (event is ChannelErrorEvent) {
      yield ErrorWebsocketchannelState(event.errorMessage);
    }
  }
}
