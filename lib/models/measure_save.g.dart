// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measure_save.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeasuredAreaAdapter extends TypeAdapter<MeasuredArea> {
  @override
  final int typeId = 0;

  @override
  MeasuredArea read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeasuredArea(
      name: fields[0] as String,
      area: fields[1] as num,
      polygon: (fields[2] as List)?.cast<MapPoint>(),
    );
  }

  @override
  void write(BinaryWriter writer, MeasuredArea obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.area)
      ..writeByte(2)
      ..write(obj.polygon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasuredAreaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
