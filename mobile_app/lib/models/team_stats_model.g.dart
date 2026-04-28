// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_stats_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TeamStatsAdapter extends TypeAdapter<TeamStats> {
  @override
  final int typeId = 7;

  @override
  TeamStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TeamStats(
      backendId: fields[0] as String?,
      teamId: fields[1] as String,
      appearanceCount: fields[2] as int,
      totalOwnGoals: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TeamStats obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.backendId)
      ..writeByte(1)
      ..write(obj.teamId)
      ..writeByte(2)
      ..write(obj.appearanceCount)
      ..writeByte(3)
      ..write(obj.totalOwnGoals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
