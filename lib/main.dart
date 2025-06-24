import 'dart:async';

import 'package:camera_stream/app.dart';
import 'package:camera_stream/core/logic/switch_views_cubit/switch_views_cubit.dart'
    show SwitchViewsCubit;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(BlocProvider(
    create: (context) => SwitchViewsCubit(),
    child: const MyApp(),
  ));
}

extension SizeDevice on BuildContext {
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;
}
