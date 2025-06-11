import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ReelThumbnailShimmerItem extends StatelessWidget {
  const ReelThumbnailShimmerItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor:  Colors.grey[100]!, child: Container(
      height: 150,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey,
      ),
    ));
  }
}
