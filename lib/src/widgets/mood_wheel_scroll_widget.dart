import 'package:flutter/material.dart';

/// A horizontal wheel selector widget that displays numbered circular items
/// with fixed positions and center highlighting.
class HorizontalWheelSelector extends StatefulWidget {
  /// The minimum value in the wheel
  final int minValue;

  /// The maximum value in the wheel
  final int maxValue;

  /// Initial selected value
  final int initialValue;

  /// Callback when value changes
  final ValueChanged<int>? onChanged;

  /// Size of the item circles
  final double itemSize;

  /// Color of the items
  final Color itemColor;

  /// Text style for the numbers
  final TextStyle? textStyle;

  const HorizontalWheelSelector({
    Key? key,
    required this.minValue,
    required this.maxValue,
    this.initialValue = 0,
    this.onChanged,
    this.itemSize = 60.0,
    this.itemColor = Colors.blue,
    this.textStyle,
  }) : assert(minValue <= maxValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        super(key: key);

  @override
  State<HorizontalWheelSelector> createState() => _HorizontalWheelSelectorState();

  /// Shows this wheel selector in a modal bottom sheet
  static Future<int?> showAsBottomSheet({
    required BuildContext context,
    required int minValue,
    required int maxValue,
    int initialValue = 0,
    String title = 'Wheel',
    double itemSize = 60.0,
    Color itemColor = Colors.blue,
    TextStyle? textStyle,
    VoidCallback? onCancel,
    ValueChanged<int>? onConfirm,
  }) async {
    int selectedValue = initialValue;

    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bottom sheet handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  color: itemColor,
                  width: double.infinity,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Wheel selector
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: HorizontalWheelSelector(
                    minValue: minValue,
                    maxValue: maxValue,
                    initialValue: initialValue,
                    itemSize: itemSize,
                    itemColor: itemColor,
                    textStyle: textStyle,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                      });
                    },
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (onCancel != null) onCancel();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: itemColor,
                        ),
                        onPressed: () {
                          if (onConfirm != null) onConfirm(selectedValue);
                          Navigator.of(context).pop(selectedValue);
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return result;
  }
}

class _HorizontalWheelSelectorState extends State<HorizontalWheelSelector> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.itemSize * 1.5,
      decoration: const BoxDecoration(
        // Grid background with lines
        image: DecorationImage(
          image: NetworkImage('https://transparent-grid.com/patterns/grid-light.png'),
          repeat: ImageRepeat.repeat,
          opacity: 0.3,
        ),
      ),
      child: GestureDetector(
        // Handle horizontal drag to change values
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity.abs() < 100) return; // Ignore small movements

          setState(() {
            if (velocity < 0) {
              // Dragged left to right - increase value
              if (_currentValue < widget.maxValue) {
                _currentValue++;
                if (widget.onChanged != null) {
                  widget.onChanged!(_currentValue);
                }
              }
            } else {
              // Dragged right to left - decrease value
              if (_currentValue > widget.minValue) {
                _currentValue--;
                if (widget.onChanged != null) {
                  widget.onChanged!(_currentValue);
                }
              }
            }
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Fixed position layout with three items
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left item
                _buildWheelItem(_currentValue > widget.minValue
                    ? _currentValue - 1
                    : widget.maxValue, false, -1),

                SizedBox(width: widget.itemSize * 0.5),

                // Center item with crosshair
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Center item
                    _buildWheelItem(_currentValue, true, 0),

                    // Crosshair overlay
                    Container(
                      width: widget.itemSize,
                      height: widget.itemSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: CustomPaint(
                        painter: CrosshairPainter(
                          color: Colors.black.withOpacity(0.5),
                          strokeWidth: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: widget.itemSize * 0.5),

                // Right item
                _buildWheelItem(_currentValue < widget.maxValue
                    ? _currentValue + 1
                    : widget.minValue, false, 1),
              ],
            ),

            // Horizontal line
            Positioned(
              left: 0,
              right: 0,
              top: widget.itemSize * 0.75,
              child: Container(
                height: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
            ),

            // Vertical line
            Positioned(
              top: 0,
              bottom: 0,
              left: MediaQuery.of(context).size.width / 2,
              child: Container(
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheelItem(int value, bool isCenter, int position) {
    // Determine opacity based on position
    final opacity = isCenter ? 1.0 : 0.7;

    return Container(
      width: widget.itemSize,
      height: widget.itemSize,
      decoration: BoxDecoration(
        color: widget.itemColor.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          value.toString(),
          style: (widget.textStyle ??
              const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

/// Custom painter for drawing a crosshair overlay
class CrosshairPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  CrosshairPainter({
    required this.color,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw horizontal line
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      paint,
    );

    // Draw vertical line
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
