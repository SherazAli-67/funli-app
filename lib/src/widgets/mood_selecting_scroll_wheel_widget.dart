import 'package:circle_wheel_scroll/circle_wheel_scroll_view.dart' as circleWheel;
import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_colors.dart';

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

  int currentIndex = 2;
  late circleWheel.FixedExtentScrollController _controller;

  @override
  void initState() {
    _controller = circleWheel.FixedExtentScrollController(initialItem: currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height*0.5,
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
            height: size.height*0.19,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.tealColor,
                  radius: 45,
                ),
                circleWheel.CircleListScrollView(
                  physics: circleWheel.CircleFixedExtentScrollPhysics(),
                  axis: Axis.horizontal,
                  itemExtent: 80,
                  radius: size.width*0.5,
                  controller: _controller,
                  onSelectedItemChanged: (val){
                    currentIndex = val;
                    setState(() {});
                  },
                  children: List.generate(moods.length, (index){
                    bool isSelected = currentIndex == index;

                    return Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(moods[index]['emoji']!, textAlign: TextAlign.center, style: TextStyle(fontSize: isSelected ? 60 : 55),),
                        )
                    );
                  }),
                ),

              ],
            ),
          ),

          Text(
            moods[currentIndex]['label']!,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text("(Current)", style: TextStyle(color: Colors.grey)),

          ResizeHorizontalButton(onLeftTap: (){
            if (currentIndex > 0) {
              currentIndex--;

              _controller.animateToItem(
                currentIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() {});
            }
          }, onRightTap: (){
            if (currentIndex < moods.length - 1) {
              currentIndex++;
              _controller.animateToItem(
                currentIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() {

              });
            }
          })
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


class ResizeHorizontalButton extends StatelessWidget {
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;

  const ResizeHorizontalButton({
    super.key,
    required this.onLeftTap,
    required this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient:  LinearGradient(
          colors: [
            Color.fromRGBO(255, 59, 48, 1),
            Color.fromRGBO(255, 149, 0, 1),
            Color.fromRGBO(255, 204, 0, 1),
            Color.fromRGBO(52, 199, 89, 1),
            Color.fromRGBO(0, 122, 255, 1),
            Color.fromRGBO(88, 86, 214, 1),
            Color.fromRGBO(175, 82, 222, 1),

          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withValues(alpha: 0.6),
            blurRadius: 12,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        // mainAxisAlignment: MainAxisAlignment.center,
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 6,
            child:  IconButton(
              onPressed: onLeftTap,
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30,),
            ),
          ),
          const SizedBox(width: 12),
          Positioned(
            right: 6,
            child: IconButton(
              onPressed: onRightTap,
              icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 30,),
            ),
          ),
        ],
      ),
    );
  }
}