/// Data Masking and PII Redaction Service for statutory Indian compliance (Aadhaar, PAN, Bank, Phone).
class DataMaskingService {
  DataMaskingService._();

  static const Set<String> _sensitiveKeys = {
    'password',
    'pass',
    'secret',
    'token',
    'access_token',
    'refresh_token',
    'jwt',
    'authorization',
    'api_key',
    'pin',
    'cvv',
    'auth_code',
    'private_key',
  };

  /// Mask a 12-digit Indian Aadhaar number.
  ///
  /// Example: "123456789012" -> "•••• •••• 9012"
  static String maskAadhaar(String? aadhaar) {
    if (aadhaar == null || aadhaar.trim().isEmpty) return '';
    final cleaned = aadhaar.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 12) {
      // Fallback for non-standard lengths
      if (cleaned.length <= 4) return '••••';
      final last4 = cleaned.substring(cleaned.length - 4);
      return '•••• •••• $last4';
    }
    final last4 = cleaned.substring(8);
    return '•••• •••• $last4';
  }

  /// Mask an Indian Permanent Account Number (PAN).
  ///
  /// Example: "ABCDE1234F" -> "••••• 1234F"
  static String maskPan(String? pan) {
    if (pan == null || pan.trim().isEmpty) return '';
    final cleaned = pan.trim().replaceAll(' ', '').toUpperCase();
    if (cleaned.length < 5) return '•••••';
    if (cleaned.length == 10) {
      final suffix = cleaned.substring(5);
      return '••••• $suffix';
    }
    final visibleCount = (cleaned.length * 0.4).ceil();
    final suffix = cleaned.substring(cleaned.length - visibleCount);
    return '${'•' * (cleaned.length - visibleCount)} $suffix';
  }

  /// Mask a Bank Account Number revealing only the trailing digits.
  ///
  /// Example: "12345678901234" -> "••••••••••••1234"
  static String maskBankAccount(String? accountNumber) {
    if (accountNumber == null || accountNumber.trim().isEmpty) return '';
    final cleaned = accountNumber.trim().replaceAll(RegExp(r'\s+|-'), '');
    if (cleaned.length <= 4) return '••••';
    final last4 = cleaned.substring(cleaned.length - 4);
    return '${'•' * (cleaned.length - 4)}$last4';
  }

  /// Mask a Phone Number showing country code and trailing digits.
  ///
  /// Example: "+919820012345" -> "+91 98200 •••45"
  static String maskPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return '';
    final cleaned = phone.trim().replaceAll(RegExp(r'\s+|-'), '');
    if (cleaned.length <= 4) return '••••';

    if (cleaned.length >= 10) {
      final last2 = cleaned.substring(cleaned.length - 2);
      final firstPart = cleaned.substring(0, cleaned.length - 5);
      return '$firstPart •••$last2';
    }
    final last2 = cleaned.substring(cleaned.length - 2);
    return '${'•' * (cleaned.length - 2)}$last2';
  }

  /// Mask an Email address preserving first letter, domain, and TLD.
  ///
  /// Example: "john.doe@example.com" -> "j•••e@example.com"
  static String maskEmail(String? email) {
    if (email == null || email.trim().isEmpty) return '';
    final parts = email.trim().split('@');
    if (parts.length != 2) return '••••@••••';

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '${name[0]}•@$domain';
    }

    final first = name[0];
    final last = name[name.length - 1];
    return '$first•••$last@$domain';
  }

  /// Recursively sanitizes JSON map payload, redacting passwords, secrets, and auth tokens.
  static Map<String, dynamic> sanitizePayload(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) return {};

    final result = <String, dynamic>{};

    for (final entry in payload.entries) {
      final keyLower = entry.key.toLowerCase();

      // Check if key is in sensitive list
      if (_sensitiveKeys.contains(keyLower) ||
          keyLower.contains('password') ||
          keyLower.contains('secret') ||
          keyLower.contains('token')) {
        result[entry.key] = '[REDACTED]';
      } else if (entry.value is Map<String, dynamic>) {
        result[entry.key] = sanitizePayload(entry.value as Map<String, dynamic>);
      } else if (entry.value is List) {
        result[entry.key] = _sanitizeList(entry.value as List);
      } else {
        result[entry.key] = entry.value;
      }
    }

    return result;
  }

  static List<dynamic> _sanitizeList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return sanitizePayload(item);
      } else if (item is List) {
        return _sanitizeList(item);
      }
      return item;
    }).toList();
  }
}
