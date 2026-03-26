enum CalculationType { credit, deposit }

class PaymentScheduleRow {
  final int month;
  final double payment;
  final double principal;
  final double interest;
  final double balance;

  const PaymentScheduleRow({
    required this.month,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
  });
}

class CreditResult {
  final double amount;
  final double annualRate;
  final int termMonths;
  final bool isAnnuity;
  final double monthlyPayment;
  final double totalPayment;
  final double totalInterest;
  final double overpaymentPercent;
  final List<PaymentScheduleRow> schedule;

  const CreditResult({
    required this.amount,
    required this.annualRate,
    required this.termMonths,
    required this.isAnnuity,
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterest,
    required this.overpaymentPercent,
    required this.schedule,
  });
}

class DepositAccrualRow {
  final int month;
  final double balance;
  final double accrued;
  final double cumulative;

  const DepositAccrualRow({
    required this.month,
    required this.balance,
    required this.accrued,
    required this.cumulative,
  });
}

class DepositResult {
  final double initialAmount;
  final double monthlyContribution;
  final double annualRate;
  final int termMonths;
  final bool isCapitalized;
  final double finalAmount;
  final double totalInterest;
  final double totalContributions;
  final double effectiveRate;
  final List<DepositAccrualRow> schedule;

  const DepositResult({
    required this.initialAmount,
    required this.monthlyContribution,
    required this.annualRate,
    required this.termMonths,
    required this.isCapitalized,
    required this.finalAmount,
    required this.totalInterest,
    required this.totalContributions,
    required this.effectiveRate,
    required this.schedule,
  });
}
