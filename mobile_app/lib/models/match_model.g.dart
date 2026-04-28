// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class Match2Adapter extends TypeAdapter<Match2> {
  @override
  final int typeId = 1;

  @override
  Match2 read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Match2(
      homeTeam: fields[0] as Team,
      awayTeam: fields[1] as Team,
      date: fields[2] as DateTime,
      homeTeamScore: fields[3] as int?,
      awayTeamScore: fields[4] as int?,
      eventsHome: (fields[6] as List).cast<Event>(),
      eventsAway: (fields[7] as List).cast<Event>(),
      backendId: fields[8] as String?,
      videoUrl: fields[9] as String?,
    )..status = fields[5] as String?;
  }

  @override
  void write(BinaryWriter writer, Match2 obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.homeTeam)
      ..writeByte(1)
      ..write(obj.awayTeam)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.homeTeamScore)
      ..writeByte(4)
      ..write(obj.awayTeamScore)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.eventsHome)
      ..writeByte(7)
      ..write(obj.eventsAway)
      ..writeByte(8)
      ..write(obj.backendId)
      ..writeByte(9)
      ..write(obj.videoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Match2Adapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
