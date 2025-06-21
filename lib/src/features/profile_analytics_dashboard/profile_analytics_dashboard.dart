import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/app_gradients.dart';

class ProfileAnalyticsDashboard extends StatefulWidget {
  const ProfileAnalyticsDashboard({super.key});

  @override
  State<ProfileAnalyticsDashboard> createState() => _ProfileAnalyticsDashboardState();
}

class _ProfileAnalyticsDashboardState extends State<ProfileAnalyticsDashboard> {
  int _selectedTabIndex = 0;
  String _selectedTimeRange = 'This month';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            const SizedBox(height: 16),
            _buildTabBar(),
            Expanded(
              child: _selectedTabIndex == 0 ? _buildMoodHistoryTab() : _buildCreatorInsightsTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            'Dashboard',
            style: AppTextStyles.headingTextStyle3,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              // Show dropdown for time range selection
              _showTimeRangeDropdown();
            },
            child: Row(
              children: [
                Text(
                  _selectedTimeRange,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTimeRangeDropdown() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTimeRangeOption('This week'),
              _buildTimeRangeOption('This month'),
              _buildTimeRangeOption('This year'),
              _buildTimeRangeOption('All time'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeRangeOption(String option) {
    return ListTile(
      title: Text(option),
      onTap: () {
        setState(() {
          _selectedTimeRange = option;
        });
        Navigator.pop(context);
      },
      trailing: _selectedTimeRange == option ? const Icon(Icons.check, color: Colors.blue) : null,
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 0;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: _selectedTabIndex == 0 ? AppGradients.primaryGradient : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Mood History',
                  style: TextStyle(
                    color: _selectedTabIndex == 0 ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: _selectedTabIndex == 1 ? AppGradients.primaryGradient : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Creator Insights',
                  style: TextStyle(
                    color: _selectedTabIndex == 1 ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGradientCard(
            'You\'ve been mostly',
            'Happy',
            'this month!',
          ),
          const SizedBox(height: 16),
          _buildYearSelector(),
          const SizedBox(height: 16),
          _buildMoodStats(),
          const SizedBox(height: 16),
          _buildMoodStreaks(),
        ],
      ),
    );
  }

  Widget _buildCreatorInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGradientCard(
            'Your global ranking is',
            '5,674,464',
            '',
          ),
          const SizedBox(height: 16),
          _buildFeelViews(),
          const SizedBox(height: 16),
          _buildMostPopularFeels(),
          const SizedBox(height: 16),
          _buildTotalEngagements(),
          const SizedBox(height: 16),
          _buildStatsGrid(),
          const SizedBox(height: 16),
          _buildLovesThisYear(),
        ],
      ),
    );
  }

  Widget _buildGradientCard(String topText, String mainText, String bottomText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppGradients.primaryGradient,
      ),
      child: Column(
        children: [
          Text(
            topText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mainText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (bottomText.isNotEmpty)
            Text(
              bottomText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
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
    );
  }

  Widget _buildMoodStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCircularProgressChart(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMoodPercentage('Happy', '24%', Colors.yellow),
              _buildMoodPercentage('Angry', '24%', Colors.red),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMoodPercentage('Sad', '46%', Colors.blue),
              _buildMoodPercentage('Chill', '10.4%', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgressChart() {
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
              '22,870',
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
  }

  Widget _buildMoodStreaks() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
            'Mood Streaks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMoodStreakItem('😊 Happy', '34 days'),
          const SizedBox(height: 12),
          _buildMoodStreakItem('😔 Sad', '14 days'),
          const SizedBox(height: 12),
          _buildMoodStreakItem('😠 Angry', '06 days'),
        ],
      ),
    );
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
            const Icon(Icons.favorite, color: Colors.red, size: 16),
            const SizedBox(width: 4),
            Text(
              days,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeelViews() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
            'Feel Views',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeRangeSelector(),
          const SizedBox(height: 16),
          _buildLineChart(),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Weekly',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: AppGradients.primaryGradient,
              ),
              alignment: Alignment.center,
              child: const Text(
                'Monthly',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Yearly',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return SizedBox(
      height: 200,
      child: CustomPaint(
        painter: LineChartPainter(),
        size: const Size(double.infinity, 200),
      ),
    );
  }

  Widget _buildMostPopularFeels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Most Popular Feels',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildPopularFeelItem('assets/icons/ic_user.svg', '837.5K'),
              _buildPopularFeelItem('assets/icons/ic_user.svg', '837.5K'),
              _buildPopularFeelItem('assets/icons/ic_user.svg', '837.5K'),
              _buildPopularFeelItem('assets/icons/ic_user.svg', '837.5K'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularFeelItem(String imagePath, String views) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/icons/ic_user.svg',
              fit: BoxFit.cover,
              width: 100,
              height: 120,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 40),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_outline, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  views,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalEngagements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
            'Your Total Engagements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEngagementItem(
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.primaryGradient,
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white),
                ),
                '250K',
              ),
              _buildEngagementItem(
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.primaryGradient,
                  ),
                  child: const Icon(Icons.chat_bubble, color: Colors.white),
                ),
                '100K',
              ),
              _buildEngagementItem(
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.primaryGradient,
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
                '132K',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementItem(Widget icon, String count) {
    return Column(
      children: [
        icon,
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('3,456', 'Total Feels', '+2.5%'),
        _buildStatCard('102,990', 'Total Views', '+0.5%'),
        _buildStatCard('30,980', 'Total Loves', '-2.5%'),
        _buildStatCard('230', 'Total Followers', '-5%'),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, String percentage) {
    final isPositive = percentage.startsWith('+');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 12,
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLovesThisYear() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '10,254',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '1.5% ↓',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Loves this year',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: CustomPaint(
              painter: MiniLineChartPainter(),
              size: const Size(double.infinity, 40),
            ),
          ),
        ],
      ),
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

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    
    // Sample data points
    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.1, size.height * 0.5),
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.7, size.height * 0.6),
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width * 0.9, size.height * 0.5),
      Offset(size.width, size.height * 0.4),
    ];
    
    // Draw the line
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    // Draw the path
    canvas.drawPath(path, paint);
    
    // Draw the grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;
    
    // Horizontal grid lines
    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    
    // Vertical grid lines
    for (var i = 1; i < 6; i++) {
      final x = size.width * i / 6;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    
    // Draw the month labels
    final textStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 10,
    );
    final months = ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    
    for (var i = 0; i < months.length; i++) {
      final textSpan = TextSpan(
        text: months[i],
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final x = size.width * (i + 0.5) / 6 - textPainter.width / 2;
      final y = size.height + 5;
      textPainter.paint(canvas, Offset(x, y));
    }
    
    // Draw the value labels
    final valueStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 10,
    );
    final values = ['\$1k', '\$800', '\$600', '\$400', '\$200', '0'];
    
    for (var i = 0; i < values.length; i++) {
      final textSpan = TextSpan(
        text: values[i],
        style: valueStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final x = -textPainter.width - 5;
      final y = size.height * i / 5 - textPainter.height / 2;
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MiniLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    
    // Sample data points for mini chart
    final points = [
      Offset(0, size.height * 0.5),
      Offset(size.width * 0.1, size.height * 0.6),
      Offset(size.width * 0.2, size.height * 0.4),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.3),
      Offset(size.width, size.height * 0.4),
    ];
    
    // Draw the line
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    // Draw the path
    canvas.drawPath(path, paint);
    
    // Add gradient dots at specific points
    final dotPaint = Paint()
      ..style = PaintingStyle.fill;
    
    // Add dots at specific points
    for (var i = 0; i < points.length; i += 3) {
      if (i < points.length) {
        // Alternate colors for dots
        if (i % 6 == 0) {
          dotPaint.color = Colors.blue;
        } else {
          dotPaint.color = Colors.yellow;
        }
        
        canvas.drawCircle(points[i], 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
