import 'package:camera_stream/core/routing/routes.dart';
import 'package:camera_stream/feature/authentication/presentation/views/widgets/dont_have_account.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class SignInBottomSection extends StatelessWidget {
  const SignInBottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          flex: 1,
          child: SizedBox(
            height: 32,
          ),
        ),
        DontHaveAccount(
          onTap: () {
            context.go(
              Routes.signUp,
            );
          },
        ),
        const Expanded(
          flex: 3,
          child: SizedBox(),
        ),
      ],
    );
  }
}
