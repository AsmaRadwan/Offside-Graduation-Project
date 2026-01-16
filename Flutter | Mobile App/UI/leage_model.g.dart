// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leage_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeagueAdapter extends TypeAdapter<League> {
  @override
  final int typeId = 0;

  @override
  League read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return League(
      logo: fields[0] as String,
      name: fields[1] as String,
      teams: (fields[2] as List).cast<Team>(),
      matches: (fields[3] as List).cast<Match2>(),
      topScorers: (fields[4] as List?)?.cast<Player>(),
      topAssistants: (fields[5] as List?)?.cast<Player>(),
    );
  }

  @override
  void write(BinaryWriter writer, League obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.logo)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.teams)
      ..writeByte(3)
      ..write(obj.matches)
      ..writeByte(4)
      ..write(obj.topScorers)
      ..writeByte(5)
      ..write(obj.topAssistants);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeagueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
