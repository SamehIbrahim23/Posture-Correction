import 'package:camera_stream/core/routing/routes.dart';
import 'package:camera_stream/feature/authentication/presentation/views/widgets/name_and_email_part.dart';
import 'package:camera_stream/feature/authentication/presentation/views/widgets/sign_up_bottom_bar.dart';
import 'package:camera_stream/feature/authentication/presentation/views/widgets/sign_up_top_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/helper/show_snack_bar.dart';
import '../../../../../core/logic/switch_views_cubit/switch_views_cubit.dart';
import '../../../../../core/widgets/custom_action_button.dart';
import '../../../../../core/widgets/custom_loading_bar.dart';
import '../../manager/sign_up_with_email_cubit/sign_up_with_email_cubit.dart';

class SignUpViewBody extends StatefulWidget {
  const SignUpViewBody({super.key});

  @override
  State<SignUpViewBody> createState() => _SignUpViewBodyState();
}

class _SignUpViewBodyState extends State<SignUpViewBody> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  TextEditingController textEditingController = TextEditingController();
  late String email, password, name;
  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 26.0,
      ),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SignUpTopSection()),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 22,
                ),
              ),
              SliverToBoxAdapter(
                child: Form(
                  autovalidateMode: autovalidateMode,
                  key: formKey,
                  child: NameAndEmailPart(
                    onChanged1: (value) {
                      name = value;
                    },
                    onChanged2: (value) {
                      email = value;
                    },
                    onChanged3: (value) {
                      password = value;
                    },
                    textEditingController: textEditingController,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 22,
                ),
              ),
              BlocConsumer<SignUpWithEmailCubit, SignUpWithEmailState>(
                listener: (context, state) {
                  if (state is SignUpWithEmailSuccess) {
                    BlocProvider.of<SwitchViewsCubit>(context).setIndex(0);
                    context.go(Routes.switchView);
                    showSnackBar(
                        context: context,
                        e: 'Signed up successfully',
                        flag: true);
                  } else if (state is SignUpWithEmailFaliure) {
                    showSnackBar(
                      context: context,
                      e: state.errorMsg,
                    );
                    setState(() {});
                  }
                },
                builder: (context, state) {
                  if (state is SignUpWithEmailLoading) {
                    return const SliverToBoxAdapter(child: CustomLoadingBar());
                  }
                  return SliverToBoxAdapter(
                    child: CustomActionButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          autovalidateMode = AutovalidateMode.disabled;
                          BlocProvider.of<SwitchViewsCubit>(context)
                              .setIndex(0);
                          await BlocProvider.of<SignUpWithEmailCubit>(context)
                              .userRegister(
                                  email: email, password: password, name: name);
                        } else {
                          autovalidateMode = AutovalidateMode.always;
                        }
                        setState(() {});
                      },
                      text: 'Sign Up',
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(
                child: SignUpBottomSection(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
