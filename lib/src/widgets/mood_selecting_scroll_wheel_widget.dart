import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class MoodSelectingScrollWheelWidget extends StatefulWidget{
  const MoodSelectingScrollWheelWidget({super.key});

  @override
  State<MoodSelectingScrollWheelWidget> createState() => _MoodSelectingScrollWheelWidgetState();
}

class _MoodSelectingScrollWheelWidgetState extends State<MoodSelectingScrollWheelWidget> {
  final List<Map<String, String>> moods = [
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😥', 'label': 'Crying'},
    {'emoji': '😄', 'label': 'Happy'},
    {'emoji': '😒', 'label': 'Annoyed'},
    {'emoji': '🤣', 'label': 'Laughing'},
    {'emoji': '😡', 'label': 'Angry'},
  ];

  late PageController _controller;
  int currentIndex = 2;

  CarouselSliderController buttonCarouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: currentIndex,
      viewportFraction: 0.3,
    );

    _controller.addListener(() {
      final newIndex = _controller.page!.round();
      if (newIndex != currentIndex) {
        setState(() {
          currentIndex = newIndex;
        });
      }
    });
  }

  void scrollLeft() {
    buttonCarouselController.previousPage(
        duration: Duration(milliseconds: 300), curve: Curves.linear);
    /*if (currentIndex < moods.length - 1) {
      _controller.animateToPage(currentIndex + 1,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }*/
  }

  void scrollRight() {
    buttonCarouselController.nextPage(
        duration: Duration(milliseconds: 300), curve: Curves.linear);
  /*  if (currentIndex > 0) {
      buttonCarouselController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.linear);
      _controller.animateToPage(currentIndex - 1,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    }*/
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 450,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Text("Change your mood!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          SizedBox(
            height: 160,
            child: CarouselSlider(
              carouselController: buttonCarouselController,
                items: List.generate(moods.length, (index){
                  final offset = (index - currentIndex).toDouble();
                  final scale = max(0.8, 1.2 - offset.abs() * 0.3);
                  final verticalOffset = offset.abs() * 20;

                  return Transform.translate(
                    offset: Offset(0, verticalOffset),
                    child: Opacity(
                      opacity: offset.abs() > 2 ? 0.0 : 1.0,
                      child: buildCenter(index, scale)
                    ),
                  );
                }),
                options: CarouselOptions(
                  height: 400,
                  aspectRatio: 16/9,
                  viewportFraction: 0.3,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.linear,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.6,
                  onPageChanged: (index, _){
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  scrollDirection: Axis.horizontal,
                )
            )

            /*PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: _controller,
              itemCount: moods.length,
              itemBuilder: (_, index) {
                final offset = (index - currentIndex).toDouble();
                final scale = max(0.8, 1.2 - offset.abs() * 0.3);
                final verticalOffset = offset.abs() * 20;

                return Transform.translate(
                  offset: Offset(0, verticalOffset),
                  child: Opacity(
                    opacity: offset.abs() > 2 ? 0.0 : 1.0,
                    child: Center(
                      child: Text(
                        moods[index]['emoji']!,
                        style: TextStyle(fontSize: 60 * scale),
                      ),
                    ),
                  ),
                );
              },
            ),*/
          ),

          const SizedBox(height: 16),
          Text(
            moods[currentIndex]['label']!,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text("(Current)", style: TextStyle(color: Colors.grey)),
          const Spacer(),

          GestureDetector(
            onTapDown: (details) {
              final width = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < width / 2) {
                scrollRight(); // Left tap
              } else {
                scrollLeft(); // Right tap
              }
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(colors: [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.purple,
                  Colors.red,
                ]),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: (){
                    scrollRight(); // Left tap
                  }, icon: Icon(Icons.arrow_forward, color: Colors.white,)),
                  IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back, color: Colors.white,)),

                ],
              )
            ),
          ),
        ],
      ),
    );
  }

  Center buildCenter(int index, double scale) {
    bool isSelected = index == currentIndex;
    return Center(
      child: Text(
        moods[index]['emoji']!,
        style: TextStyle(fontSize: isSelected ? 100 * scale : 60*scale),
      ),
    );
  }
}