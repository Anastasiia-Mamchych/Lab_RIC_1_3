import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Про застосунок'),
        backgroundColor: scheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Фінансовий калькулятор',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            const Center(
              child: Text(
                'Версія 1.0.0',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            const _InfoSection(
              icon: Icons.school_rounded,
              title: 'Лабораторна робота',
              content:
                  'Лабораторна робота №1\nВаріант 3: Калькулятор кредиту та депозиту',
            ),
            const SizedBox(height: 16),
            const _InfoSection(
              icon: Icons.functions_rounded,
              title: 'Функціональність',
              content: '• Розрахунок ануїтетного кредиту\n'
                  '• Розрахунок диференційованого кредиту\n'
                  '• Розрахунок депозиту зі складним відсотком\n'
                  '• Розрахунок депозиту з простим відсотком\n'
                  '• Щомісячне поповнення депозиту\n'
                  '• Графік платежів / нарахувань\n'
                  '• Кругова діаграма структури виплат\n'
                  '• Збереження результатів у текстовий файл',
            ),
            const SizedBox(height: 16),
            const _InfoSection(
              icon: Icons.calculate_rounded,
              title: 'Формули розрахунку',
              content:
                  'Ануїтетний кредит:\nM = P × r × (1+r)ⁿ / ((1+r)ⁿ - 1)\n\n'
                  'Диференційований кредит:\nMᵢ = P/n + (P - P/n × (i-1)) × r\n\n'
                  'Складний відсоток (FV):\nFV = PV × (1+r)ⁿ\n\n'
                  'де: P — сума, r — місячна ставка, n — кількість місяців',
            ),
            const SizedBox(height: 16),
            const _InfoSection(
              icon: Icons.save_rounded,
              title: 'Збереження файлів',
              content:
                  'Результати зберігаються у текстовий (.txt) файл у папку документів застосунку. Файл містить усі вхідні дані, результати розрахунку та детальний графік платежів.',
            ),
            const SizedBox(height: 16),
            const _InfoSection(
              icon: Icons.build_rounded,
              title: 'Технології',
              content:
                  'Flutter (Dart)\nMaterial Design 3\npath_provider (для роботи з файловою системою)',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                '© 2026 Лабораторна робота Розробка інтерфейсів користувачів',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}
