import 'package:camera_stream/feature/home/presentation/ui/home_view.dart'
    show HomeView;
import 'package:camera_stream/feature/profile/presentation/views/profile_view.dart';
import 'package:camera_stream/feature/switcher/presentation/custom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/logic/switch_views_cubit/switch_views_cubit.dart';
import '../../statistics/presentation/statistics_view.dart';

class SwitcherView extends StatelessWidget {
  const SwitcherView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwitchViewsCubit, SwitchViewsState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              (state is HomeViewState)
                  ? const HomeView()
                  : (state is StatisticsViewState)
                      ? const StatisticsView()
                      : (state is ProfileViewState)
                          ? const ProfileView()
                          : const SizedBox(),
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: const CustomNavBar(),
              ),
            ],
          ),
        );
      },
    );
  }
}
