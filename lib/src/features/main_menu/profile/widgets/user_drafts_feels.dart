import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/loading_shimmers/reels_gridview_shimmer.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/widgets/reel_grid_item_widget.dart';
import 'package:funli_app/src/widgets/reel_likes_count.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/reels_service.dart';

class UserDraftsFeelsWidget extends StatelessWidget {
  const UserDraftsFeelsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UserService.getUserDraftsReels(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ReelsGridShimmer();
        }

        if (snapshot.hasData && snapshot.requireData.isNotEmpty) {
          List<ReelModel> reels = snapshot.requireData;
          return CustomScrollView(
            key: PageStorageKey('UserDraftReels'),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      ReelModel reel = reels[index];

                      return ReelGridItemWidget(reel: reel, onTap: (){
                        context.push(RouterEnum.publishDraftView.routeName, extra: {
                          'reel': reel,
                        });
                      });
                    },
                    childCount: reels.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                    childAspectRatio: 9 / 16,
                  ),
                ),
              ),
            ],
          );
        }

        return const Center(child: Text("You have no feels in Drafts"));
      },
    );
  }
}
