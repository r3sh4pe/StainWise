// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symptom.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SymptomAdapter extends TypeAdapter<Symptom> {
  @override
  final int typeId = 1;

  @override
  Symptom read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Symptom(
      name: fields[0] as String,
      description: fields[1] as String?,
      createdAt: fields[2] as DateTime?,
      updatedAt: fields[3] as DateTime?,
      strainLevels: (fields[4] as List?)?.cast<int>(),
      strainTimestamps: (fields[5] as List?)?.cast<DateTime>(),
      isActive: fields[6] as bool,
      frequency: fields[7] as int,
      averageStrainLevel: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Symptom obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(obj.strainLevels)
      ..writeByte(5)
      ..write(obj.strainTimestamps)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.frequency)
      ..writeByte(8)
      ..write(obj.averageStrainLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
