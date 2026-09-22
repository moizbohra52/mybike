class DataMaskingService {
  /// Masks a 12-digit Aadhaar number as XXXX-XXXX-1234 or •••• •••• 1234
  static String maskAadhaar(String? aadhaar) {
    if (aadhaar == null || aadhaar.isEmpty) return '';
    final clean = aadhaar.replaceAll(RegExp(r'\D'), '');
    if (clean.length != 12) return aadhaar; // Return as is if invalid length
    return '•••• •••• ${clean.substring(8)}';
  }

  /// Masks a 10-character PAN number as ••••• 1234X
  static String maskPan(String? pan) {
    if (pan == null || pan.isEmpty) return '';
    final clean = pan.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (clean.length != 10) return pan;
    return '••••• ${clean.substring(5)}';
  }

  /// Masks a bank account number revealing only the last 4 digits
  static String maskBankAccount(String? accNo) {
    if (accNo == null || accNo.isEmpty) return '';
    final clean = accNo.replaceAll(RegExp(r'\s+'), '');
    if (clean.length <= 4) return clean;
    final maskedLength = clean.length - 4;
    return '${'•' * maskedLength}${clean.substring(maskedLength)}';
  }

  /// Masks a phone number (assumes Indian +91 format or 10 digits)
  static String maskPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 10) return phone;
    
    // Support 10 digit or 12 digit (with 91 prefix)
    final isWithPrefix = clean.length > 10;
    final last4 = clean.substring(clean.length - 4);
    
    if (isWithPrefix) {
      final prefix = clean.substring(0, clean.length - 10); // e.g. 91
      return '+$prefix ••••• •$last4';
    }
    
    return '••••• •$last4';
  }

  /// Obfuscates an email address
  static String maskEmail(String? email) {
    if (email == null || email.isEmpty || !email.contains('@')) return email ?? '';
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    
    if (name.length <= 2) {
      return '${name[0]}•••@$domain';
    }
    
    return '${name[0]}${'•' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  /// Recursively sanitizes a JSON payload by masking or removing sensitive keys
  static Map<String, dynamic> sanitizePayload(Map<String, dynamic> payload) {
    final sensitiveKeys = {
      'password', 'token', 'secret', 'access_token', 'refresh_token',
      'pin', 'cvv', 'card_number', 'authorization'
    };
    
    Map<String, dynamic> sanitized = {};
    
    payload.forEach((key, value) {
      final lowerKey = key.toLowerCase();
      bool isSensitive = sensitiveKeys.any((s) => lowerKey.contains(s));
      
      if (isSensitive) {
        sanitized[key] = '********';
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = sanitizePayload(value);
      } else if (value is List) {
        sanitized[key] = value.map((item) {
          if (item is Map<String, dynamic>) return sanitizePayload(item);
          return item;
        }).toList();
      } else {
        sanitized[key] = value;
      }
    });
    
    return sanitized;
  }
}
