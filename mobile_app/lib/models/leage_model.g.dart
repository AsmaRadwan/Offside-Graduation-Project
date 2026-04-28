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
      backendId: fields[6] as String?,
      startDate: fields[7] as DateTime?,
      endDate: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, League obj) {
    writer
      ..writeByte(9)
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
      ..write(obj.topAssistants)
      ..writeByte(6)
      ..write(obj.backendId)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.endDate);
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
