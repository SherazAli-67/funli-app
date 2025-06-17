import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TrendingHashtagShimmerWidget extends StatelessWidget {
  const TrendingHashtagShimmerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color baseColor = Colors.grey[300]!;
    Color highlightColor = Colors.grey[100]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        spacing: 20,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Shimmer.fromColors(baseColor: baseColor, highlightColor:  highlightColor, child: Container(
              height: 20,
              width: 100,
              color: Colors.grey,
            )),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Shimmer.fromColors(baseColor: baseColor, highlightColor:  highlightColor, child: Container(
              height: 20,
              width: 50,
              color: Colors.grey,
            )),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Shimmer.fromColors(baseColor: baseColor, highlightColor:  highlightColor, child: Container(
              height: 30,
              width: 100,
              color: Colors.grey,
            )),
          ),
        ],
      ),
    );
  }
}