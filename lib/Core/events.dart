class Event {
  String title;
  int id = 0;
  bool notification = false;
  DateTime? eventTime;
  Event(
      {this.title = "Title",
      this.id = 0,
      this.notification = false,
      this.eventTime});

  @override
  String toString() => title;

  int getId() => id;
}
