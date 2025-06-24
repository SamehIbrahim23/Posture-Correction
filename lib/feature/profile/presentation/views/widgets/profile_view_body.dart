import 'package:camera_stream/feature/profile/presentation/views/widgets/profile_top_section.dart';
import 'package:flutter/material.dart';

import 'profile_items_list_view.dart';

class ProfileViewBody extends StatelessWidget {
  const ProfileViewBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 22,
      ),
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: ProfileTopSection(),
          ),
          ProfileItemsListView(),
          SliverFillRemaining(
            hasScrollBody: false,
            child: SizedBox(
              height: 100,
            ),
          )
        ],
      ),
    );
  }
}
