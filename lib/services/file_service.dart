import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart' as pp;
import '../models/calculation_result.dart';
import '../utils/formatters.dart';

class FileService {
  static final DateFormat _dtFmt = DateFormat('dd.MM.yyyy HH:mm', 'uk_UA');
  static final DateFormat _fileFmt = DateFormat('yyyyMMdd_HHmmss');

  static Future<String> saveCreditResult(CreditResult result) async {
    final b = StringBuffer();
    b.writeln('РОЗРАХУНОК КРЕДИТУ');
    b.writeln('Дата: ${_dtFmt.format(DateTime.now())}');
    b.writeln();
    b.writeln('ВХІДНІ ДАНІ');
    b.writeln('Сума кредиту: ${Formatters.currency(result.amount)}');
    b.writeln('Річна ставка: ${Formatters.percent(result.annualRate)}');
    b.writeln(
        'Термін: ${result.termMonths} міс. (${Formatters.months(result.termMonths)})');
    b.writeln('Тип: ${result.isAnnuity ? 'Ануїтетний' : 'Диференційований'}');
    b.writeln();
    b.writeln('РЕЗУЛЬТАТИ');
    b.writeln(
        '${result.isAnnuity ? 'Щомісячний платіж' : 'Перший платіж'}: ${Formatters.currency(result.monthlyPayment)}');
    b.writeln(
        'Загальна сума виплат: ${Formatters.currency(result.totalPayment)}');
    b.writeln('Сума відсотків: ${Formatters.currency(result.totalInterest)}');
    b.writeln(
        'Переплата: ${Formatters.percent(result.overpaymentPercent)} від суми кредиту');
    b.writeln();
    b.writeln('ГРАФІК ПЛАТЕЖІВ');
    b.writeln(
        '${'Міс'.padRight(5)}${'Платіж'.padLeft(14)}${'Осн. борг'.padLeft(14)}${'Відсотки'.padLeft(14)}${'Залишок'.padLeft(14)}');
    b.writeln('-' * 61);
    for (final row in result.schedule) {
      b.writeln(
          '${row.month.toString().padRight(5)}${Formatters.currency(row.payment).padLeft(14)}${Formatters.currency(row.principal).padLeft(14)}${Formatters.currency(row.interest).padLeft(14)}${Formatters.currency(row.balance).padLeft(14)}');
    }
    return _writeFile('credit', b.toString());
  }

  static Future<String> saveDepositResult(DepositResult result) async {
    final b = StringBuffer();
    b.writeln('РОЗРАХУНОК ДЕПОЗИТУ');
    b.writeln('Дата: ${_dtFmt.format(DateTime.now())}');
    b.writeln();
    b.writeln('ВХІДНІ ДАНІ');
    b.writeln('Початкова сума: ${Formatters.currency(result.initialAmount)}');
    b.writeln(
        'Щомісячне поповнення: ${Formatters.currency(result.monthlyContribution)}');
    b.writeln('Річна ставка: ${Formatters.percent(result.annualRate)}');
    b.writeln(
        'Термін: ${result.termMonths} міс. (${Formatters.months(result.termMonths)})');
    b.writeln(
        'Нарахування: ${result.isCapitalized ? 'Складний %' : 'Простий %'}');
    b.writeln();
    b.writeln('РЕЗУЛЬТАТИ');
    b.writeln(
        'Загальна сума внесків: ${Formatters.currency(result.totalContributions)}');
    b.writeln(
        'Нараховані відсотки: ${Formatters.currency(result.totalInterest)}');
    b.writeln('Кінцева сума: ${Formatters.currency(result.finalAmount)}');
    b.writeln(
        'Ефективна річна ставка: ${Formatters.percent(result.effectiveRate)}');
    b.writeln();
    b.writeln('ГРАФІК НАРАХУВАННЯ');
    b.writeln(
        '${'Міс'.padRight(5)}${'Баланс'.padLeft(16)}${'Нараховано'.padLeft(14)}${'Накопичено'.padLeft(14)}');
    b.writeln('-' * 49);
    for (final row in result.schedule) {
      b.writeln(
          '${row.month.toString().padRight(5)}${Formatters.currency(row.balance).padLeft(16)}${Formatters.currency(row.accrued).padLeft(14)}${Formatters.currency(row.cumulative).padLeft(14)}');
    }
    return _writeFile('deposit', b.toString());
  }

  static Future<String> _writeFile(String prefix, String content) async {
    final Directory dir = await _getOutputDirectory();
    final String fileName = '${prefix}_${_fileFmt.format(DateTime.now())}.txt';
    final File file = File('${dir.path}/$fileName');
    await file.writeAsString(content, encoding: const Utf8Codec());
    return _friendlyPath(file.path);
  }

  static String _friendlyPath(String fullPath) {
    final home = Platform.environment['HOME'] ?? '';
    if (home.isNotEmpty && fullPath.startsWith(home)) {
      final relative = fullPath.substring(home.length);
      if (relative.startsWith('/Desktop/')) {
        return 'Робочий стіл${relative.substring('/Desktop'.length)}';
      }
      if (relative.startsWith('/Робочий стіл/')) {
        return 'Робочий стіл${relative.substring('/Робочий стіл'.length)}';
      }
      if (relative.startsWith('/Downloads/')) {
        return 'Завантаження${relative.substring('/Downloads'.length)}';
      }
      return '~$relative';
    }
    return fullPath;
  }

  static Future<Directory> _getOutputDirectory() async {
    try {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final desktopEn = Directory('$home/Desktop/CalculatorResults');
        final desktopUk = Directory('$home/Робочий стіл/CalculatorResults');
        if (await Directory('$home/Desktop').exists()) {
          if (!await desktopEn.exists()) {
            await desktopEn.create(recursive: true);
          }
          return desktopEn;
        } else if (await Directory('$home/Робочий стіл').exists()) {
          if (!await desktopUk.exists()) {
            await desktopUk.create(recursive: true);
          }
          return desktopUk;
        }
      }
    } catch (_) {}
    try {
      final downloads = await pp.getDownloadsDirectory();
      if (downloads != null && await downloads.exists()) {
        final outDir = Directory('${downloads.path}/CalculatorResults');
        if (!await outDir.exists()) await outDir.create(recursive: true);
        return outDir;
      }
    } catch (_) {}
    try {
      final docs = await pp.getApplicationDocumentsDirectory();
      final outDir = Directory('${docs.path}/CalculatorResults');
      if (!await outDir.exists()) await outDir.create(recursive: true);
      return outDir;
    } catch (_) {}
    return Directory.systemTemp;
  }

  static Future<List<FileSystemEntity>> listSavedFiles() async {
    try {
      final dir = await _getOutputDirectory();
      final entities = dir
          .listSync()
          .where((e) =>
              e is File &&
              (e.path.contains('credit_') || e.path.contains('deposit_')))
          .toList();
      entities.sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      return entities;
    } catch (_) {
      return [];
    }
  }
}
