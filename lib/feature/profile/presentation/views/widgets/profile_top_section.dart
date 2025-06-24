import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/app_styles.dart';

class ProfileTopSection extends StatelessWidget {
  const ProfileTopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          left: false,
          right: false,
          child: Center(
            child: Text(
              'Profile',
              style: AppStyles.semiBoldInter16(context).copyWith(
                fontSize: getResponsiveText(context: context, base: 20),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 22,
        ),
        const SizedBox(
          height: 18,
        ),
        Center(
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('usernames')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (context, snapshot) {
              return Text(
                snapshot.data?.data()!['name'] ?? '',
                style: AppStyles.regular24(context).copyWith(
                  fontSize: getResponsiveText(context: context, base: 20),
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        const SizedBox(
          height: 22,
        ),
      ],
    );
  }
}
