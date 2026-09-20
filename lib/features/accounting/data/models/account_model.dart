import '../../domain/entities/account_entity.dart';

/// Chart of Accounts Data Model (Supabase JSON ↔ Entity)
class AccountModel {
  const AccountModel._();

  static AccountEntity fromJson(Map<String, dynamic> json) {
    return AccountEntity(
      id: json['id'] as String,
      showroomId: json['showroom_id'] as String?,
      accountCode: json['account_code'] as String,
      accountName: json['account_name'] as String,
      accountType: json['account_type'] as String,
      subType: json['sub_type'] as String,
      parentId: json['parent_id'] as String?,
      openingBalance: (json['opening_balance'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      isActive: json['is_active'] as bool? ?? true,
      isSystemAccount: json['is_system_account'] as bool? ?? false,
      isReconciled: json['is_reconciled'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      showroomName: json['showroom_name'] as String?,
    );
  }

  static Map<String, dynamic> toJson(AccountEntity entity) {
    return {
      'id': entity.id,
      'showroom_id': entity.showroomId,
      'account_code': entity.accountCode,
      'account_name': entity.accountName,
      'account_type': entity.accountType,
      'sub_type': entity.subType,
      'parent_id': entity.parentId,
      'opening_balance': entity.openingBalance,
      'current_balance': entity.currentBalance,
      'currency': entity.currency,
      'is_active': entity.isActive,
      'is_system_account': entity.isSystemAccount,
      'is_reconciled': entity.isReconciled,
      'created_at': entity.createdAt.toIso8601String(),
      'updated_at': entity.updatedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> toInsertJson(AccountEntity entity) {
    final map = toJson(entity);
    if (entity.id.isEmpty) {
      map.remove('id');
    }
    return map;
  }
}
