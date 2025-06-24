import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void showSnackBar(
    {required BuildContext context,
    required String e,
    bool flag = false,
    int delay = 550}) {
  flag
      ? showTopSnackBar(
          displayDuration: Duration(milliseconds: delay),
          Overlay.of(context),
          CustomSnackBar.success(
            message: e,
          ),
        )
      : showTopSnackBar(
          displayDuration: Duration(milliseconds: delay),
          Overlay.of(context),
          CustomSnackBar.error(
            message: e,
          ),
        );
}
