import 'dart:async';

import 'package:camera_stream/app.dart';
import 'package:camera_stream/constants.dart';
import 'package:camera_stream/core/logic/switch_views_cubit/switch_views_cubit.dart'
    show SwitchViewsCubit;
import 'package:camera_stream/core/utils/simple_bloc_observer.dart';
import 'package:camera_stream/feature/statistics/data/models/statistics_model.dart';
import 'package:camera_stream/feature/statistics/presentation/logic/statistical_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(StatisticsModelAdapter());
  await Hive.openBox<StatisticsModel>(kStatisticsBox);
  Bloc.observer = SimpleBlocObserver();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => SwitchViewsCubit(),
      ),
      BlocProvider(
        create: (context) => StatisticsCubit(),
      ),
    ],
    child: const MyApp(),
  ));
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
}

extension SizeDevice on BuildContext {
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;
}
