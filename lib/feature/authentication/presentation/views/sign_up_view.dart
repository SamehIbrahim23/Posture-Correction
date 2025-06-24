import 'package:camera_stream/feature/authentication/presentation/manager/sign_up_with_email_cubit/sign_up_with_email_cubit.dart';
import 'package:camera_stream/feature/authentication/presentation/views/widgets/sign_up_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpWithEmailCubit(),
      child: const Scaffold(
        backgroundColor: AppColors.white,
        body: SignUpViewBody(),
      ),
    );
  }
}
