// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_stats_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerStatsAdapter extends TypeAdapter<PlayerStats> {
  @override
  final int typeId = 6;

  @override
  PlayerStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerStats(
      backendId: fields[0] as String?,
      playerId: fields[1] as String,
      heatmapImageUrl: fields[2] as String?,
      position: fields[3] as String,
      appearanceCount: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerStats obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.backendId)
      ..writeByte(1)
      ..write(obj.playerId)
      ..writeByte(2)
      ..write(obj.heatmapImageUrl)
      ..writeByte(3)
      ..write(obj.position)
      ..writeByte(4)
      ..write(obj.appearanceCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
