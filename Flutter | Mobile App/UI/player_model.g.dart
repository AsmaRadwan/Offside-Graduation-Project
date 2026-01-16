// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 3;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
      name: fields[0] as String,
      position: fields[1] as String,
      age: fields[2] as int,
      nationality: fields[3] as String,
      image: fields[4] as String?,
      number: fields[5] as int,
      goals: fields[6] as int,
      assists: fields[7] as int,
      appearances: fields[8] as int,
      yellowCards: fields[9] as int,
      redCards: fields[10] as int,
      minutesPlayed: fields[11] as int,
      shots: fields[12] as int,
      passes: fields[13] as int,
      played: fields[14] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.position)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.nationality)
      ..writeByte(4)
      ..write(obj.image)
      ..writeByte(5)
      ..write(obj.number)
      ..writeByte(6)
      ..write(obj.goals)
      ..writeByte(7)
      ..write(obj.assists)
      ..writeByte(8)
      ..write(obj.appearances)
      ..writeByte(9)
      ..write(obj.yellowCards)
      ..writeByte(10)
      ..write(obj.redCards)
      ..writeByte(11)
      ..write(obj.minutesPlayed)
      ..writeByte(12)
      ..write(obj.shots)
      ..writeByte(13)
      ..write(obj.passes)
      ..writeByte(14)
      ..write(obj.played);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
