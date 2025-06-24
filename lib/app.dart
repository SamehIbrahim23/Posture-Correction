import 'package:camera_stream/core/routing/app_routers.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Posture Monitor',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: AppRouters.goRouter,
    );
  }
}
