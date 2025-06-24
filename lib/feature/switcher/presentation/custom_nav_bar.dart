import 'dart:ui';

import 'package:camera_stream/feature/switcher/presentation/widgets/custom_bottom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../core/logic/switch_views_cubit/switch_views_cubit.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
        left: 22,
        right: 22,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  38,
                ),
                color: Color(0xff1F2029).withOpacity(0.55)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 9.0,
                vertical: 8,
              ),
              child: BlocBuilder<SwitchViewsCubit, SwitchViewsState>(
                builder: (context, state) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      3,
                      (index) {
                        if (index == 0) {
                          return GestureDetector(
                            onTap: () {
                              BlocProvider.of<SwitchViewsCubit>(context)
                                  .setIndex(0);
                            },
                            child: CustomBottomIcon(
                              color: AppColors.white,
                              icon: Icon(
                                state is HomeViewState
                                    ? IconlyBold.home
                                    : IconlyLight.home,
                                color: state is HomeViewState
                                    ? AppColors.primaryButtonColor
                                    : AppColors.white,
                                size: 26,
                              ),
                              isActive: state is HomeViewState,
                            ),
                          );
                        } else if (index == 1) {
                          return GestureDetector(
                            onTap: () {
                              BlocProvider.of<SwitchViewsCubit>(context)
                                  .setIndex(1);
                            },
                            child: CustomBottomIcon(
                              color: AppColors.white,
                              icon: Icon(
                                state is StatisticsViewState
                                    ? IconlyBold.graph
                                    : IconlyLight.graph,
                                color: state is StatisticsViewState
                                    ? AppColors.primaryButtonColor
                                    : AppColors.white,
                                size: 26,
                              ),
                              isActive: state is StatisticsViewState,
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () {
                              BlocProvider.of<SwitchViewsCubit>(context)
                                  .setIndex(2);
                            },
                            child: CustomBottomIcon(
                              color: AppColors.white,
                              icon: Icon(
                                state is ProfileViewState
                                    ? IconlyBold.profile
                                    : IconlyLight.profile,
                                color: state is ProfileViewState
                                    ? AppColors.primaryButtonColor
                                    : AppColors.white,
                                size: 26,
                              ),
                              isActive: state is ProfileViewState,
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
