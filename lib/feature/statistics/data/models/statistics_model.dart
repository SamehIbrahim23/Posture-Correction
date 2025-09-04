import 'package:hive/hive.dart';

part 'statistics_model.g.dart';

@HiveType(typeId: 0)
class StatisticsModel extends HiveObject {
  @HiveField(0)
  final String msg;

  @HiveField(1)
  final DateTime time;

  StatisticsModel({required this.msg, required this.time});
}
