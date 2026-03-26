import 'package:flutter/material.dart';
import '../models/calculation_result.dart';
import '../services/calculator_service.dart';
import '../services/file_service.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';
import '../widgets/result_card.dart';
import '../widgets/schedule_table.dart';
import '../widgets/breakdown_chart.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _termCtrl = TextEditingController();

  bool _isAnnuity = true;
  CreditResult? _result;
  bool _isSaving = false;
  String? _savedPath;
  bool _showBanner = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _termCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final amount = Validators.parseDouble(_amountCtrl.text);
    final rate = Validators.parseDouble(_rateCtrl.text);
    final term = int.parse(_termCtrl.text.trim());

    setState(() {
      _result = CalculatorService.calculateCredit(
        amount: amount,
        annualRate: rate,
        termMonths: term,
        isAnnuity: _isAnnuity,
      );
      _savedPath = null;
      _showBanner = false;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      Scrollable.ensureVisible(
        _resultKey.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  final _resultKey = GlobalKey();

  Future<void> _save() async {
    if (_result == null) return;
    setState(() => _isSaving = true);
    try {
      final path = await FileService.saveCreditResult(_result!);
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
    setState(() {
      _result = null;
      _savedPath = null;
      _showBanner = false;
      _isAnnuity = true;
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
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.account_balance_rounded,
                        color: scheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Параметри кредиту',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Тип кредиту',
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
                    _TypeButton(
                      label: 'Ануїтетний',
                      subtitle: 'Фіксований платіж',
                      icon: Icons.calculate_rounded,
                      selected: _isAnnuity,
                      onTap: () => setState(() => _isAnnuity = true),
                    ),
                    Container(
                        width: 1, height: 60, color: scheme.outlineVariant),
                    _TypeButton(
                      label: 'Диференційований',
                      subtitle: 'Зменшується',
                      icon: Icons.trending_down_rounded,
                      selected: !_isAnnuity,
                      onTap: () => setState(() => _isAnnuity = false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _amountCtrl,
                label: 'Сума кредиту',
                hint: 'напр. 200000',
                suffix: 'UAH',
                prefixIcon: Icons.payments_outlined,
                validator: (v) => Validators.amount(v, label: 'Сума кредиту'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _rateCtrl,
                      label: 'Річна ставка',
                      hint: 'напр. 18',
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
                      hint: 'напр. 36',
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
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
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
                  child: Icon(Icons.check_circle_outline_rounded,
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
                        '${r.isAnnuity ? 'Ануїтетний' : 'Диференційований'} кредит • '
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
              label:
                  r.isAnnuity ? 'Щомісячний платіж' : 'Перший місячний платіж',
              value: Formatters.currency(r.monthlyPayment),
              icon: Icons.calendar_today_rounded,
              valueColor: scheme.primary,
            ),
            const SizedBox(height: 8),
            ResultCard(
              label: 'Загальна сума виплат',
              value: Formatters.currency(r.totalPayment),
              icon: Icons.account_balance_wallet_rounded,
            ),
            const SizedBox(height: 8),
            ResultCard(
              label: 'Сума відсотків',
              value: Formatters.currency(r.totalInterest),
              icon: Icons.trending_up_rounded,
              valueColor: Colors.red.shade700,
            ),
            const SizedBox(height: 8),
            ResultCard(
              label: 'Переплата',
              value: Formatters.percent(r.overpaymentPercent),
              icon: Icons.percent_rounded,
              valueColor: Colors.orange.shade700,
            ),
            const SizedBox(height: 20),

            const SectionTitle(
              text: 'Структура виплат',
              icon: Icons.pie_chart_rounded,
            ),
            const SizedBox(height: 12),
            BreakdownChart(
              value1: r.amount,
              value2: r.totalInterest,
              label1: 'Основний борг',
              label2: 'Відсотки',
              color1: scheme.primary,
              color2: Colors.red.shade400,
            ),
            const SizedBox(height: 20),

            const SectionTitle(
              text: 'Графік платежів',
              icon: Icons.table_chart_rounded,
            ),
            const SizedBox(height: 8),
            CreditScheduleTable(schedule: r.schedule),
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

class _TypeButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : null,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? scheme.onPrimary : scheme.onSurface,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: selected
                      ? scheme.onPrimary.withValues(alpha: 0.75)
                      : scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
