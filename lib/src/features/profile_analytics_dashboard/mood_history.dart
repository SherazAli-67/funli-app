import 'package:flutter/material.dart';
import 'package:funli_app/src/features/profile_analytics_dashboard/analytics_gradient_info_card.dart';
import 'package:funli_app/src/features/profile_analytics_dashboard/reel_views_chart.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/mood_analytics_cache_service.dart';


class AnalyticsMoodHistory extends StatelessWidget{
  const AnalyticsMoodHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          FutureBuilder(future: MoodAnalyticsCacheService.getUserMoodAnalytics(), builder: (ctx, snapshot){
            if(snapshot.hasData){
              return  AnalyticsGradientInfoCard(
                topText: 'You\'ve been mostly',
                mainText: snapshot.data!,
                bottomText: 'this month!',
              );
            }
            return  AnalyticsGradientInfoCard(
              topText: 'You\'ve been mostly',
              mainText: '...',
              bottomText: 'this month!',
            );
          }),

          const SizedBox(height: 16),
          _buildYearSelector(),
          /*const SizedBox(height: 16),
          _buildMoodStats(),*/
          const SizedBox(height: 16),
          _buildMoodStreaks(),

        ],
      ),
    );
  }


  Widget _buildYearSelector() {
    return Card(
      elevation: 1,
      color: Colors.white,
      child:  FutureBuilder<Map<String, dynamic>>(
        future: MoodAnalyticsCacheService.getMoodPercentages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Text('Error loading analytics', style: TextStyle(color: Colors.red));
          } else if (!snapshot.hasData || snapshot.data!['percentages'].isEmpty) {
            return const Text('No reel data available', style: TextStyle(fontSize: 16));
          } else {
            final rawMoodData = snapshot.data!['percentages'] as Map<String, dynamic>;
            final moodData = rawMoodData.map((key, value) => MapEntry(key, (value as num).toDouble()));
            final totalViews = snapshot.data!['totalViews'] as int;

            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  // Year selector with arrows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.arrow_back_ios, size: 16),
                      const Text(
                        '2025',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Circular progress chart
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: CustomPaint(
                          painter: DynamicCircularProgressPainter(moodData),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            totalViews.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Visitors this year',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Display top 4 moods dynamically
                  _buildTopMoodsDisplay(moodData),
                ],
              ),
            );
          }
        },
      ),
    );
  }
  
 /* Widget _buildMoodStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future: MoodAnalyticsCacheService.getMoodPercentages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error loading analytics', style: TextStyle(color: Colors.red));
        } else {
          final moodData = (snapshot.data != null && snapshot.data!['percentages'] != null)
              ? (snapshot.data!['percentages'] as Map<String, dynamic>).map((key, value) => MapEntry(key, (value as num).toDouble()))
              : {
                  'Happy': 24.0,
                  'Angry': 24.0,
                  'Sad': 46.0,
                  'Chill': 10.4,
                };
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mood Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...moodData.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getMoodColor(entry.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.key,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          );
        }
      },
    );
  }
  */
  Widget _buildDynamicMoodPercentage(String mood, double percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          mood,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTopMoodsDisplay(Map<String, double> moodData) {
    // Sort moods by percentage (descending)
    final sortedMoods = moodData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Take top 4 moods or all if less than 4
    final topMoods = sortedMoods.take(4).toList();
    
    // If we have 4 moods, display in 2 rows of 2
    if (topMoods.length == 4) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDynamicMoodPercentage(
                topMoods[0].key, 
                topMoods[0].value, 
                _getMoodColor(topMoods[0].key)
              ),
              _buildDynamicMoodPercentage(
                topMoods[1].key, 
                topMoods[1].value, 
                _getMoodColor(topMoods[1].key)
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDynamicMoodPercentage(
                topMoods[2].key, 
                topMoods[2].value, 
                _getMoodColor(topMoods[2].key)
              ),
              _buildDynamicMoodPercentage(
                topMoods[3].key, 
                topMoods[3].value, 
                _getMoodColor(topMoods[3].key)
              ),
            ],
          ),
        ],
      );
    } 
    // If we have 3 moods, display in a row of 2 and a row of 1
    else if (topMoods.length == 3) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDynamicMoodPercentage(
                topMoods[0].key, 
                topMoods[0].value, 
                _getMoodColor(topMoods[0].key)
              ),
              _buildDynamicMoodPercentage(
                topMoods[1].key, 
                topMoods[1].value, 
                _getMoodColor(topMoods[1].key)
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDynamicMoodPercentage(
                topMoods[2].key, 
                topMoods[2].value, 
                _getMoodColor(topMoods[2].key)
              ),
            ],
          ),
        ],
      );
    } 
    // If we have 2 moods, display in a single row
    else if (topMoods.length == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDynamicMoodPercentage(
            topMoods[0].key, 
            topMoods[0].value, 
            _getMoodColor(topMoods[0].key)
          ),
          _buildDynamicMoodPercentage(
            topMoods[1].key, 
            topMoods[1].value, 
            _getMoodColor(topMoods[1].key)
          ),
        ],
      );
    } 
    // If we have 1 mood, display centered
    else if (topMoods.length == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDynamicMoodPercentage(
            topMoods[0].key, 
            topMoods[0].value, 
            _getMoodColor(topMoods[0].key)
          ),
        ],
      );
    } 
    // Fallback for empty data
    else {
      return const Text('No mood data available');
    }
  }


  
  Color _getMoodColor(String mood) {
    // Define a map of standard mood colors
    final moodColors = {
      'Happy': Colors.yellow,
      'Angry': Colors.red,
      'Sad': Colors.blue,
      'Chill': Colors.green,
      'Excited': Colors.orange,
      'Relaxed': Colors.teal,
      'Anxious': Colors.purple,
      'Bored': Colors.brown,
      'Surprised': Colors.pink,
      'Confused': Colors.indigo,
      'Tired': Colors.blueGrey,
      'Energetic': Colors.amber,
    };
    
    // Return the color for the mood if it exists, otherwise return a color based on the hash code
    if (moodColors.containsKey(mood)) {
      return moodColors[mood]!;
    } else {
      // Generate a consistent color based on the mood string
      final colorValue = mood.hashCode & 0xFFFFFF;
      return Color(0xFF000000 | colorValue);
    }
  }

/*  Widget _buildCircularProgressChart() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: CustomPaint(
            painter: CircularProgressPainter(),
          ),
        ),
        Column(
          children: const [
            Text(
              'N/A',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Visitors this year',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodPercentage(String mood, String percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          mood,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }*/

  Widget _buildMoodStreaks() {
    return FutureBuilder<Map<String, int>>(
      future: MoodAnalyticsCacheService.getMoodStreaks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Text('Error loading mood streaks', style: TextStyle(color: Colors.red)),
          );
        } else {
          final moodStreaks = snapshot.data ?? {};
          
          // Sort moods by streak length (descending)
          final sortedMoods = moodStreaks.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          
          return Card(
            elevation: 1,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mood Streaks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (moodStreaks.isEmpty)
                    const Text('No mood streaks available yet  34 days', style: TextStyle(fontSize: 16))
                  else
                    ...sortedMoods.take(3).map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildMoodStreakItem(
                          '${_getMoodEmoji(entry.key)} ${entry.key}',
                          '${entry.value.toString().padLeft(2, '0')} days',
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        }
      },
    );
  }
  
  String _getMoodEmoji(String mood) {
    final moodEmojis = {
      'Happy': '😊',
      'Sad': '😔',
      'Angry': '😠',
      'Chill': '😌',
      'Excited': '🤩',
      'Relaxed': '😎',
      'Anxious': '😰',
      'Bored': '😒',
      'Surprised': '😲',
      'Confused': '🤔',
      'Tired': '😴',
      'Energetic': '⚡',
    };
    
    return moodEmojis[mood] ?? '😐';
  }

  Widget _buildMoodStreakItem(String mood, String days) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          mood,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        Row(
          children: [
           Text("❤️‍🔥"),
            const SizedBox(width: 4),
            Text(
              days,
              style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w400)
            ),
          ],
        ),
      ],
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Define the colors for the segments
    final colors = [
      Colors.yellow,
      Colors.red,
      Colors.blue,
      Colors.green,
    ];

    // Define the sweep angles for each segment (in radians)
    final sweepAngles = [
      0.24 * 2 * 3.14159, // 24% Happy
      0.24 * 2 * 3.14159, // 24% Angry
      0.46 * 2 * 3.14159, // 46% Sad
      0.104 * 2 * 3.14159, // 10.4% Chill
    ];

    var startAngle = -3.14159 / 2; // Start from the top

    for (var i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12;

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngles[i],
        false,
        paint,
      );

      startAngle += sweepAngles[i];
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DynamicCircularProgressPainter extends CustomPainter {
  final Map<String, double> moodData;
  
  DynamicCircularProgressPainter(this.moodData);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // Define a list of colors to use for different moods
    final availableColors = [
      Colors.yellow,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    
    // If no data, use default values
    if (moodData.isEmpty) {
      final defaultData = {
        'Happy': 24.0,
        'Angry': 24.0,
        'Sad': 46.0,
        'Chill': 10.4,
      };
      
      var startAngle = -3.14159 / 2; // Start from the top
      int colorIndex = 0;
      
      defaultData.forEach((mood, percentage) {
        final sweepAngle = percentage / 100 * 2 * 3.14159;
        final paint = Paint()
          ..color = availableColors[colorIndex % availableColors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12;
        
        canvas.drawArc(
          rect,
          startAngle,
          sweepAngle,
          false,
          paint,
        );
        
        startAngle += sweepAngle;
        colorIndex++;
      });
      
      return;
    }
    
    // Sort moods by percentage (descending) to get top moods
    final sortedMoods = moodData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Take top 4 moods or all if less than 4
    final topMoods = sortedMoods.take(4).toList();
    
    // Draw arcs based on top moods
    var startAngle = -3.14159 / 2; // Start from the top
    int colorIndex = 0;
    
    for (var entry in topMoods) {
      // final mood = entry.key;
      final percentage = entry.value;
      final sweepAngle = percentage / 100 * 2 * 3.14159;
      
      final paint = Paint()
        ..color = availableColors[colorIndex % availableColors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12;
      
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      
      startAngle += sweepAngle;
      colorIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
