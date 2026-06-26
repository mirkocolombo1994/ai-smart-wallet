import 'package:flutter/material.dart';
import 'forecast_chart_painter.dart';
import '../utils/currency_formatter.dart';

class InteractiveForecastChart extends StatefulWidget {
  final List<double> data;
  final Color lineColor;

  const InteractiveForecastChart({
    super.key,
    required this.data,
    required this.lineColor,
  });

  @override
  State<InteractiveForecastChart> createState() => _InteractiveForecastChartState();
}

class _InteractiveForecastChartState extends State<InteractiveForecastChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onHorizontalDragUpdate: (details) => _updateSelection(details.localPosition, constraints.maxWidth),
          onTapDown: (details) => _updateSelection(details.localPosition, constraints.maxWidth),
          onTapUp: (_) => setState(() => _selectedIndex = null),
          onHorizontalDragEnd: (_) => setState(() => _selectedIndex = null),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: CustomPaint(
                  painter: ForecastChartPainter(
                    data: widget.data,
                    lineColor: widget.lineColor,
                    selectedIndex: _selectedIndex,
                  ),
                ),
              ),
              if (_selectedIndex != null)
                Positioned(
                  left: _getTooltipLeftPos(constraints.maxWidth),
                  top: -40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF334155)),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Giorno +${_selectedIndex! + 1}',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                        ),
                        Text(
                          formatCurrency(widget.data[_selectedIndex!]),
                          style: TextStyle(
                            color: widget.lineColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _updateSelection(Offset localPosition, double width) {
    final dx = width / (widget.data.length - 1);
    int index = (localPosition.dx / dx).round();
    if (index < 0) index = 0;
    if (index >= widget.data.length) index = widget.data.length - 1;

    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  double _getTooltipLeftPos(double width) {
    if (_selectedIndex == null) return 0;
    final dx = width / (widget.data.length - 1);
    double pos = _selectedIndex! * dx - 40; // Center tooltip
    if (pos < 0) pos = 0;
    if (pos > width - 80) pos = width - 80;
    return pos;
  }
}
