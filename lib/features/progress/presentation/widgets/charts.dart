import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/widgets/clay_surface.dart';

/// Card that wraps a single-series chart with a title, a short caption and
/// a "table" toggle so values are never available only as a graphic.
class ChartCard extends StatefulWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.caption,
    required this.points,
    required this.unit,
    this.bars = false,
    this.maxY,
  });

  final String title;
  final String caption;

  /// (day, value) oldest first; null values are gaps.
  final List<(DateTime, double?)> points;
  final String unit;
  final bool bars;
  final double? maxY;

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {
  bool _table = false;

  @override
  Widget build(BuildContext context) {
    final withData = widget.points.where((p) => p.$2 != null).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: ClaySurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.title, style: context.text.titleMedium)),
                TextButton(onPressed: () => setState(() => _table = !_table), child: Text(_table ? 'Chart' : 'Table')),
              ],
            ),
            Text(widget.caption, style: context.text.bodySmall),
            const SizedBox(height: Gap.lg),
            if (withData.length < 2)
              SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'Not enough data yet. A few entries will show a trend.',
                    style: context.text.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (_table)
              _ValueTable(points: withData, unit: widget.unit)
            else
              Semantics(
                label: '${widget.title} chart. Use the Table button for values.',
                child: SizedBox(height: 170, child: widget.bars ? _bar(context) : _line(context)),
              ),
          ],
        ),
      ),
    );
  }

  FlTitlesData _titles(BuildContext context) {
    final style = context.text.labelSmall!;
    final n = widget.points.length;
    final step = (n / 4).ceil().clamp(1, n);
    return FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (v, meta) => v == meta.max || v != v.roundToDouble()
              ? const SizedBox.shrink()
              : SideTitleWidget(
                  meta: meta,
                  child: Text(v.toInt().toString(), style: style),
                ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: 1,
          getTitlesWidget: (v, meta) {
            final i = v.toInt();
            if (i < 0 || i >= n || (n - 1 - i) % step != 0) return const SizedBox.shrink();
            return SideTitleWidget(
              meta: meta,
              child: Text(DateFormat.Md().format(widget.points[i].$1), style: style),
            );
          },
        ),
      ),
    );
  }

  FlGridData _grid(BuildContext context) => FlGridData(
    drawVerticalLine: false,
    getDrawingHorizontalLine: (_) => FlLine(color: context.clay.textSecondary.withValues(alpha: 0.12), strokeWidth: 1),
  );

  Widget _line(BuildContext context) {
    final clay = context.clay;
    final spots = [
      for (final (i, p) in widget.points.indexed) p.$2 == null ? FlSpot.nullSpot : FlSpot(i.toDouble(), p.$2!),
    ];
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: widget.maxY,
        gridData: _grid(context),
        borderData: FlBorderData(show: false),
        titlesData: _titles(context),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => clay.brand,
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(
                  '${DateFormat.MMMd().format(widget.points[s.x.toInt()].$1)}\n${_fmt(s.y)} ${widget.unit}',
                  context.text.labelMedium!.copyWith(color: clay.onBrand),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: clay.chart,
            barWidth: 2,
            isCurved: true,
            preventCurveOverShooting: true,
            dotData: FlDotData(
              getDotPainter: (_, _, _, _) =>
                  FlDotCirclePainter(radius: 4, color: clay.chart, strokeWidth: 2, strokeColor: clay.surface),
            ),
            belowBarData: BarAreaData(show: true, color: clay.chart.withValues(alpha: 0.10)),
          ),
        ],
      ),
    );
  }

  Widget _bar(BuildContext context) {
    final clay = context.clay;
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: widget.maxY,
        gridData: _grid(context),
        borderData: FlBorderData(show: false),
        titlesData: _titles(context),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => clay.brand,
            getTooltipItem: (group, _, rod, _) => BarTooltipItem(
              '${DateFormat.MMMd().format(widget.points[group.x].$1)}\n${_fmt(rod.toY)} ${widget.unit}',
              context.text.labelMedium!.copyWith(color: clay.onBrand),
            ),
          ),
        ),
        barGroups: [
          for (final (i, p) in widget.points.indexed)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: p.$2 ?? 0,
                  color: clay.chart,
                  width: widget.points.length > 14 ? 6 : 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

class _ValueTable extends StatelessWidget {
  const _ValueTable({required this.points, required this.unit});
  final List<(DateTime, double?)> points;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final f = DateFormat.MMMEd();
    return Column(
      children: [
        for (final p in points.reversed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(child: Text(f.format(p.$1), style: context.text.bodyMedium)),
                Text('${_ChartCardState._fmt(p.$2!)} $unit', style: context.text.titleSmall),
              ],
            ),
          ),
      ],
    );
  }
}
