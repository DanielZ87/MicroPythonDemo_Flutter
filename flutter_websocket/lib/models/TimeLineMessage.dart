class TimeLineMessage {
  DateTime timeStamp;
  String content;

  TimeLineMessage(this.content) {
    timeStamp = DateTime.now();
  }
}
