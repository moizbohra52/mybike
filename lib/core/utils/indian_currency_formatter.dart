/// Indian Currency & Number Formatting Utilities
///
/// Converts numeric amounts into Indian Currency words (Crores, Lakhs,
/// Thousands, Hundreds) and Indian comma-separated format for GST invoices,
/// money receipts, and financial statements.
class IndianCurrencyFormatter {
  IndianCurrencyFormatter._();

  static const List<String> _units = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];

  static const List<String> _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  /// Converts a number less than 1000 to words
  static String _convertThreeDigits(int number) {
    if (number == 0) return '';

    final StringBuffer buffer = StringBuffer();
    final int hundreds = number ~/ 100;
    final int remainder = number % 100;

    if (hundreds > 0) {
      buffer.write('${_units[hundreds]} Hundred');
      if (remainder > 0) {
        buffer.write(' and ');
      }
    }

    if (remainder > 0) {
      if (remainder < 20) {
        buffer.write(_units[remainder]);
      } else {
        final int ten = remainder ~/ 10;
        final int unit = remainder % 10;
        buffer.write(_tens[ten]);
        if (unit > 0) {
          buffer.write(' ${_units[unit]}');
        }
      }
    }

    return buffer.toString().trim();
  }

  /// Converts an amount in INR to words following the Indian numbering system:
  /// Crores, Lakhs, Thousands, Hundreds.
  ///
  /// Example:
  /// `125430.50` -> "Rupees One Lakh Twenty-Five Thousand Four Hundred Thirty and Fifty Paise Only"
  static String toWords(double amount) {
    if (amount.isNaN || amount.isInfinite) return 'Zero Rupees Only';
    if (amount == 0.0) return 'Rupees Zero Only';

    final bool isNegative = amount < 0;
    final double positiveAmount = amount.abs();
    final int rupees = positiveAmount.truncate();
    final int paise = ((positiveAmount - rupees) * 100).round();

    if (rupees == 0 && paise == 0) return 'Rupees Zero Only';

    final StringBuffer words = StringBuffer();
    if (isNegative) words.write('Minus ');
    words.write('Rupees ');

    if (rupees > 0) {
      int remaining = rupees;

      // Crores (1,00,00,000)
      final int crores = remaining ~/ 10000000;
      remaining %= 10000000;
      if (crores > 0) {
        words.write('${_convertThreeDigits(crores)} Crore ');
      }

      // Lakhs (1,00,000)
      final int lakhs = remaining ~/ 100000;
      remaining %= 100000;
      if (lakhs > 0) {
        words.write('${_convertThreeDigits(lakhs)} Lakh ');
      }

      // Thousands (1,000)
      final int thousands = remaining ~/ 1000;
      remaining %= 1000;
      if (thousands > 0) {
        words.write('${_convertThreeDigits(thousands)} Thousand ');
      }

      // Hundreds and remaining
      if (remaining > 0) {
        words.write(_convertThreeDigits(remaining));
      }
    }

    if (paise > 0) {
      if (rupees > 0) words.write(' and ');
      words.write('${_convertThreeDigits(paise)} Paise');
    }

    words.write(' Only');
    return words.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Formats amount in Indian numbering format: e.g. 1,54,300.00
  static String formatIndianCurrency(
    double amount, {
    bool showSymbol = true,
    String symbol = '₹ ',
  }) {
    final bool isNegative = amount < 0;
    final double absVal = amount.abs();
    final String fixed = absVal.toStringAsFixed(2);
    final List<String> parts = fixed.split('.');
    final String integerPart = parts[0];
    final String decimalPart = parts[1];

    if (integerPart.length <= 3) {
      final String res = '$integerPart.$decimalPart';
      return '${isNegative ? '-' : ''}${showSymbol ? symbol : ''}$res';
    }

    final String lastThree = integerPart.substring(integerPart.length - 3);
    final String remaining = integerPart.substring(0, integerPart.length - 3);

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < remaining.length; i++) {
      buffer.write(remaining[i]);
      final int charsFromEnd = remaining.length - 1 - i;
      if (charsFromEnd > 0 && charsFromEnd % 2 == 0) {
        buffer.write(',');
      }
    }

    final String formatted = '${buffer.toString()},$lastThree.$decimalPart';
    return '${isNegative ? '-' : ''}${showSymbol ? symbol : ''}$formatted';
  }
}
