import 'package:camera_stream/feature/authentication/presentation/views/widgets/email_and_password_part.dart'
    show EmailAndPasswordPart;
import 'package:camera_stream/feature/authentication/presentation/views/widgets/sign_word.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/helper/show_snack_bar.dart';
import '../../../../../core/logic/switch_views_cubit/switch_views_cubit.dart'
    show SwitchViewsCubit;
import '../../../../../core/routing/routes.dart';
import '../../../../../core/widgets/custom_action_button.dart';
import '../../../../../core/widgets/custom_loading_bar.dart';
import '../../manager/sign_in_with_email_cubit/sign_in_with_email_cubit.dart';

class SignInTopSection extends StatefulWidget {
  const SignInTopSection({
    super.key,
  });
  @override
  State<SignInTopSection> createState() => _SignInTopSectionState();
}

class _SignInTopSectionState extends State<SignInTopSection> {
  String email = '', password = '';
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SignWord(
            title: 'Sign In',
            subTitle: r"Hi! Welcome Back, you've been missed",
            height: MediaQuery.sizeOf(context).height * 0.1,
          ),
          const SizedBox(
            height: 52,
          ),
          EmailAndPasswordPart(
            onChanged1: (value) {
              email = value;
            },
            onChanged2: (value) {
              password = value;
            },
          ),
          const SizedBox(
            height: 22,
          ),
          BlocConsumer<SignInWithEmailCubit, SignInWithEmailState>(
            listener: (BuildContext context, SignInWithEmailState state) {
              if (state is SignInWithEmailSuccess) {
                showSnackBar(
                    context: context, e: 'Signed in successfully', flag: true);
                BlocProvider.of<SwitchViewsCubit>(context).setIndex(0);
                GoRouter.of(context).go(Routes.switchView);
              } else if (state is SignInWithEmailFailure) {
                showSnackBar(context: context, e: state.errorMsg);
              }
            },
            builder: (context, state) {
              if (state is SignInWithEmailLoading) {
                return const CustomLoadingBar();
              }
              return CustomActionButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    autovalidateMode = AutovalidateMode.disabled;
                    await BlocProvider.of<SignInWithEmailCubit>(context)
                        .userSignIn(email: email, password: password);
                  } else {
                    autovalidateMode = AutovalidateMode.always;
                  }
                  setState(() {});
                },
                text: 'Sign In',
              );
            },
          ),
        ],
      ),
    );
  }
}
