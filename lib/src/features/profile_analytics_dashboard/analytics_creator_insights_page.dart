import 'package:flutter/material.dart';
import 'package:funli_app/src/features/profile_analytics_dashboard/reel_views_chart.dart';
import 'package:funli_app/src/features/profile_analytics_dashboard/user_stats_card.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/services/settings_service.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/widgets/reel_grid_item_widget.dart';

import '../../loading_shimmers/reel_thumbnail_shimmer_item.dart';
import '../../res/app_textstyles.dart';
import 'analytics_gradient_info_card.dart';

class AnalyticsCreatorInsightsPage extends StatelessWidget{
  const AnalyticsCreatorInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        children: [
          FutureBuilder(future: SettingsService.rankCurrentUser(), builder: (ctx, snapshot){
            if(snapshot.hasData){
              return AnalyticsGradientInfoCard(topText: 'Your global ranking is',
                  mainText: snapshot.requireData.toString(),
                  bottomText: '');
            }

            return AnalyticsGradientInfoCard(topText: 'Your global ranking is',
                mainText: '...',
                bottomText: '');
          }),
          ReelViewsChart(),
          _buildMostPopularFeels(),
          UserStatsCard(),
        ],
      ),
    );
  }


  Widget _buildMostPopularFeels() {
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
        spacing: 10,
        children: [
          const Text(
              'Most Popular Feels',
              style: AppTextStyles.tileTitleTextStyle
          ),
          SizedBox(
            height: 200,
            child: FutureBuilder(future: UserService.getUserPopularReels(), builder: (ctx, snapshot){
              if(snapshot.hasData){
                List<ReelModel> reels = snapshot.requireData;
                return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:  reels.length,
                    itemBuilder: (ctx, index) {
                      ReelModel reel = reels[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SizedBox(
                            height: 150,
                            width: 120,
                            child: ReelGridItemWidget(reel: reel, onTap: (){})),
                      );
                    });
              }else if(snapshot.connectionState == ConnectionState.waiting){
                return ListView.builder(
                    itemCount: 3,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index){
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ReelThumbnailShimmerItem(),
                      );
                    });
              }
              return SizedBox();
            }),
          )
        ],
      ),
    );
  }

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
      ..color = Colors.grey.withValues(alpha: 0.3)
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