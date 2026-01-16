// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TeamAdapter extends TypeAdapter<Team> {
  @override
  final int typeId = 2;

  @override
  Team read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Team(
      name: fields[0] as String,
      logo: fields[1] as String,
      points: fields[2] as int?,
      wins: fields[3] as int?,
      losses: fields[4] as int?,
      goalsFor: fields[5] as int?,
      goalsAgainst: fields[6] as int?,
      draw: fields[7] as int?,
      players: (fields[8] as List).cast<Player>(),
      played: fields[9] as int?,
      diff_goals: fields[10] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Team obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.logo)
      ..writeByte(2)
      ..write(obj.points)
      ..writeByte(3)
      ..write(obj.wins)
      ..writeByte(4)
      ..write(obj.losses)
      ..writeByte(5)
      ..write(obj.goalsFor)
      ..writeByte(6)
      ..write(obj.goalsAgainst)
      ..writeByte(7)
      ..write(obj.draw)
      ..writeByte(8)
      ..write(obj.players)
      ..writeByte(9)
      ..write(obj.played)
      ..writeByte(10)
      ..write(obj.diff_goals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
