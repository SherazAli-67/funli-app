import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ReelsGridShimmer extends StatelessWidget {
  const ReelsGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Color baseColor = Colors.grey[300]!;
    Color highlightColor = Colors.grey[100]!;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 9, // adjust as needed
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 9 / 16,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Row: Avatar + Username + Views
              Row(
                children: [
                  // Avatar shimmer
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Name shimmer
                  Expanded(
                    child: Container(
                      height: 12,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Eye icon shimmer
                  Container(
                    width: 12,
                    height: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  // View count shimmer
                  Container(
                    width: 30,
                    height: 10,
                    color: Colors.white,
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}