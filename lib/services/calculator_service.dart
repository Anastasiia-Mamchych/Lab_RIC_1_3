import 'dart:math';
import '../models/calculation_result.dart';

class CalculatorService {
  static CreditResult calculateCredit({
    required double amount,
    required double annualRate,
    required int termMonths,
    required bool isAnnuity,
  }) {
    final double monthlyRate = annualRate / 100 / 12;
    final List<PaymentScheduleRow> schedule = [];
    double totalPayment = 0;
    double totalInterest = 0;

    if (isAnnuity) {
      final double monthly = monthlyRate == 0
          ? amount / termMonths
          : amount *
              monthlyRate *
              pow(1 + monthlyRate, termMonths) /
              (pow(1 + monthlyRate, termMonths) - 1);

      double balance = amount;
      for (int i = 1; i <= termMonths; i++) {
        final double interestPart = balance * monthlyRate;
        final double principalPart = monthly - interestPart;
        balance = (balance - principalPart).clamp(0, double.infinity);
        totalPayment += monthly;
        totalInterest += interestPart;
        schedule.add(PaymentScheduleRow(
          month: i,
          payment: monthly,
          principal: principalPart,
          interest: interestPart,
          balance: balance,
        ));
      }

      return CreditResult(
        amount: amount,
        annualRate: annualRate,
        termMonths: termMonths,
        isAnnuity: true,
        monthlyPayment: monthly,
        totalPayment: totalPayment,
        totalInterest: totalInterest,
        overpaymentPercent: (totalInterest / amount) * 100,
        schedule: schedule,
      );
    } else {
      final double principalPart = amount / termMonths;
      double balance = amount;

      for (int i = 1; i <= termMonths; i++) {
        final double interestPart = balance * monthlyRate;
        final double payment = principalPart + interestPart;
        balance -= principalPart;
        totalPayment += payment;
        totalInterest += interestPart;
        schedule.add(PaymentScheduleRow(
          month: i,
          payment: payment,
          principal: principalPart,
          interest: interestPart,
          balance: balance.clamp(0, double.infinity),
        ));
      }

      return CreditResult(
        amount: amount,
        annualRate: annualRate,
        termMonths: termMonths,
        isAnnuity: false,
        monthlyPayment: schedule.first.payment,
        totalPayment: totalPayment,
        totalInterest: totalInterest,
        overpaymentPercent: (totalInterest / amount) * 100,
        schedule: schedule,
      );
    }
  }

  static DepositResult calculateDeposit({
    required double initialAmount,
    required double monthlyContribution,
    required double annualRate,
    required int termMonths,
    required bool isCapitalized,
  }) {
    final double monthlyRate = annualRate / 100 / 12;
    final List<DepositAccrualRow> schedule = [];
    double balance = initialAmount;
    double cumulativeInterest = 0;
    double totalContributions = initialAmount;

    if (isCapitalized) {
      for (int i = 1; i <= termMonths; i++) {
        final double accrued = balance * monthlyRate;
        balance += accrued + monthlyContribution;
        cumulativeInterest += accrued;
        if (i > 1) totalContributions += monthlyContribution;
        schedule.add(DepositAccrualRow(
          month: i,
          balance: balance,
          accrued: accrued,
          cumulative: cumulativeInterest,
        ));
      }
    } else {
      for (int i = 1; i <= termMonths; i++) {
        if (i > 1) {
          balance += monthlyContribution;
          totalContributions += monthlyContribution;
        }
        final double accrued = initialAmount * monthlyRate;
        cumulativeInterest += accrued;
        schedule.add(DepositAccrualRow(
          month: i,
          balance: balance + cumulativeInterest,
          accrued: accrued,
          cumulative: cumulativeInterest,
        ));
      }
      balance += cumulativeInterest;
    }

    final double years = termMonths / 12;
    final double effectiveRate = years > 0
        ? (pow(balance / totalContributions, 1 / years) - 1) * 100
        : annualRate;

    return DepositResult(
      initialAmount: initialAmount,
      monthlyContribution: monthlyContribution,
      annualRate: annualRate,
      termMonths: termMonths,
      isCapitalized: isCapitalized,
      finalAmount: balance,
      totalInterest: cumulativeInterest,
      totalContributions: totalContributions,
      effectiveRate: effectiveRate,
      schedule: schedule,
    );
  }
}
