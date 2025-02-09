// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strain_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StrainEntryAdapter extends TypeAdapter<StrainEntry> {
  @override
  final int typeId = 3;

  @override
  StrainEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StrainEntry(
      title: fields[0] as String,
      note: fields[1] as String?,
      strainLevel: fields[2] as int,
      symptoms: (fields[5] as List?)?.cast<Symptom>(),
      usedSkill: fields[6] as Skill?,
      skillRating: fields[7] as double?,
      createdAt: fields[3] as DateTime?,
      updatedAt: fields[4] as DateTime?,
    )
      ..isSkillRated = fields[8] as bool
      ..skillRatedAt = fields[9] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, StrainEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.note)
      ..writeByte(2)
      ..write(obj.strainLevel)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.symptoms)
      ..writeByte(6)
      ..write(obj.usedSkill)
      ..writeByte(7)
      ..write(obj.skillRating)
      ..writeByte(8)
      ..write(obj.isSkillRated)
      ..writeByte(9)
      ..write(obj.skillRatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrainEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
