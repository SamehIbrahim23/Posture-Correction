import 'package:camera_stream/feature/authentication/presentation/manager/sign_in_with_email_cubit/sign_in_with_email_cubit.dart';
import 'package:camera_stream/feature/authentication/presentation/views/widgets/sign_in_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInWithEmailCubit(),
      child: const SignInViewBody(),
    );
  }
}
