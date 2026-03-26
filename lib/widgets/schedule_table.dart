
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import '../models/calculation_result.dart';
import '../utils/formatters.dart';

class CreditScheduleTable extends StatefulWidget {
  final List<PaymentScheduleRow> schedule;

  const CreditScheduleTable({super.key, required this.schedule});

  @override
  State<CreditScheduleTable> createState() => _CreditScheduleTableState();
}

class _CreditScheduleTableState extends State<CreditScheduleTable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rows = _expanded
        ? widget.schedule
        : widget.schedule.take(6).toList();

    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: const Row(
            children: [
              _ColHeader('Міс.', flex: 1),
              _ColHeader('Платіж', flex: 3),
              _ColHeader('Осн. борг', flex: 3),
              _ColHeader('Відсотки', flex: 3),
              _ColHeader('Залишок', flex: 3),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12)),
          ),
          child: Column(
            children: [
              ...rows.asMap().entries.map((e) {
                final i = e.key;
                final row = e.value;
                return Container(
                  color: i.isOdd
                      ? scheme.surfaceContainerHighest.withValues(alpha: 0.3)
                      : null,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      _Cell(row.month.toString(), flex: 1),
                      _Cell(Formatters.currency(row.payment), flex: 3),
                      _Cell(Formatters.currency(row.principal), flex: 3),
                      _Cell(
                        Formatters.currency(row.interest),
                        flex: 3,
                        color: Colors.red.shade700,
                      ),
                      _Cell(Formatters.currency(row.balance), flex: 3),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        if (widget.schedule.length > 6)
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(_expanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down),
            label: Text(_expanded
                ? 'Приховати'
                : 'Показати всі ${widget.schedule.length} місяців'),
          ),
      ],
    );
  }
}

class DepositScheduleTable extends StatefulWidget {
  final List<DepositAccrualRow> schedule;

  const DepositScheduleTable({super.key, required this.schedule});

  @override
  State<DepositScheduleTable> createState() => _DepositScheduleTableState();
}

class _DepositScheduleTableState extends State<DepositScheduleTable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rows = _expanded
        ? widget.schedule
        : widget.schedule.take(6).toList();

    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: const Row(
            children: [
              _ColHeader('Міс.', flex: 1),
              _ColHeader('Баланс', flex: 3),
              _ColHeader('Нараховано', flex: 3),
              _ColHeader('Накопичено %', flex: 3),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12)),
          ),
          child: Column(
            children: [
              ...rows.asMap().entries.map((e) {
                final i = e.key;
                final row = e.value;
                return Container(
                  color: i.isOdd
                      ? scheme.surfaceContainerHighest.withValues(alpha: 0.3)
                      : null,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      _Cell(row.month.toString(), flex: 1),
                      _Cell(Formatters.currency(row.balance), flex: 3),
                      _Cell(
                        Formatters.currency(row.accrued),
                        flex: 3,
                        color: Colors.green.shade700,
                      ),
                      _Cell(
                        Formatters.currency(row.cumulative),
                        flex: 3,
                        color: Colors.green.shade900,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        if (widget.schedule.length > 6)
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(_expanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down),
            label: Text(_expanded
                ? 'Приховати'
                : 'Показати всі ${widget.schedule.length} місяців'),
          ),
      ],
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String text;
  final int flex;

  const _ColHeader(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final int flex;
  final Color? color;

  const _Cell(this.text, {required this.flex, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
