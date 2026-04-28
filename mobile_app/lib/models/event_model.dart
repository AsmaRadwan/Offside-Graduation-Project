import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 4)

class Event extends HiveObject {
  @HiveField(0)
  String type;

  @HiveField(1)
  String player;

  @HiveField(2)
  int  minute;
  @HiveField(3)
  String? assist;

  @HiveField(4)
  String? half;


  Event({
    required this.type,
    required this.player,
    required this.minute,
    this.assist,
    this.half,
  });
}
