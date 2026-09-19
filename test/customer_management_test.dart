import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mybike/core/services/customer_management_service.dart';
import 'package:mybike/features/customers/domain/entities/customer_entity.dart';
import 'package:mybike/features/customers/domain/entities/customer_document_entity.dart';
import 'package:mybike/features/customers/domain/entities/lead_entity.dart';
import 'package:mybike/features/customers/domain/entities/lead_activity_entity.dart';
import 'package:mybike/features/customers/domain/entities/booking_entity.dart';
import 'package:mybike/features/customers/presentation/cubit/customer_list_cubit.dart';
import 'package:mybike/features/customers/presentation/cubit/customer_detail_cubit.dart';
import 'package:mybike/features/customers/presentation/cubit/customer_form_cubit.dart';
import 'package:mybike/features/customers/presentation/cubit/lead_pipeline_cubit.dart';
import 'package:mybike/features/customers/presentation/cubit/booking_management_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CustomerManagementService.instance.resetDevData();
  });

  // ═══════════════════════════════════════════════════════════════════
  // 1. CustomerManagementService Tests
  // ═══════════════════════════════════════════════════════════════════
  group('CustomerManagementService', () {
    late CustomerManagementService service;

    setUp(() {
      service = CustomerManagementService.instance;
    });

    test('fetchCustomers returns seeded customers', () async {
      final customers = await service.fetchCustomers();
      expect(customers.length, greaterThanOrEqualTo(10));
      expect(customers.first.firstName.isNotEmpty, isTrue);
    });

    test('fetchCustomers filters by showroomId', () async {
      final mumbaiCustomers = await service.fetchCustomers(showroomId: 'showroom-mumbai-main');
      expect(mumbaiCustomers.every((c) => c.showroomId == 'showroom-mumbai-main'), isTrue);
    });

    test('fetchCustomers filters by kycStatus', () async {
      final verified = await service.fetchCustomers(kycStatus: 'verified');
      expect(verified.every((c) => c.kycStatus == 'verified'), isTrue);
    });

    test('fetchCustomers searches by name', () async {
      final results = await service.fetchCustomers(search: 'Rajesh');
      expect(results.any((c) => c.firstName == 'Rajesh'), isTrue);
    });

    test('fetchCustomerById returns matching customer', () async {
      final cust = await service.fetchCustomerById('cust-001');
      expect(cust, isNotNull);
      expect(cust!.id, equals('cust-001'));
      expect(cust.firstName, equals('Rajesh'));
    });

    test('createCustomer adds customer with generated sequence', () async {
      final newCustomer = CustomerEntity(
        id: '',
        showroomId: 'showroom-mumbai-main',
        customerNumber: '',
        firstName: 'Aarav',
        lastName: 'Patel',
        mobilePrimary: '9820011223',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final created = await service.createCustomer(newCustomer);
      expect(created.id, startsWith('cust-'));
      expect(created.customerNumber, startsWith('CUST-DEV-'));
      expect(created.firstName, equals('Aarav'));

      final fetched = await service.fetchCustomerById(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.mobilePrimary, equals('9820011223'));
    });

    test('updateCustomer updates existing customer attributes', () async {
      final cust = await service.fetchCustomerById('cust-001');
      expect(cust, isNotNull);

      final updated = await service.updateCustomer(
        'cust-001',
        cust!.copyWith(firstName: 'Rajesh Kumar'),
      );
      expect(updated.firstName, equals('Rajesh Kumar'));

      final fetched = await service.fetchCustomerById('cust-001');
      expect(fetched!.firstName, equals('Rajesh Kumar'));
    });

    test('updateKycStatus updates KYC verification details', () async {
      await service.updateKycStatus('cust-003', 'verified', verifiedBy: 'staff-001');
      final fetched = await service.fetchCustomerById('cust-003');
      expect(fetched!.kycStatus, equals('verified'));
      expect(fetched.kycVerifiedBy, equals('staff-001'));
      expect(fetched.kycVerifiedAt, isNotNull);
    });

    test('document operations: fetch, add, verify, reject', () async {
      final docs = await service.fetchCustomerDocuments('cust-001');
      expect(docs, isNotEmpty);

      final newDoc = await service.addCustomerDocument(
        CustomerDocumentEntity(
          id: '',
          customerId: 'cust-001',
          documentType: 'pan_card',
          documentNumber: 'ABCDE1234F',
          fileName: 'pan.pdf',
          fileSizeBytes: 2048,
          mimeType: 'application/pdf',
          createdAt: DateTime.now(),
        ),
      );
      expect(newDoc.id, startsWith('doc-'));

      await service.verifyDocument(newDoc.id, verifiedBy: 'staff-001');
      var updatedDocs = await service.fetchCustomerDocuments('cust-001');
      var verifiedDoc = updatedDocs.firstWhere((d) => d.id == newDoc.id);
      expect(verifiedDoc.verificationStatus, equals('verified'));
      expect(verifiedDoc.verifiedBy, equals('staff-001'));

      await service.rejectDocument(newDoc.id, 'Blurry document', verifiedBy: 'staff-001');
      updatedDocs = await service.fetchCustomerDocuments('cust-001');
      var rejectedDoc = updatedDocs.firstWhere((d) => d.id == newDoc.id);
      expect(rejectedDoc.verificationStatus, equals('rejected'));
      expect(rejectedDoc.rejectionReason, equals('Blurry document'));
    });

    test('lead operations: fetch, create, update, activities', () async {
      final leads = await service.fetchLeads();
      expect(leads, isNotEmpty);

      final created = await service.createLead(
        LeadEntity(
          id: '',
          showroomId: 'showroom-mumbai-main',
          leadNumber: '',
          prospectName: 'Vikram Mehta',
          prospectMobile: '9988776655',
          priority: 'hot',
          status: 'contacted',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      expect(created.id, startsWith('lead-'));
      expect(created.prospectName, equals('Vikram Mehta'));

      final activity = await service.addLeadActivity(
        LeadActivityEntity(
          id: '',
          leadId: created.id,
          activityType: 'test_ride',
          description: 'Customer took test ride of CB350',
          performedBy: 'staff-001',
          performedByName: 'Rahul Staff',
          createdAt: DateTime.now(),
        ),
      );
      expect(activity.id, startsWith('act-'));

      final activities = await service.fetchLeadActivities(created.id);
      expect(activities.length, equals(1));
      expect(activities.first.activityType, equals('test_ride'));
    });

    test('booking operations: fetch, create, update status, allocate vehicle', () async {
      final bookings = await service.fetchBookings();
      expect(bookings, isNotEmpty);

      final newBooking = await service.createBooking(
        BookingEntity(
          id: '',
          showroomId: 'showroom-mumbai-main',
          customerId: 'cust-001',
          bookingNumber: '',
          variantId: 'variant-cb350-dlx-pro',
          colorId: 'color-cb350-red',
          bookingAmount: 5000.0,
          status: 'booked',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      expect(newBooking.id, startsWith('booking-'));
      expect(newBooking.bookingNumber, startsWith('BK-DEV-'));

      final allocated = await service.allocateVehicleToBooking(newBooking.id, 'inv-cb350-001');
      expect(allocated.status, equals('allocated'));
      expect(allocated.allocatedVehicleId, equals('inv-cb350-001'));

      final cancelled = await service.cancelBooking(newBooking.id, 'Customer changed preference');
      expect(cancelled.status, equals('cancelled'));
      expect(cancelled.cancelledReason, equals('Customer changed preference'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // 2. CustomerListCubit Tests
  // ═══════════════════════════════════════════════════════════════════
  group('CustomerListCubit', () {
    late CustomerListCubit cubit;

    setUp(() {
      cubit = CustomerListCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has empty list and non-loading', () {
      expect(cubit.state.customers, isEmpty);
      expect(cubit.state.isLoading, isFalse);
    });

    test('loadCustomers loads customers and computes KPIs', () async {
      await cubit.loadCustomers();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.customers, isNotEmpty);
      expect(cubit.state.totalCustomers, greaterThanOrEqualTo(10));
      expect(cubit.state.kycVerified, greaterThan(0));
    });

    test('search filters customers by name or mobile', () async {
      await cubit.loadCustomers();
      cubit.search('Rajesh');

      expect(cubit.state.searchQuery, equals('Rajesh'));
      expect(cubit.state.filteredCustomers.every((c) =>
          c.fullName.toLowerCase().contains('rajesh') ||
          c.mobilePrimary.contains('rajesh') ||
          c.customerNumber.toLowerCase().contains('rajesh')), isTrue);
    });

    test('filter by KYC verification status using applyFilters', () async {
      await cubit.loadCustomers();
      cubit.applyFilters(kycStatus: 'verified');

      expect(cubit.state.selectedKycStatus, equals('verified'));
      expect(cubit.state.filteredCustomers.every((c) => c.kycStatus == 'verified'), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // 3. CustomerDetailCubit Tests
  // ═══════════════════════════════════════════════════════════════════
  group('CustomerDetailCubit', () {
    late CustomerDetailCubit cubit;

    setUp(() {
      cubit = CustomerDetailCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('loadCustomer loads customer profile and related documents/bookings', () async {
      await cubit.loadCustomer('cust-001');

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.customer, isNotNull);
      expect(cubit.state.customer!.id, equals('cust-001'));
      expect(cubit.state.documents, isNotEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // 4. CustomerFormCubit Tests
  // ═══════════════════════════════════════════════════════════════════
  group('CustomerFormCubit', () {
    late CustomerFormCubit cubit;

    setUp(() {
      cubit = CustomerFormCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('form field updates and state retention', () {
      cubit.updateFirstName('Rohit');
      cubit.updateLastName('Verma');
      cubit.updateMobilePrimary('9876543210');
      cubit.updateCustomerType('individual');
      cubit.updateShowroomId('showroom-mumbai-main');

      expect(cubit.state.firstName, equals('Rohit'));
      expect(cubit.state.lastName, equals('Verma'));
      expect(cubit.state.mobilePrimary, equals('9876543210'));
      expect(cubit.state.selectedShowroomId, equals('showroom-mumbai-main'));
    });

    test('saveCustomer creates a customer in dev mode', () async {
      cubit.updateFirstName('Ananya');
      cubit.updateLastName('Pandey');
      cubit.updateMobilePrimary('9876500001');
      cubit.updateShowroomId('showroom-mumbai-main');

      await cubit.saveCustomer();
      expect(cubit.state.isSaved, isTrue);
      expect(cubit.state.error, isNull);
    });

    test('loadForEdit populates form with existing customer data', () async {
      await cubit.loadForEdit('cust-001');

      expect(cubit.state.isEditMode, isTrue);
      expect(cubit.state.firstName, equals('Rajesh'));
      expect(cubit.state.lastName, equals('Sharma'));
      expect(cubit.state.mobilePrimary, equals('9876543210'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // 5. LeadPipelineCubit Tests
  // ═══════════════════════════════════════════════════════════════════
  group('LeadPipelineCubit', () {
    late LeadPipelineCubit cubit;

    setUp(() {
      cubit = LeadPipelineCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('loadLeads populates leads and pipeline KPIs', () async {
      await cubit.loadLeads();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.leads, isNotEmpty);
      expect(cubit.state.totalActiveLeads, greaterThan(0));
    });

    test('applyFilters by priority filters correctly', () async {
      await cubit.loadLeads();
      cubit.applyFilters(priority: 'hot');

      expect(cubit.state.selectedPriority, equals('hot'));
      expect(cubit.state.filteredLeads.every((l) => l.priority == 'hot'), isTrue);
    });

    test('applyFilters by status filters correctly', () async {
      await cubit.loadLeads();
      cubit.applyFilters(status: 'new');

      expect(cubit.state.selectedStatus, equals('new'));
      expect(cubit.state.filteredLeads.every((l) => l.status == 'new'), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // 6. BookingManagementCubit Tests
  // ═══════════════════════════════════════════════════════════════════
  group('BookingManagementCubit', () {
    late BookingManagementCubit cubit;

    setUp(() {
      cubit = BookingManagementCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('loadBookings populates bookings and financial KPIs', () async {
      await cubit.loadBookings();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.bookings, isNotEmpty);
      expect(cubit.state.totalBookingValue, greaterThan(0));
      expect(cubit.state.activeBookings, greaterThan(0));
    });

    test('applyFilters by status filters bookings correctly', () async {
      await cubit.loadBookings();
      cubit.applyFilters(status: 'booked');

      expect(cubit.state.selectedStatus, equals('booked'));
      expect(cubit.state.filteredBookings.every((b) => b.status == 'booked'), isTrue);
    });

    test('cancelBooking updates booking status to cancelled', () async {
      await cubit.loadBookings();
      final firstBooking = cubit.state.bookings.first;

      await cubit.cancelBooking(firstBooking.id, 'Customer changed preference');
      final updated = cubit.state.bookings.firstWhere((b) => b.id == firstBooking.id);
      expect(updated.status, equals('cancelled'));
    });
  });
}
