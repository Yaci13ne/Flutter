// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meals_of_a_day_meals.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealsOfADayAdapter extends TypeAdapter<MealsOfADay> {
  @override
  final int typeId = 1;

  @override
  MealsOfADay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealsOfADay(
      day: fields[0] as String,
      listOfMealsForADay: (fields[1] as List).cast<Meal>(),
    );
  }

  @override
  void write(BinaryWriter writer, MealsOfADay obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.listOfMealsForADay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealsOfADayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
