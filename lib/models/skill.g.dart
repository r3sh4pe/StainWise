// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkillAdapter extends TypeAdapter<Skill> {
  @override
  final int typeId = 2;

  @override
  Skill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Skill(
      name: fields[0] as String,
      description: fields[1] as String?,
      strainLowerFence: fields[2] as int,
      strainUpperFence: fields[3] as int,
      ratings: (fields[7] as List?)?.cast<double>(),
      ratingTimestamps: (fields[8] as List?)?.cast<DateTime>(),
      tags: (fields[9] as List?)?.cast<String>(),
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
      isActive: fields[10] as bool,
      usageCount: fields[11] as int,
    )..averageRating = fields[4] as double;
  }

  @override
  void write(BinaryWriter writer, Skill obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.strainLowerFence)
      ..writeByte(3)
      ..write(obj.strainUpperFence)
      ..writeByte(4)
      ..write(obj.averageRating)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.ratings)
      ..writeByte(8)
      ..write(obj.ratingTimestamps)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.usageCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
