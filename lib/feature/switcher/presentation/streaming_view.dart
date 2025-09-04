import 'package:camera_stream/feature/authentication/presentation/views/sign_in_view.dart';
import 'package:camera_stream/feature/switcher/presentation/switcher_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../core/helper/show_snack_bar.dart';
import '../../../core/logic/switch_views_cubit/switch_views_cubit.dart';
import '../../../core/utils/app_colors.dart';

class StreamingView extends StatelessWidget {
  const StreamingView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            const ModalProgressHUD(
              inAsyncCall: true,
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }
          if (snapshot.hasError) {
            showSnackBar(context: context, e: 'Oops, there somthing wrong');
            return const SignInView();
          }
          if (snapshot.data == null) {
            return const SignInView();
          } else {
            BlocProvider.of<SwitchViewsCubit>(context).setIndex(0);
            return const SwitcherView();
          }
        });
  }
}
