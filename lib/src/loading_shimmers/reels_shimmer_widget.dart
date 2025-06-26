import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ReelsShimmerWidget extends StatelessWidget {
  const ReelsShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width;

    Color baseColor = Colors.grey[300]!;
    Color highlightColor = Colors.grey[100]!;
    // bool isDarkTheme = Provider.of<ThemeProvider>(context).isDarkTheme;
    // Color baseColor =  isDarkTheme ? darkGreyColor : Colors.grey[300]!;
    // Color highlightColor =  isDarkTheme ? primaryDarkColor : Colors.grey[100]!;

    return Stack(
      children: [
        Shimmer.fromColors(baseColor: Colors.grey, highlightColor: Colors.grey, child: Container(
          height: size.height,
          width: size.width,
          color: Colors.grey,
        )),

        Positioned(
          bottom: 10,
          right: 0,
          left: 0,
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          margin: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Username and rating
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 12,
                              width: 120,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 12,
                              width: 80,
                              color: Colors.grey[700],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      height: 20,
                      width: size.width*0.45,
                      margin: EdgeInsets.only(top: 10,left: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: List.generate(3, (index){
                    return  Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 100,
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.purple,
                            ),
                          ),
                          Container(
                            height: 12,
                            width: 75,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


