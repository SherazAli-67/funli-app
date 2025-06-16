import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TrendingFeelsWidget extends StatelessWidget {
  const TrendingFeelsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color baseColor = Colors.grey[300]!;
    Color highlightColor = Colors.grey[100]!;

    return Column(
      children: List.generate(2, (index){
        return SizedBox(
          height: 250,
          child: Card(
            margin: EdgeInsets.only(bottom: 10),
            elevation: 1,
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Shimmer.fromColors(baseColor: baseColor, highlightColor:  highlightColor, child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                      )),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Shimmer.fromColors(baseColor: baseColor, highlightColor:  highlightColor, child: Container(
                            height: 20,
                            width: 50,
                            color: Colors.grey,
                          )),
                          Shimmer.fromColors(baseColor: baseColor, highlightColor:  highlightColor, child: Container(
                            height: 10,
                            width: 100,
                            color: Colors.grey,
                          )),
                        ],
                      ),
                      const Spacer(),
                      Shimmer.fromColors(baseColor: baseColor, highlightColor:  highlightColor, child: Container(
                        height: 25,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey,
                        ),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: ListView.builder(
                        itemCount: 4,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (ctx, index){
                          Shimmer.fromColors(baseColor: baseColor, highlightColor:  highlightColor, child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey,
                            ),
                          ));
                        }),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}