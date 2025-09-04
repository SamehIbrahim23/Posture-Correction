import 'package:camera_stream/feature/statistics/presentation/logic/statistical_cubit.dart';

import '../../data/models/statistics_model.dart';

// Enhanced state classes
abstract class StatisticsState {}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final List<StatisticsModel> statistics;
  final PostureAnalysis analysis;

  StatisticsLoaded(this.statistics, this.analysis);
}

class StatisticsError extends StatisticsState {
  final String message;

  StatisticsError(this.message);
}
