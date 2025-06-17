import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NotificationShimmerItemWidget extends StatelessWidget {
  const NotificationShimmerItemWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color baseColor = Colors.grey[300]!;
    Color highlightColor = Colors.grey[100]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Shimmer.fromColors(baseColor: baseColor, highlightColor:  highlightColor, child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              height: 50,
              width: 100,
            )),
          ),
          Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Shimmer.fromColors(baseColor: baseColor, highlightColor:  highlightColor, child: Container(
                  height: 20,
                  width: 70,
                  color: Colors.grey,
                )),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Shimmer.fromColors(baseColor: baseColor, highlightColor:  highlightColor, child: Container(
                  height: 20,
                  width: 200,
                  color: Colors.grey,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}