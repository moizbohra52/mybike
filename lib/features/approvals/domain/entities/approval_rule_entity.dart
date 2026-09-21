import 'package:equatable/equatable.dart';

/// Approval Policy Rule Entity
class ApprovalRuleEntity extends Equatable {
  final String id;
  final String transactionType; // 'expense', 'discount', 'purchase', 'payment', 'stock_adjustment', 'stock_transfer', 'other'
  final String name;
  final String? description;
  final double thresholdAmount;
  final String requiredRole; // 'showroom_manager', 'sales_manager', 'accountant', 'admin', 'cfo'
  final String? showroomId;
  final bool isActive;
  final bool autoApproveBelowThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ApprovalRuleEntity({
    required this.id,
    required this.transactionType,
    required this.name,
    this.description,
    required this.thresholdAmount,
    required this.requiredRole,
    this.showroomId,
    this.isActive = true,
    this.autoApproveBelowThreshold = true,
    required this.createdAt,
    required this.updatedAt,
  });

  String get typeLabel {
    switch (transactionType.toLowerCase()) {
      case 'expense':
        return 'Operating Expenses';
      case 'discount':
        return 'Retail Sales Discounts';
      case 'purchase':
        return 'OEM / Inventory Purchases';
      case 'payment':
        return 'Supplier & Outgoing Payments';
      case 'stock_adjustment':
        return 'Stock Discrepancies & Scraps';
      case 'stock_transfer':
        return 'Inter-Branch Stock Transfers';
      default:
        return transactionType.toUpperCase();
    }
  }

  String get requiredRoleLabel {
    switch (requiredRole.toLowerCase()) {
      case 'showroom_manager':
        return 'Showroom Branch Manager';
      case 'sales_manager':
        return 'Sales Manager';
      case 'accountant':
        return 'Senior Accountant';
      case 'cfo':
        return 'Chief Financial Officer (CFO)';
      case 'admin':
        return 'System Administrator';
      default:
        return requiredRole;
    }
  }

  String get formattedThreshold {
    if (thresholdAmount == 0) return 'All Transactions';
    return 'Exceeds ₹${thresholdAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  ApprovalRuleEntity copyWith({
    String? id,
    String? transactionType,
    String? name,
    String? description,
    double? thresholdAmount,
    String? requiredRole,
    String? showroomId,
    bool? isActive,
    bool? autoApproveBelowThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApprovalRuleEntity(
      id: id ?? this.id,
      transactionType: transactionType ?? this.transactionType,
      name: name ?? this.name,
      description: description ?? this.description,
      thresholdAmount: thresholdAmount ?? this.thresholdAmount,
      requiredRole: requiredRole ?? this.requiredRole,
      showroomId: showroomId ?? this.showroomId,
      isActive: isActive ?? this.isActive,
      autoApproveBelowThreshold: autoApproveBelowThreshold ?? this.autoApproveBelowThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        transactionType,
        name,
        description,
        thresholdAmount,
        requiredRole,
        showroomId,
        isActive,
        autoApproveBelowThreshold,
        createdAt,
        updatedAt,
      ];
}
