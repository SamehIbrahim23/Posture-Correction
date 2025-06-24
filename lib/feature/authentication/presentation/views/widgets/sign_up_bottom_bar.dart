import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routing/routes.dart';
import 'already_have_an_account.dart';

class SignUpBottomSection extends StatelessWidget {
  const SignUpBottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 22,
        ),
        AlreadyHaveAnAccount(
          onTap: () {
            context.go(
              Routes.signIn,
            );
          },
        ),
        const SizedBox(
          height: 22,
        ),
      ],
    );
  }
}
