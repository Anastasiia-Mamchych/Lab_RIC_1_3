// ============================================================
//  screens/deposit_screen.dart
//  Екран розрахунку депозиту
// ============================================================

import 'package:flutter/material.dart';
import '../models/calculation_result.dart';
import '../services/calculator_service.dart';
import '../services/file_service.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';
import '../widgets/result_card.dart';
import '../widgets/schedule_table.dart';
import '../widgets/breakdown_chart.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _termCtrl = TextEditingController();
  final _contributionCtrl = TextEditingController(text: '0');

  bool _isCapitalized = true;
  DepositResult? _result;
  bool _isSaving = false;
  String? _savedPath;
  bool _showBanner = false;

  final _resultKey = GlobalKey();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _termCtrl.dispose();
    _contributionCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final amount = Validators.parseDouble(_amountCtrl.text);
    final rate = Validators.parseDouble(_rateCtrl.text);
    final term = int.parse(_termCtrl.text.trim());
    final contribText = _contributionCtrl.text.trim();
    final contribution = contribText.isEmpty
        ? 0.0
        : Validators.parseDouble(contribText);

    setState(() {
      _result = CalculatorService.calculateDeposit(
        initialAmount: amount,
        monthlyContribution: contribution,
        annualRate: rate,
        termMonths: term,
        isCapitalized: _isCapitalized,
      );
      _savedPath = null;
      _showBanner = false;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_resultKey.currentContext != null) {
        Scrollable.ensureVisible(
          _resultKey.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _save() async {
    if (_result == null) return;
    setState(() => _isSaving = true);
    try {
      final path = await FileService.saveDepositResult(_result!);
      setState(() {
        _savedPath = path;
        _showBanner = true;
        _isSaving = false;
      });
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка збереження: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _reset() {
    _formKey.currentState?.reset();
    _amountCtrl.clear();
    _rateCtrl.clear();
    _termCtrl.clear();
    _contributionCtrl.text = '0';
    setState(() {
      _result = null;
      _savedPath = null;
      _showBanner = false;
      _isCapitalized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputCard(scheme),
          const SizedBox(height: 16),
          if (_result != null) ...[
            if (_showBanner && _savedPath != null)
              SaveSuccessBanner(
                filePath: _savedPath!,
                onDismiss: () => setState(() => _showBanner = false),
              ),
            _buildResultCard(scheme),
          ],
        ],
      ),
    );
  }

  Widget _buildInputCard(ColorScheme scheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.savings_rounded,
                        color: scheme.secondary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Параметри депозиту',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text('Нарахування відсотків',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    TypeToggleButton(
                      label: 'Складний %',
                      subtitle: 'Капіталізація щомісяця',
                      icon: Icons.auto_graph_rounded,
                      selected: _isCapitalized,
                      color: scheme.secondary,
                      onColor: scheme.onSecondary,
                      onTap: () => setState(() => _isCapitalized = true),
                    ),
                    Container(
                        width: 1,
                        height: 60,
                        color: scheme.outlineVariant),
                    TypeToggleButton(
                      label: 'Простий %',
                      subtitle: 'Без капіталізації',
                      icon: Icons.show_chart_rounded,
                      selected: !_isCapitalized,
                      color: scheme.secondary,
                      onColor: scheme.onSecondary,
                      onTap: () => setState(() => _isCapitalized = false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _amountCtrl,
                label: 'Початкова сума',
                hint: 'напр. 50000',
                suffix: 'UAH',
                prefixIcon: Icons.account_balance_wallet_outlined,
                validator: (v) =>
                    Validators.amount(v, label: 'Початкова сума'),
              ),
              const SizedBox(height: 12),

              AppTextField(
                controller: _contributionCtrl,
                label: 'Щомісячне поповнення',
                hint: '0',
                suffix: 'UAH',
                prefixIcon: Icons.add_circle_outline_rounded,
                validator: Validators.contribution,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _rateCtrl,
                      label: 'Річна ставка',
                      hint: 'напр. 15',
                      suffix: '%',
                      prefixIcon: Icons.percent_rounded,
                      validator: Validators.rate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _termCtrl,
                      label: 'Термін',
                      hint: 'напр. 12',
                      suffix: 'міс.',
                      prefixIcon: Icons.calendar_month_rounded,
                      keyboardType: TextInputType.number,
                      validator: Validators.term,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Очистити'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate_rounded),
                      label: const Text('Розрахувати'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.secondary,
                        foregroundColor: scheme.onSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(ColorScheme scheme) {
    final r = _result!;

    return Card(
      key: _resultKey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.trending_up_rounded,
                      color: Colors.green.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Результати розрахунку',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(
                        '${r.isCapitalized ? 'Складний %' : 'Простий %'} • '
                        '${Formatters.months(r.termMonths)}',
                        style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            const SectionTitle(
              text: 'Ключові показники',
              icon: Icons.bar_chart_rounded,
            ),
            const SizedBox(height: 8),
            ResultCard(
              label: 'Кінцева сума',
              value: Formatters.currency(r.finalAmount),
              icon: Icons.account_balance_wallet_rounded,
              valueColor: Colors.green.shade700,
            ),
            const SizedBox(height: 8),
            ResultCard(
              label: 'Загальна сума внесків',
              value: Formatters.currency(r.totalContributions),
              icon: Icons.payments_rounded,
            ),
            const SizedBox(height: 8),
            ResultCard(
              label: 'Нараховані відсотки',
              value: Formatters.currency(r.totalInterest),
              icon: Icons.trending_up_rounded,
              valueColor: Colors.green.shade700,
            ),
            const SizedBox(height: 8),
            ResultCard(
              label: 'Ефективна річна ставка',
              value: Formatters.percent(r.effectiveRate),
              icon: Icons.percent_rounded,
              valueColor: scheme.secondary,
            ),
            const SizedBox(height: 20),

            const SectionTitle(
              text: 'Структура доходу',
              icon: Icons.pie_chart_rounded,
            ),
            const SizedBox(height: 12),
            BreakdownChart(
              value1: r.totalInterest,
              value2: r.totalContributions,
              label1: 'Відсотки (дохід)',
              label2: 'Ваші внески',
              color1: Colors.green.shade500,
              color2: scheme.secondary,
            ),
            const SizedBox(height: 20),

            const SectionTitle(
              text: 'Графік нарахування',
              icon: Icons.table_chart_rounded,
            ),
            const SizedBox(height: 8),
            DepositScheduleTable(schedule: r.schedule),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_alt_rounded),
              label: Text(
                  _isSaving ? 'Збереження...' : 'Зберегти результати у файл'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


