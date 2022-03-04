import 'package:hive/hive.dart';

part 'todolist_model.g.dart';

@HiveType(typeId: 0)
class TodolistModel extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String details;

  @HiveField(2)
  late bool complete;

  TodolistModel(
      {required this.title, required this.details, required this.complete});
}
