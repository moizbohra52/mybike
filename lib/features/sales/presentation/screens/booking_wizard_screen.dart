import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../common/layouts/app_scaffold.dart';
import '../cubit/booking_wizard_cubit.dart';
import '../cubit/booking_wizard_state.dart';

/// Interactive Booking & Sales Invoicing Wizard Screen
class BookingWizardScreen extends StatelessWidget {
  const BookingWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingWizardCubit(),
      child: const _BookingWizardView(),
    );
  }
}

class _BookingWizardView extends StatefulWidget {
  const _BookingWizardView();

  @override
  State<_BookingWizardView> createState() => _BookingWizardViewState();
}

class _BookingWizardViewState extends State<_BookingWizardView> {
  late final TextEditingController _customerNameController;
  late final TextEditingController _customerMobileController;

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController();
    _customerMobileController = TextEditingController();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerMobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return BlocConsumer<BookingWizardCubit, BookingWizardState>(
      listener: (context, state) {
        if (state.savedInvoice != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tax Invoice ${state.savedInvoice!.invoiceNumber} generated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/sales/${state.savedInvoice!.id}');
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return AppScaffold(
          activeNavigationId: 'sales',
          title: 'Sales & Booking Wizard',
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  children: [
                    // ─── Step Indicator Progress Bar ───
                    _buildStepper(context, state, isDark),
                    const SizedBox(height: 24),

                    // ─── Step Content Card ───
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: _buildCurrentStep(context, state, isDark),
                    ),
                    const SizedBox(height: 24),

                    // ─── Wizard Bottom Navigation Buttons ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (state.currentStep > 0)
                          OutlinedButton.icon(
                            onPressed: state.isSaving
                                ? null
                                : () => context.read<BookingWizardCubit>().previousStep(),
                            icon: const Icon(Icons.arrow_back_rounded, size: 18),
                            label: const Text('Back'),
                          )
                        else
                          const SizedBox.shrink(),
                        if (state.currentStep < 4)
                          FilledButton.icon(
                            onPressed: () {
                              final cubit = context.read<BookingWizardCubit>();
                              if (state.currentStep == 0) {
                                cubit.setCustomer(
                                  name: _customerNameController.text.trim(),
                                  mobile: _customerMobileController.text.trim(),
                                );
                              }
                              cubit.nextStep();
                            },
                            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                            label: const Text('Continue'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryYellow,
                              foregroundColor: AppColors.primaryBlack,
                            ),
                          )
                        else
                          FilledButton.icon(
                            onPressed: state.isSaving
                                ? null
                                : () => context.read<BookingWizardCubit>().generateInvoice(),
                            icon: state.isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.check_circle_rounded, size: 18),
                            label: const Text('Generate Tax Invoice'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepper(BuildContext context, BookingWizardState state, bool isDark) {
    const steps = ['Customer', 'Vehicle', 'Pricing', 'Payment', 'Review'];
    final accentColor = isDark ? AppColors.primaryYellow : AppColors.primaryYellowDark;

    return Row(
      children: List.generate(steps.length, (index) {
        final isDone = state.currentStep > index;
        final isCurrent = state.currentStep == index;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isDone
                          ? AppColors.success
                          : (isCurrent
                              ? AppColors.primaryYellow
                              : (isDark ? AppColors.darkBackground : AppColors.lightBackground)),
                      child: isDone
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              '${index + 1}',
                              style: AppTypography.captionLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? AppColors.primaryBlack
                                    : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[index],
                      style: AppTypography.captionSmall.copyWith(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent
                            ? accentColor
                            : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < steps.length - 1)
                Container(
                  width: 24,
                  height: 2,
                  color: isDone
                      ? AppColors.success
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep(BuildContext context, BookingWizardState state, bool isDark) {
    switch (state.currentStep) {
      case 0:
        return _buildStep0Customer(context, state, isDark);
      case 1:
        return _buildStep1Vehicle(context, state, isDark);
      case 2:
        return _buildStep2Pricing(context, state, isDark);
      case 3:
        return _buildStep3Payment(context, state, isDark);
      case 4:
        return _buildStep4Review(context, state, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Step 0: Customer Selection ───
  Widget _buildStep0Customer(BuildContext context, BookingWizardState state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Customer Details', style: AppTypography.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Select an existing customer or enter their details for invoicing.',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _customerNameController,
          decoration: const InputDecoration(
            labelText: 'Customer Full Name *',
            hintText: 'e.g. Ramesh Chandra',
            prefixIcon: Icon(Icons.person_outline_rounded),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _customerMobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: const InputDecoration(
            labelText: 'Mobile Number (10 Digits) *',
            hintText: 'e.g. 9820011223',
            prefixText: '+91 ',
            prefixIcon: Icon(Icons.phone_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        // Quick Presets from seed customers
        Text('Or select from recent customers:', style: AppTypography.captionSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ActionChip(
              label: const Text('Rajesh Sharma (Mumbai)'),
              onPressed: () {
                _customerNameController.text = 'Rajesh Sharma';
                _customerMobileController.text = '9876543210';
                context.read<BookingWizardCubit>().setCustomer(
                      id: 'cust-001',
                      name: 'Rajesh Sharma',
                      mobile: '9876543210',
                    );
              },
            ),
            ActionChip(
              label: const Text('Priya Deshmukh (Mumbai)'),
              onPressed: () {
                _customerNameController.text = 'Priya Deshmukh';
                _customerMobileController.text = '9876543211';
                context.read<BookingWizardCubit>().setCustomer(
                      id: 'cust-002',
                      name: 'Priya Deshmukh',
                      mobile: '9876543211',
                    );
              },
            ),
            ActionChip(
              label: const Text('Amit Kulkarni (Pune)'),
              onPressed: () {
                _customerNameController.text = 'Amit Kulkarni';
                _customerMobileController.text = '9822012345';
                context.read<BookingWizardCubit>().setCustomer(
                      id: 'cust-003',
                      name: 'Amit Kulkarni',
                      mobile: '9822012345',
                    );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ─── Step 1: Vehicle Selection ───
  Widget _buildStep1Vehicle(BuildContext context, BookingWizardState state, bool isDark) {
    final accentColor = isDark ? AppColors.primaryYellow : AppColors.primaryYellowDark;
    final bikes = [
      {
        'modelId': 'model-cb350',
        'modelName': 'Honda CB350 H\'ness',
        'variantId': 'variant-cb350-dlx-pro',
        'variantName': 'DLX Pro Dual Tone',
        'colorId': 'color-cb350-red',
        'colorName': 'Precious Red Metallic',
        'colorHex': 'B71C1C',
        'price': 217800.0,
        'isEv': false,
        'vin': 'ME4NC5800N8000101',
      },
      {
        'modelId': 'model-ather-450x',
        'modelName': 'Ather 450X Gen 3',
        'variantId': 'variant-ather-450x-pro',
        'variantName': '3.7 kWh Pro',
        'colorId': 'color-ather-white',
        'colorName': 'True White',
        'colorHex': 'FFFFFF',
        'price': 154999.0,
        'isEv': true,
        'vin': 'MALJA450XN0000103',
      },
      {
        'modelId': 'model-apache-rtr-310',
        'modelName': 'TVS Apache RTR 310',
        'variantId': 'variant-apache-rtr-310-bto',
        'variantName': 'BTO Dynamic Kit',
        'colorId': 'color-cb350-red',
        'colorName': 'Arsenal Black',
        'colorHex': '111111',
        'price': 272000.0,
        'isEv': false,
        'vin': 'ME4NC5800N8000102',
      },
      {
        'modelId': 'model-hunter-350',
        'modelName': 'Royal Enfield Hunter 350',
        'variantId': 'variant-hunter-350-metro',
        'variantName': 'Metro Dapper',
        'colorId': 'color-hunter-green',
        'colorName': 'Dapper Ash',
        'colorHex': '607D8B',
        'price': 169656.0,
        'isEv': false,
        'vin': 'ME4NC5800N8000105',
      },
      {
        'modelId': 'model-ather-rizta',
        'modelName': 'Ather Rizta Family Scooter',
        'variantId': 'variant-ather-rizta-z',
        'variantName': 'Rizta Z 3.7',
        'colorId': 'color-rizta-blue',
        'colorName': 'Pangong Blue',
        'colorHex': '1E88E5',
        'price': 144999.0,
        'isEv': true,
        'vin': 'MALJA450XN0000104',
      },
    ];

    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Select Vehicle & Color', style: AppTypography.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Choose the motorcycle or electric scooter variant for invoice generation.',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          ),
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bikes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final bike = bikes[index];
            final isSelected = state.selectedVariantId == bike['variantId'];

            return InkWell(
              onTap: () {
                context.read<BookingWizardCubit>().setVehicle(
                      modelId: bike['modelId'] as String,
                      modelName: bike['modelName'] as String,
                      variantId: bike['variantId'] as String,
                      variantName: bike['variantName'] as String,
                      colorId: bike['colorId'] as String,
                      colorName: bike['colorName'] as String,
                      colorHex: bike['colorHex'] as String,
                      exShowroomPrice: bike['price'] as double,
                      isEv: bike['isEv'] as bool,
                      vin: bike['vin'] as String,
                    );
              },
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                    color: isSelected ? accentColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? AppColors.primaryYellow.withValues(alpha: 0.1) : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      bike['isEv'] == true ? Icons.electric_scooter_rounded : Icons.two_wheeler_rounded,
                      size: 28,
                      color: isSelected ? accentColor : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bike['modelName'] as String, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                          Text('${bike['variantName']} • Color: ${bike['colorName']}', style: AppTypography.captionMedium),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currency.format(bike['price']),
                          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          bike['isEv'] == true ? '5% GST (EV)' : '28% GST (ICE)',
                          style: AppTypography.captionMedium.copyWith(
                            color: bike['isEv'] == true ? AppColors.success : AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─── Step 2: On-Road Pricing Customizer ───
  Widget _buildStep2Pricing(BuildContext context, BookingWizardState state, bool isDark) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0);
    final accentColor = isDark ? AppColors.primaryYellow : AppColors.primaryYellowDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: On-Road Price & Indian Tax Breakdown', style: AppTypography.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Fine-tune statutory charges, accessories, and promotional discounts.',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          title: const Text('Ex-Showroom Price (Vehicle Base)'),
          trailing: Text(currency.format(state.exShowroomPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListTile(
          title: Text(state.isEv ? 'CGST (2.5%) + SGST (2.5%) — EV' : 'CGST (14%) + SGST (14%) — Petrol'),
          trailing: Text(currency.format(state.totalGst), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListTile(
          title: const Text('RTO Road Tax & Registration'),
          subtitle: Text(state.isEv ? 'Subsidized EV Road Tax' : 'Standard 10-12% State Road Tax'),
          trailing: Text(currency.format(state.rtoCharges)),
        ),
        ListTile(
          title: const Text('Comprehensive Insurance (1+5 Yrs)'),
          trailing: Text(currency.format(state.insuranceCharges)),
        ),
        ListTile(
          title: const Text('Accessories Pack (Crash Guard, Grip, Cover)'),
          trailing: Text(currency.format(state.accessoriesTotal)),
        ),
        ListTile(
          title: const Text('Extended Warranty & 5-Yr Roadside Assistance'),
          trailing: Text(currency.format(state.extendedWarrantyAmount)),
        ),
        const Divider(),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text('Total On-Road Price (INR):', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Text(
                currency.format(state.totalOnRoadPrice),
                textAlign: TextAlign.right,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Step 3: Payment & Financing ───
  Widget _buildStep3Payment(BuildContext context, BookingWizardState state, bool isDark) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 4: Payment & Settlement', style: AppTypography.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Record token booking advances, bank loan financing, and customer down payments.',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          initialValue: state.bookingAdvanceAdjusted > 0 ? state.bookingAdvanceAdjusted.toStringAsFixed(0) : '5000',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Booking Token Advance Adjusted (INR)',
            prefixText: '₹ ',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) {
            final val = double.tryParse(v) ?? 0.0;
            context.read<BookingWizardCubit>().updatePayment(bookingAdvance: val);
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: state.financeAmount > 0 ? state.financeAmount.toStringAsFixed(0) : '150000',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Bank Loan / Finance Disbursed (INR)',
            prefixText: '₹ ',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) {
            final val = double.tryParse(v) ?? 0.0;
            context.read<BookingWizardCubit>().updatePayment(
                  financeAmount: val,
                  financeBank: 'HDFC Bank Auto Loan',
                );
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: state.downPaymentPaid > 0 ? state.downPaymentPaid.toStringAsFixed(0) : '0',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Customer Down Payment Today (INR)',
            prefixText: '₹ ',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) {
            final val = double.tryParse(v) ?? 0.0;
            context.read<BookingWizardCubit>().updatePayment(downPayment: val);
          },
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text('Total Received: ${currency.format(state.totalPaid)}')),
              const SizedBox(width: AppDimensions.spacing12),
              Text(
                'Balance Due: ${currency.format(state.balanceAmount)}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: state.isFullyPaid ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Step 4: Final Review ───
  Widget _buildStep4Review(BuildContext context, BookingWizardState state, bool isDark) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0);
    final accentColor = isDark ? AppColors.primaryYellow : AppColors.primaryYellowDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 5: Review & Confirm Invoice', style: AppTypography.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Verify customer particulars, GST rates, and vehicle allocation before issuing.',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            color: AppColors.primaryYellow.withValues(alpha: 0.06),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer:', style: AppTypography.bodySmall),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(
                    child: Text('${state.customerName} (+91 ${state.customerMobile})',
                        textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vehicle:', style: AppTypography.bodySmall),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(
                    child: Text('${state.selectedModelName} (${state.selectedVariantName})',
                        textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Color / VIN:', style: AppTypography.bodySmall),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(
                    child: Text('${state.selectedColorName} • ${state.selectedVin ?? "Assigned on Invoicing"}',
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GST Regime:', style: AppTypography.bodySmall),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(
                    child: Text(state.isEv ? '5.0% EV Subsidized GST' : '28.0% Standard Motor Vehicle GST',
                        textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text('Total On-Road Value:', style: AppTypography.headlineSmall),
                  ),
                  const SizedBox(width: AppDimensions.spacing12),
                  Text(
                    currency.format(state.totalOnRoadPrice),
                    textAlign: TextAlign.right,
                    style: AppTypography.headlineSmall.copyWith(color: accentColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
