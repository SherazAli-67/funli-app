import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/mood_analytics_cache_service.dart';

enum TimeRange {
  weekly,
  monthly,
  yearly
}

class ReelViewsChart extends StatefulWidget {
  const ReelViewsChart({super.key});

  @override
  State<ReelViewsChart> createState() => _ReelViewsChartState();
}

class _ReelViewsChartState extends State<ReelViewsChart> {
  TimeRange _selectedTimeRange = TimeRange.monthly;
  bool _isLoading = true;
  List<FlSpot> _spots = [];
  double _maxY = 1000;
  double _minY = 0;
  List<String> _bottomTitles = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(()=> _isLoading = true);

    try {
      final data = await MoodAnalyticsCacheService.getReelViewsData(_selectedTimeRange);
      
      // Process data for chart
      final List<FlSpot> spots = [];
      final List<String> bottomTitles = [];
      double maxValue = 0;
      double minValue = double.infinity;

      for (int i = 0; i < data.length; i++) {
        final point = data[i];
        spots.add(FlSpot(i.toDouble(), point['value']));
        bottomTitles.add(point['label']);
        
        if (point['value'] > maxValue) {
          maxValue = point['value'];
        }
        if (point['value'] < minValue) {
          minValue = point['value'];
        }
      }

      // Ensure we have a reasonable min/max range
      minValue = minValue == double.infinity ? 0 : minValue;
      maxValue = maxValue == 0 ? 1000 : maxValue * 1.2; // Add 20% padding

      setState(() {
        _spots = spots;
        _bottomTitles = bottomTitles;
        _maxY = maxValue;
        _minY = minValue;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading reel views data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTimeRangeChanged(TimeRange newRange) {
    if (newRange != _selectedTimeRange) {
      setState(() {
        _selectedTimeRange = newRange;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            style: AppTextStyles.tileTitleTextStyle
          ),
          const SizedBox(height: 16),
          _buildTimeRangeSelector(),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _spots.isEmpty
                  ? const Center(child: Text('No view data available'))
                  : SizedBox(
                      height: 250,
                      child: _buildChart(),
                    ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTimeRangeButton(TimeRange.weekly, 'Weekly'),
          _buildTimeRangeButton(TimeRange.monthly, 'Monthly'),
          _buildTimeRangeButton(TimeRange.yearly, 'Yearly'),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(TimeRange range, String label) {
    final isSelected = _selectedTimeRange == range;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTimeRangeChanged(range),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? AppGradients.primaryGradient
                : null,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: _maxY / 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < _bottomTitles.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      _bottomTitles[value.toInt()],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _maxY / 5,
              getTitlesWidget: (value, meta) {
                String text;
                if (value >= 1000) {
                  text = '\$${(value / 1000).toStringAsFixed(1)}k';
                } else {
                  text = '\$${value.toInt()}';
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: _spots.length - 1.0,
        minY: _minY,
        maxY: _maxY,
        lineBarsData: [
          LineChartBarData(
            spots: _spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF9800),
                Color(0xFF8BC34A),
                Color(0xFF2196F3),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF9800).withOpacity(0.3),
                  const Color(0xFF8BC34A).withOpacity(0.3),
                  const Color(0xFF2196F3).withOpacity(0.3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
