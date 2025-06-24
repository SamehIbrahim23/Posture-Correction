import 'package:camera_stream/feature/authentication/presentation/views/widgets/row_of_dividers.dart';
import 'package:flutter/widgets.dart';

class CustomSubMiddleSection extends StatelessWidget {
  const CustomSubMiddleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        RowOfDividers(
          text: 'Or sign in with',
        ),
        Expanded(
          child: SizedBox(
            height: 32,
          ),
        ),
      ],
    );
  }
}
