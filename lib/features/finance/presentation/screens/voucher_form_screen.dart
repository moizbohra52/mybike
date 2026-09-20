import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../common/common.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routes/route_names.dart';
import '../cubit/voucher_form_cubit.dart';
import '../cubit/voucher_form_state.dart';

/// Financial Voucher Creation Screen
class VoucherFormScreen extends StatelessWidget {
  final String? initialType;

  const VoucherFormScreen({super.key, this.initialType});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VoucherFormCubit()
        ..init(voucherType: initialType ?? 'payment'),
      child: const _VoucherFormView(),
    );
  }
}

class _VoucherFormView extends StatefulWidget {
  const _VoucherFormView();

  @override
  State<_VoucherFormView> createState() => _VoucherFormViewState();
}

class _VoucherFormViewState extends State<_VoucherFormView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _tdsCtrl = TextEditingController(text: '0');
  final TextEditingController _partyNameCtrl = TextEditingController();
  final TextEditingController _partyPhoneCtrl = TextEditingController();
  final TextEditingController _refCtrl = TextEditingController();
  final TextEditingController _bankNameCtrl = TextEditingController();
  final TextEditingController _narrationCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _tdsCtrl.dispose();
    _partyNameCtrl.dispose();
    _partyPhoneCtrl.dispose();
    _refCtrl.dispose();
    _bankNameCtrl.dispose();
    _narrationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isDark = context.isDarkMode;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM yyyy');

    return BlocConsumer<VoucherFormCubit, VoucherFormState>(
      listener: (context, state) {
        if (state.savedVoucher != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✓ Successfully created & posted voucher ${state.savedVoucher!.voucherNumber} to General Ledger!',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.goNamed(RouteNames.vouchers);
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.availableAccounts.isEmpty) {
          return const AppScaffold(
            title: 'New Financial Voucher',
            body: Center(child: AppLoading(message: 'Initializing Chart of Accounts...')),
          );
        }

        return AppScaffold(
          title: 'Record Financial Voucher',
          activeNavigationId: 'finance',
          actions: [
            TextButton(
              onPressed: () => context.goNamed(RouteNames.vouchers),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
          ],
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? AppDimensions.spacing24 : AppDimensions.spacing16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Voucher Type Selector
                      _buildSectionCard(
                        title: 'Select Voucher Type',
                        isDark: isDark,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildTypeOption(context, 'payment', 'Payment Voucher', Icons.upload_rounded, state.voucherType),
                            _buildTypeOption(context, 'receipt', 'Receipt Voucher', Icons.download_rounded, state.voucherType),
                            _buildTypeOption(context, 'contra', 'Contra Transfer', Icons.swap_horiz_rounded, state.voucherType),
                            _buildTypeOption(context, 'expense', 'Petty Cash Expense', Icons.payments_outlined, state.voucherType),
                            _buildTypeOption(context, 'credit_note', 'Credit Note', Icons.assignment_return_rounded, state.voucherType),
                            _buildTypeOption(context, 'debit_note', 'Debit Note', Icons.note_alt_rounded, state.voucherType),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Basic Details Card
                      _buildSectionCard(
                        title: 'Transaction Details',
                        isDark: isDark,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Date Picker
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: state.voucherDate,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now().add(const Duration(days: 30)),
                                      );
                                      if (picked != null && context.mounted) {
                                        context.read<VoucherFormCubit>().updateField(voucherDate: picked);
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Voucher Date *',
                                        prefixIcon: Icon(Icons.calendar_today_rounded),
                                        border: OutlineInputBorder(),
                                      ),
                                      child: Text(dateFormat.format(state.voucherDate)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Payment Mode
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: state.paymentMode,
                                    decoration: const InputDecoration(
                                      labelText: 'Payment Mode *',
                                      prefixIcon: Icon(Icons.payment_rounded),
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer (NEFT/RTGS)')),
                                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                                      DropdownMenuItem(value: 'upi', child: Text('UPI / QR Code')),
                                      DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                                      DropdownMenuItem(value: 'clearing', child: Text('Book Adjustment / Clearing')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        context.read<VoucherFormCubit>().updateField(paymentMode: val);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Party Type & Party Name
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<String>(
                                    initialValue: state.partyType,
                                    decoration: const InputDecoration(
                                      labelText: 'Party Category *',
                                      prefixIcon: Icon(Icons.group_outlined),
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'supplier', child: Text('Supplier / OEM')),
                                      DropdownMenuItem(value: 'customer', child: Text('Customer')),
                                      DropdownMenuItem(value: 'staff', child: Text('Staff / Employee')),
                                      DropdownMenuItem(value: 'bank', child: Text('Bank')),
                                      DropdownMenuItem(value: 'other', child: Text('Other / Sundry')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        context.read<VoucherFormCubit>().updateField(partyType: val);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _partyNameCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Party Name *',
                                      hintText: 'e.g. Honda Motorcycle Ltd / Ankit Verma',
                                      prefixIcon: Icon(Icons.person_outline_rounded),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val) => context.read<VoucherFormCubit>().updateField(partyName: val),
                                    validator: (val) => val == null || val.trim().isEmpty ? 'Party name is required' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Amounts Row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _amountCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Gross Amount (₹) *',
                                      hintText: '0.00',
                                      prefixIcon: Icon(Icons.currency_rupee_rounded),
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (val) {
                                      final amt = double.tryParse(val) ?? 0.0;
                                      context.read<VoucherFormCubit>().updateField(amount: amt);
                                    },
                                    validator: (val) {
                                      final amt = double.tryParse(val ?? '') ?? 0.0;
                                      if (amt <= 0) return 'Enter a valid positive amount';
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _tdsCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'TDS Deducted (₹)',
                                      hintText: '0.00',
                                      prefixIcon: Icon(Icons.percent_rounded),
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (val) {
                                      final tds = double.tryParse(val) ?? 0.0;
                                      context.read<VoucherFormCubit>().updateField(tdsDeducted: tds);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Net Settlement Amount', style: AppTypography.bodySmall.copyWith(color: AppColors.success)),
                                        const SizedBox(height: 4),
                                        Text(
                                          currencyFormat.format(state.netAmount),
                                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.success),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // General Ledger Account Mapping Card
                      _buildSectionCard(
                        title: 'General Ledger Accounts Integration',
                        isDark: isDark,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Source Account Dropdown
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: state.sourceAccountId,
                                    decoration: InputDecoration(
                                      labelText: state.voucherType == 'payment'
                                          ? 'Source Account (Cash / Bank) [Credit] *'
                                          : 'Source Account [Credit] *',
                                      prefixIcon: const Icon(Icons.account_balance_outlined),
                                      border: const OutlineInputBorder(),
                                    ),
                                    items: state.availableAccounts.map((acct) {
                                      return DropdownMenuItem(
                                        value: acct.id,
                                        child: Text(
                                          '${acct.accountCode} - ${acct.accountName}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        context.read<VoucherFormCubit>().updateField(sourceAccountId: val);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Destination Account Dropdown
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: state.destinationAccountId,
                                    decoration: InputDecoration(
                                      labelText: state.voucherType == 'payment'
                                          ? 'Beneficiary / Expense Account [Debit] *'
                                          : 'Destination Account [Debit] *',
                                      prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                                      border: const OutlineInputBorder(),
                                    ),
                                    items: state.availableAccounts.map((acct) {
                                      return DropdownMenuItem(
                                        value: acct.id,
                                        child: Text(
                                          '${acct.accountCode} - ${acct.accountName}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        context.read<VoucherFormCubit>().updateField(destinationAccountId: val);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.primaryYellow),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Submitting will automatically post a balanced Journal Entry into the General Ledger, updating real-time account balances.',
                                      style: AppTypography.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // References & Narration Card
                      _buildSectionCard(
                        title: 'Reference & Narration',
                        isDark: isDark,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _refCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Reference Number / UTR / Cheque',
                                      hintText: 'e.g. UTR-9823471029 or CHQ-000123',
                                      prefixIcon: Icon(Icons.tag_rounded),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val) => context.read<VoucherFormCubit>().updateField(referenceNumber: val),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _bankNameCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Bank Name / Branch',
                                      hintText: 'e.g. HDFC Bank, Fort Branch',
                                      prefixIcon: Icon(Icons.business_rounded),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val) => context.read<VoucherFormCubit>().updateField(bankName: val),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _narrationCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Narration / Description *',
                                hintText: 'Detailed description of this financial transaction for the audit trail...',
                                prefixIcon: Icon(Icons.notes_rounded),
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                              onChanged: (val) => context.read<VoucherFormCubit>().updateField(narration: val),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Narration is required' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton(
                            label: 'Cancel',
                            variant: AppButtonVariant.secondary,
                            onPressed: () => context.goNamed(RouteNames.vouchers),
                          ),
                          const SizedBox(width: 16),
                          AppButton(
                            label: 'Post Voucher to Ledger',
                            leadingIcon: Icons.check_circle_rounded,
                            variant: AppButtonVariant.primary,
                            isLoading: state.isSubmitting,
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context.read<VoucherFormCubit>().submitVoucher(autoPostToGL: true);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({required String title, required Widget child, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context,
    String type,
    String label,
    IconData icon,
    String currentType,
  ) {
    final isSelected = currentType == type;
    return InkWell(
      onTap: () => context.read<VoucherFormCubit>().init(voucherType: type),
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryYellow.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(
            color: isSelected ? AppColors.primaryYellow : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.primaryBlack : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primaryBlack : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
