import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import 'supabase_service.dart';
import '../../features/customers/domain/entities/customer_entity.dart';
import '../../features/customers/domain/entities/customer_document_entity.dart';
import '../../features/customers/domain/entities/lead_entity.dart';
import '../../features/customers/domain/entities/lead_activity_entity.dart';
import '../../features/customers/domain/entities/booking_entity.dart';
import '../../features/customers/data/models/customer_model.dart';
import '../../features/customers/data/models/customer_document_model.dart';
import '../../features/customers/data/models/lead_model.dart';
import '../../features/customers/data/models/lead_activity_model.dart';
import '../../features/customers/data/models/booking_model.dart';

/// Customer Management Service
///
/// Handles all customer CRM operations:
/// - Customer CRUD with KYC verification
/// - KYC document management
/// - Sales lead pipeline
/// - Lead activity timeline
/// - Vehicle bookings with token advance
///
/// Uses dev-mode seeded data (production would connect to Supabase).
class CustomerManagementService {
  CustomerManagementService._();
  static final CustomerManagementService instance = CustomerManagementService._();

  bool get _isSupabaseLive =>
      SupabaseConfig.isConfigured && SupabaseService.client != null;

  // ═══════════════════════════════════════════════════════════════════
  // DEV MODE SEED DATA — 12+ Realistic Indian Customers
  // ═══════════════════════════════════════════════════════════════════

  static final DateTime _now = DateTime.now();
  static final DateTime _monthAgo = _now.subtract(const Duration(days: 30));
  static final DateTime _weekAgo = _now.subtract(const Duration(days: 7));
  static final DateTime _twoWeeksAgo = _now.subtract(const Duration(days: 14));
  static final DateTime _twoMonthsAgo = _now.subtract(const Duration(days: 60));
  static final DateTime _threeMonthsAgo = _now.subtract(const Duration(days: 90));

  // Showroom IDs (matching inventory/showroom service)
  static const String _mumbaiId = 'showroom-mumbai-main';
  static const String _puneId = 'showroom-pune-west';
  static const String _bangaloreId = 'showroom-bangalore-metro';

  // Staff IDs
  static const String _staffRahul = 'staff-rahul-001';
  static const String _staffPriya = 'staff-priya-002';
  static const String _staffAmit = 'staff-amit-003';

  // Model/Variant/Color IDs (matching vehicle master service)
  static const String _cb350ModelId = 'model-cb350';
  static const String _cb350VariantId = 'variant-cb350-dlx-pro';
  static const String _cb350ColorRedId = 'color-cb350-red';
  static const String _ather450xModelId = 'model-ather-450x';
  static const String _ather450xVariantId = 'variant-ather-450x-pro';
  static const String _ather450xColorWhiteId = 'color-ather-white';
  static const String _apacheModelId = 'model-apache-rtr-310';
  static const String _apacheVariantId = 'variant-apache-rtr-310-bto';
  static const String _hunter350ModelId = 'model-hunter-350';
  static const String _hunter350VariantId = 'variant-hunter-350-metro';
  static const String _hunter350ColorGreenId = 'color-hunter-green';
  static const String _atherRiztaModelId = 'model-ather-rizta';
  static const String _atherRiztaVariantId = 'variant-ather-rizta-z';
  static const String _atherRiztaColorBlueId = 'color-rizta-blue';

  // Inventory vehicle IDs (from inventory service seed)
  static const String _invVehicle1 = 'inv-cb350-001';
  static const String _invVehicle2 = 'inv-ather-001';

  // ─── Seeded Customers ───
  static final List<CustomerEntity> _devCustomers = [
    // Mumbai Showroom Customers
    CustomerEntity(
      id: 'cust-001',
      showroomId: _mumbaiId,
      customerNumber: 'CUST-IND-MAIN-0001',
      firstName: 'Rajesh',
      lastName: 'Sharma',
      mobilePrimary: '9876543210',
      mobileSecondary: '9876543211',
      email: 'rajesh.sharma@gmail.com',
      dateOfBirth: DateTime(1988, 5, 15),
      gender: 'male',
      addressLine1: '403, Seaview Heights',
      addressLine2: 'Bandra West',
      city: 'Mumbai',
      state: 'Maharashtra',
      pinCode: '400050',
      landmark: 'Near Bandra Station',
      kycStatus: 'verified',
      kycVerifiedBy: _staffRahul,
      kycVerifiedAt: _monthAgo,
      customerType: 'individual',
      source: 'walk_in',
      preferredContactMethod: 'whatsapp',
      notes: 'Regular customer, interested in premium bikes. Has a Honda Activa for exchange.',
      createdAt: _threeMonthsAgo,
      updatedAt: _weekAgo,
    ),
    CustomerEntity(
      id: 'cust-002',
      showroomId: _mumbaiId,
      customerNumber: 'CUST-IND-MAIN-0002',
      firstName: 'Priya',
      lastName: 'Deshmukh',
      mobilePrimary: '9823456789',
      email: 'priya.deshmukh@outlook.com',
      dateOfBirth: DateTime(1995, 11, 22),
      gender: 'female',
      addressLine1: '12B, Lotus Park Society',
      city: 'Mumbai',
      state: 'Maharashtra',
      pinCode: '400076',
      kycStatus: 'verified',
      kycVerifiedBy: _staffPriya,
      kycVerifiedAt: _twoWeeksAgo,
      customerType: 'individual',
      source: 'social_media',
      preferredContactMethod: 'phone',
      notes: 'Found us on Instagram. Interested in electric vehicles.',
      createdAt: _twoMonthsAgo,
      updatedAt: _twoWeeksAgo,
    ),
    CustomerEntity(
      id: 'cust-003',
      showroomId: _mumbaiId,
      customerNumber: 'CUST-IND-MAIN-0003',
      firstName: 'Vikram',
      lastName: 'Patel',
      mobilePrimary: '9812345678',
      email: 'vikram.patel@corporatefleet.in',
      dateOfBirth: DateTime(1980, 3, 10),
      gender: 'male',
      addressLine1: 'Unit 5, Nariman Point Business Center',
      city: 'Mumbai',
      state: 'Maharashtra',
      pinCode: '400021',
      kycStatus: 'verified',
      kycVerifiedBy: _staffRahul,
      kycVerifiedAt: _twoMonthsAgo,
      customerType: 'corporate',
      source: 'corporate_tieup',
      preferredContactMethod: 'email',
      notes: 'Corporate fleet purchase for delivery executives. Bulk order potential.',
      createdAt: _threeMonthsAgo,
      updatedAt: _monthAgo,
    ),
    CustomerEntity(
      id: 'cust-004',
      showroomId: _mumbaiId,
      customerNumber: 'CUST-IND-MAIN-0004',
      firstName: 'Anita',
      lastName: 'Kulkarni',
      mobilePrimary: '9890123456',
      dateOfBirth: DateTime(1992, 8, 5),
      gender: 'female',
      addressLine1: '7, Dadar TT Circle',
      city: 'Mumbai',
      state: 'Maharashtra',
      pinCode: '400014',
      kycStatus: 'partial',
      customerType: 'individual',
      source: 'website',
      preferredContactMethod: 'whatsapp',
      notes: 'Submitted Aadhaar, PAN pending.',
      createdAt: _weekAgo,
      updatedAt: _weekAgo,
    ),
    // Pune Showroom Customers
    CustomerEntity(
      id: 'cust-005',
      showroomId: _puneId,
      customerNumber: 'CUST-IND-WEST-0001',
      firstName: 'Suresh',
      lastName: 'Joshi',
      mobilePrimary: '9765432109',
      email: 'suresh.joshi@yahoo.com',
      dateOfBirth: DateTime(1985, 12, 1),
      gender: 'male',
      addressLine1: '15, Koregaon Park Lane 7',
      city: 'Pune',
      state: 'Maharashtra',
      pinCode: '411001',
      landmark: 'Near German Bakery',
      kycStatus: 'verified',
      kycVerifiedBy: _staffAmit,
      kycVerifiedAt: _monthAgo,
      customerType: 'individual',
      source: 'walk_in',
      preferredContactMethod: 'phone',
      notes: 'Bike enthusiast, rides Royal Enfield currently.',
      createdAt: _twoMonthsAgo,
      updatedAt: _weekAgo,
    ),
    CustomerEntity(
      id: 'cust-006',
      showroomId: _puneId,
      customerNumber: 'CUST-IND-WEST-0002',
      firstName: 'Meera',
      lastName: 'Nair',
      mobilePrimary: '9654321098',
      email: 'meera.nair@techstartup.io',
      dateOfBirth: DateTime(1998, 7, 18),
      gender: 'female',
      addressLine1: '22, Hinjewadi Phase 2',
      city: 'Pune',
      state: 'Maharashtra',
      pinCode: '411057',
      kycStatus: 'pending',
      customerType: 'individual',
      source: 'social_media',
      preferredContactMethod: 'whatsapp',
      notes: 'First-time buyer, looking for commuter EV.',
      createdAt: _weekAgo,
      updatedAt: _weekAgo,
    ),
    CustomerEntity(
      id: 'cust-007',
      showroomId: _puneId,
      customerNumber: 'CUST-IND-WEST-0003',
      firstName: 'Arun',
      lastName: 'Mehta',
      mobilePrimary: '9543210987',
      email: 'arun.mehta@logistics.co.in',
      gender: 'male',
      addressLine1: 'Plot 8, MIDC Chakan',
      city: 'Pune',
      state: 'Maharashtra',
      pinCode: '410501',
      kycStatus: 'verified',
      kycVerifiedBy: _staffAmit,
      kycVerifiedAt: _monthAgo,
      customerType: 'fleet',
      source: 'corporate_tieup',
      preferredContactMethod: 'email',
      notes: 'Fleet order for last-mile delivery. 10+ units.',
      createdAt: _twoMonthsAgo,
      updatedAt: _twoWeeksAgo,
    ),
    // Bangalore Showroom Customers
    CustomerEntity(
      id: 'cust-008',
      showroomId: _bangaloreId,
      customerNumber: 'CUST-IND-SOUTH-0001',
      firstName: 'Karthik',
      lastName: 'Rajan',
      mobilePrimary: '9432109876',
      email: 'karthik.rajan@gmail.com',
      dateOfBirth: DateTime(1990, 2, 28),
      gender: 'male',
      addressLine1: '303, Whitefield Residency',
      city: 'Bangalore',
      state: 'Karnataka',
      pinCode: '560066',
      landmark: 'Near Phoenix Marketcity',
      kycStatus: 'verified',
      kycVerifiedBy: _staffPriya,
      kycVerifiedAt: _twoWeeksAgo,
      customerType: 'individual',
      source: 'oem_referral',
      preferredContactMethod: 'phone',
      notes: 'Referred by Ather showroom. Interested in Ather 450X.',
      createdAt: _monthAgo,
      updatedAt: _weekAgo,
    ),
    CustomerEntity(
      id: 'cust-009',
      showroomId: _bangaloreId,
      customerNumber: 'CUST-IND-SOUTH-0002',
      firstName: 'Deepika',
      lastName: 'Srinivasan',
      mobilePrimary: '9321098765',
      email: 'deepika.s@techcorp.com',
      dateOfBirth: DateTime(1993, 9, 14),
      gender: 'female',
      addressLine1: '18, Indiranagar 100 Feet Road',
      city: 'Bangalore',
      state: 'Karnataka',
      pinCode: '560038',
      kycStatus: 'partial',
      customerType: 'individual',
      source: 'auto_expo',
      preferredContactMethod: 'email',
      notes: 'Met at Bangalore Auto Expo 2026. Interested in Apache RTR 310.',
      createdAt: _twoWeeksAgo,
      updatedAt: _weekAgo,
    ),
    CustomerEntity(
      id: 'cust-010',
      showroomId: _bangaloreId,
      customerNumber: 'CUST-IND-SOUTH-0003',
      firstName: 'Mohammed',
      lastName: 'Irfan',
      mobilePrimary: '9210987654',
      dateOfBirth: DateTime(1987, 6, 25),
      gender: 'male',
      addressLine1: '45, Jayanagar 4th Block',
      city: 'Bangalore',
      state: 'Karnataka',
      pinCode: '560041',
      kycStatus: 'rejected',
      customerType: 'individual',
      source: 'exchange_inquiry',
      preferredContactMethod: 'phone',
      notes: 'KYC rejected — blurry Aadhaar scan. Asked to resubmit.',
      createdAt: _twoWeeksAgo,
      updatedAt: _weekAgo,
    ),
    CustomerEntity(
      id: 'cust-011',
      showroomId: _bangaloreId,
      customerNumber: 'CUST-IND-SOUTH-0004',
      firstName: 'Lakshmi',
      lastName: 'Narayana',
      mobilePrimary: '9109876543',
      email: 'lakshmi.n@gmail.com',
      dateOfBirth: DateTime(2000, 1, 5),
      gender: 'female',
      addressLine1: '12, Electronic City Phase 1',
      city: 'Bangalore',
      state: 'Karnataka',
      pinCode: '560100',
      kycStatus: 'pending',
      customerType: 'individual',
      source: 'phone_call',
      preferredContactMethod: 'whatsapp',
      notes: 'Called for Ather Rizta Z enquiry.',
      createdAt: _now.subtract(const Duration(days: 3)),
      updatedAt: _now.subtract(const Duration(days: 3)),
    ),
    CustomerEntity(
      id: 'cust-012',
      showroomId: _mumbaiId,
      customerNumber: 'CUST-IND-MAIN-0005',
      firstName: 'Sanjay',
      lastName: 'Gupta',
      mobilePrimary: '9098765432',
      email: 'sanjay.gupta@zomatodelivery.in',
      gender: 'male',
      addressLine1: 'B-204, Andheri East Industrial',
      city: 'Mumbai',
      state: 'Maharashtra',
      pinCode: '400069',
      kycStatus: 'verified',
      kycVerifiedBy: _staffRahul,
      kycVerifiedAt: _twoMonthsAgo,
      customerType: 'fleet',
      source: 'corporate_tieup',
      preferredContactMethod: 'email',
      notes: 'Zomato delivery fleet. Looking for 15 EV scooters.',
      createdAt: _threeMonthsAgo,
      updatedAt: _monthAgo,
    ),
  ];

  // ─── Seeded KYC Documents ───
  static final List<CustomerDocumentEntity> _devDocuments = [
    // Rajesh Sharma (fully verified)
    CustomerDocumentEntity(
      id: 'doc-001',
      customerId: 'cust-001',
      documentType: 'aadhaar',
      documentNumber: '4832XXXX9216',
      fileName: 'rajesh_aadhaar_front.pdf',
      fileSizeBytes: 245760,
      verificationStatus: 'verified',
      verifiedBy: _staffRahul,
      verifiedAt: _monthAgo,
      createdAt: _threeMonthsAgo,
    ),
    CustomerDocumentEntity(
      id: 'doc-002',
      customerId: 'cust-001',
      documentType: 'pan',
      documentNumber: 'BQXPS1234K',
      fileName: 'rajesh_pan_card.pdf',
      fileSizeBytes: 189440,
      verificationStatus: 'verified',
      verifiedBy: _staffRahul,
      verifiedAt: _monthAgo,
      createdAt: _threeMonthsAgo,
    ),
    CustomerDocumentEntity(
      id: 'doc-003',
      customerId: 'cust-001',
      documentType: 'driving_license',
      documentNumber: 'MH01XXXX5678',
      fileName: 'rajesh_dl_scan.pdf',
      fileSizeBytes: 312000,
      verificationStatus: 'verified',
      verifiedBy: _staffRahul,
      verifiedAt: _monthAgo,
      expiryDate: DateTime(2032, 5, 14),
      createdAt: _threeMonthsAgo,
    ),
    // Priya Deshmukh (verified)
    CustomerDocumentEntity(
      id: 'doc-004',
      customerId: 'cust-002',
      documentType: 'aadhaar',
      documentNumber: '7291XXXX8453',
      fileName: 'priya_aadhaar.pdf',
      fileSizeBytes: 198656,
      verificationStatus: 'verified',
      verifiedBy: _staffPriya,
      verifiedAt: _twoWeeksAgo,
      createdAt: _twoMonthsAgo,
    ),
    CustomerDocumentEntity(
      id: 'doc-005',
      customerId: 'cust-002',
      documentType: 'pan',
      documentNumber: 'AXDPD5678R',
      fileName: 'priya_pan.pdf',
      fileSizeBytes: 176128,
      verificationStatus: 'verified',
      verifiedBy: _staffPriya,
      verifiedAt: _twoWeeksAgo,
      createdAt: _twoMonthsAgo,
    ),
    // Anita Kulkarni (partial — Aadhaar submitted, PAN pending)
    CustomerDocumentEntity(
      id: 'doc-006',
      customerId: 'cust-004',
      documentType: 'aadhaar',
      documentNumber: '5123XXXX7890',
      fileName: 'anita_aadhaar.pdf',
      fileSizeBytes: 220160,
      verificationStatus: 'pending',
      createdAt: _weekAgo,
    ),
    // Karthik Rajan (verified)
    CustomerDocumentEntity(
      id: 'doc-007',
      customerId: 'cust-008',
      documentType: 'aadhaar',
      documentNumber: '8345XXXX2109',
      fileName: 'karthik_aadhaar.pdf',
      fileSizeBytes: 234496,
      verificationStatus: 'verified',
      verifiedBy: _staffPriya,
      verifiedAt: _twoWeeksAgo,
      createdAt: _monthAgo,
    ),
    CustomerDocumentEntity(
      id: 'doc-008',
      customerId: 'cust-008',
      documentType: 'driving_license',
      documentNumber: 'KA01XXXX9012',
      fileName: 'karthik_dl.pdf',
      fileSizeBytes: 287744,
      verificationStatus: 'verified',
      verifiedBy: _staffPriya,
      verifiedAt: _twoWeeksAgo,
      expiryDate: DateTime(2030, 2, 27),
      createdAt: _monthAgo,
    ),
    // Mohammed Irfan (rejected)
    CustomerDocumentEntity(
      id: 'doc-009',
      customerId: 'cust-010',
      documentType: 'aadhaar',
      documentNumber: '6789XXXX3456',
      fileName: 'irfan_aadhaar_blurry.jpg',
      fileSizeBytes: 524288,
      mimeType: 'image/jpeg',
      verificationStatus: 'rejected',
      verifiedBy: _staffPriya,
      verifiedAt: _weekAgo,
      rejectionReason: 'Document scan is blurry and unreadable. Please resubmit a clear scan.',
      createdAt: _twoWeeksAgo,
    ),
    // Suresh Joshi (verified)
    CustomerDocumentEntity(
      id: 'doc-010',
      customerId: 'cust-005',
      documentType: 'aadhaar',
      documentNumber: '3456XXXX7891',
      fileName: 'suresh_aadhaar.pdf',
      fileSizeBytes: 201728,
      verificationStatus: 'verified',
      verifiedBy: _staffAmit,
      verifiedAt: _monthAgo,
      createdAt: _twoMonthsAgo,
    ),
    CustomerDocumentEntity(
      id: 'doc-011',
      customerId: 'cust-005',
      documentType: 'pan',
      documentNumber: 'CMJPS9876L',
      fileName: 'suresh_pan.pdf',
      fileSizeBytes: 168960,
      verificationStatus: 'verified',
      verifiedBy: _staffAmit,
      verifiedAt: _monthAgo,
      createdAt: _twoMonthsAgo,
    ),
  ];

  // ─── Seeded Leads ───
  static final List<LeadEntity> _devLeads = [
    // Hot leads
    LeadEntity(
      id: 'lead-001',
      showroomId: _mumbaiId,
      customerId: 'cust-001',
      leadNumber: 'LEAD-IND-MAIN-0001',
      source: 'walk_in',
      status: 'converted',
      interestedModelId: _cb350ModelId,
      interestedVariantId: _cb350VariantId,
      assignedTo: _staffRahul,
      priority: 'hot',
      expectedClosureDate: _weekAgo,
      lastFollowUpAt: _weekAgo,
      notes: 'Converted to booking. CB350 DLX Pro in Radiant Red Metallic.',
      createdAt: _twoMonthsAgo,
      updatedAt: _weekAgo,
      customerName: 'Rajesh Sharma',
      assignedToName: 'Rahul Verma',
      interestedModelName: 'CB350 Highness',
      interestedVariantName: 'DLX Pro',
    ),
    LeadEntity(
      id: 'lead-002',
      showroomId: _mumbaiId,
      customerId: 'cust-002',
      leadNumber: 'LEAD-IND-MAIN-0002',
      source: 'social_media',
      status: 'test_ride_done',
      interestedModelId: _ather450xModelId,
      interestedVariantId: _ather450xVariantId,
      assignedTo: _staffPriya,
      priority: 'hot',
      expectedClosureDate: _now.add(const Duration(days: 7)),
      lastFollowUpAt: _now.subtract(const Duration(days: 2)),
      nextFollowUpAt: _now.add(const Duration(days: 1)),
      notes: 'Completed test ride. Very impressed with Ather 450X range. Discussing finance options.',
      createdAt: _monthAgo,
      updatedAt: _now.subtract(const Duration(days: 2)),
      customerName: 'Priya Deshmukh',
      assignedToName: 'Priya Singh',
      interestedModelName: 'Ather 450X',
      interestedVariantName: '3.7 Pro',
    ),
    LeadEntity(
      id: 'lead-003',
      showroomId: _puneId,
      customerId: 'cust-005',
      leadNumber: 'LEAD-IND-WEST-0001',
      source: 'walk_in',
      status: 'negotiation',
      interestedModelId: _hunter350ModelId,
      interestedVariantId: _hunter350VariantId,
      assignedTo: _staffAmit,
      priority: 'hot',
      expectedClosureDate: _now.add(const Duration(days: 5)),
      lastFollowUpAt: _now.subtract(const Duration(days: 1)),
      nextFollowUpAt: _now.add(const Duration(days: 2)),
      notes: 'Negotiating on accessories bundle. Wants a free helmet and riding jacket.',
      createdAt: _monthAgo,
      updatedAt: _now.subtract(const Duration(days: 1)),
      customerName: 'Suresh Joshi',
      assignedToName: 'Amit Desai',
      interestedModelName: 'Hunter 350',
      interestedVariantName: 'Metro',
    ),
    // Warm leads
    LeadEntity(
      id: 'lead-004',
      showroomId: _bangaloreId,
      customerId: 'cust-008',
      leadNumber: 'LEAD-IND-SOUTH-0001',
      source: 'oem_referral',
      status: 'booking_initiated',
      interestedModelId: _ather450xModelId,
      interestedVariantId: _ather450xVariantId,
      assignedTo: _staffPriya,
      priority: 'hot',
      expectedClosureDate: _now.add(const Duration(days: 3)),
      lastFollowUpAt: _now.subtract(const Duration(days: 1)),
      notes: 'Booking initiated. Awaiting token advance payment via UPI.',
      createdAt: _twoWeeksAgo,
      updatedAt: _now.subtract(const Duration(days: 1)),
      customerName: 'Karthik Rajan',
      assignedToName: 'Priya Singh',
      interestedModelName: 'Ather 450X',
      interestedVariantName: '3.7 Pro',
    ),
    LeadEntity(
      id: 'lead-005',
      showroomId: _bangaloreId,
      customerId: 'cust-009',
      leadNumber: 'LEAD-IND-SOUTH-0002',
      source: 'auto_expo',
      status: 'interested',
      interestedModelId: _apacheModelId,
      interestedVariantId: _apacheVariantId,
      assignedTo: _staffPriya,
      priority: 'warm',
      expectedClosureDate: _now.add(const Duration(days: 20)),
      lastFollowUpAt: _weekAgo,
      nextFollowUpAt: _now.add(const Duration(days: 3)),
      notes: 'Interested in Apache RTR 310 BTO. Needs to discuss with family.',
      createdAt: _twoWeeksAgo,
      updatedAt: _weekAgo,
      customerName: 'Deepika Srinivasan',
      assignedToName: 'Priya Singh',
      interestedModelName: 'Apache RTR 310',
      interestedVariantName: 'BTO',
    ),
    LeadEntity(
      id: 'lead-006',
      showroomId: _puneId,
      customerId: 'cust-006',
      leadNumber: 'LEAD-IND-WEST-0002',
      source: 'social_media',
      status: 'contacted',
      interestedModelId: _atherRiztaModelId,
      interestedVariantId: _atherRiztaVariantId,
      assignedTo: _staffAmit,
      priority: 'warm',
      expectedClosureDate: _now.add(const Duration(days: 30)),
      lastFollowUpAt: _now.subtract(const Duration(days: 3)),
      nextFollowUpAt: _now.add(const Duration(days: 4)),
      notes: 'First-time buyer. Contacted via Instagram DM. Wants to visit showroom for test ride.',
      createdAt: _weekAgo,
      updatedAt: _now.subtract(const Duration(days: 3)),
      customerName: 'Meera Nair',
      assignedToName: 'Amit Desai',
      interestedModelName: 'Ather Rizta',
      interestedVariantName: 'Z',
    ),
    // Cold lead
    LeadEntity(
      id: 'lead-007',
      showroomId: _bangaloreId,
      customerId: 'cust-011',
      leadNumber: 'LEAD-IND-SOUTH-0003',
      source: 'phone_call',
      status: 'new',
      interestedModelId: _atherRiztaModelId,
      interestedVariantId: _atherRiztaVariantId,
      assignedTo: _staffPriya,
      priority: 'cold',
      notes: 'Phone enquiry only. No showroom visit yet.',
      createdAt: _now.subtract(const Duration(days: 3)),
      updatedAt: _now.subtract(const Duration(days: 3)),
      customerName: 'Lakshmi Narayana',
      assignedToName: 'Priya Singh',
      interestedModelName: 'Ather Rizta',
      interestedVariantName: 'Z',
    ),
    // Lost lead
    LeadEntity(
      id: 'lead-008',
      showroomId: _mumbaiId,
      leadNumber: 'LEAD-IND-MAIN-0003',
      prospectName: 'Ravi Kumar',
      prospectMobile: '9898765432',
      source: 'website',
      status: 'lost',
      interestedModelId: _apacheModelId,
      priority: 'warm',
      lostReason: 'Customer found a better deal at competitor dealership.',
      createdAt: _twoMonthsAgo,
      updatedAt: _monthAgo,
      assignedToName: 'Rahul Verma',
      interestedModelName: 'Apache RTR 310',
    ),
  ];

  // ─── Seeded Lead Activities ───
  static final List<LeadActivityEntity> _devActivities = [
    // Rajesh Sharma lead activities (converted)
    LeadActivityEntity(
      id: 'act-001',
      leadId: 'lead-001',
      activityType: 'walk_in',
      description: 'Customer walked in and inquired about Honda CB350 DLX Pro. Showed interest in Radiant Red Metallic color.',
      performedBy: _staffRahul,
      createdAt: _twoMonthsAgo,
      performedByName: 'Rahul Verma',
    ),
    LeadActivityEntity(
      id: 'act-002',
      leadId: 'lead-001',
      activityType: 'test_ride',
      description: 'Completed test ride of CB350 DLX Pro. Customer very impressed with engine note and ride quality.',
      performedBy: _staffRahul,
      createdAt: _twoMonthsAgo.add(const Duration(days: 2)),
      performedByName: 'Rahul Verma',
    ),
    LeadActivityEntity(
      id: 'act-003',
      leadId: 'lead-001',
      activityType: 'negotiation',
      description: 'Discussed pricing. Customer wants accessories bundle (crash guard + saddle bag). Offered 5% discount on accessories.',
      performedBy: _staffRahul,
      createdAt: _monthAgo.add(const Duration(days: 5)),
      performedByName: 'Rahul Verma',
    ),
    LeadActivityEntity(
      id: 'act-004',
      leadId: 'lead-001',
      activityType: 'note',
      description: 'Lead converted to booking BK-IND-MAIN-2026-0001. Token advance of ₹5,000 received via UPI.',
      performedBy: _staffRahul,
      createdAt: _weekAgo,
      performedByName: 'Rahul Verma',
    ),
    // Priya Deshmukh lead activities
    LeadActivityEntity(
      id: 'act-005',
      leadId: 'lead-002',
      activityType: 'whatsapp',
      description: 'Customer reached out via Instagram DM. Redirected to WhatsApp for Ather 450X details and pricing.',
      performedBy: _staffPriya,
      createdAt: _monthAgo,
      performedByName: 'Priya Singh',
    ),
    LeadActivityEntity(
      id: 'act-006',
      leadId: 'lead-002',
      activityType: 'walk_in',
      description: 'Customer visited showroom. Shown Ather 450X Pro features, range demo, and charging infrastructure.',
      performedBy: _staffPriya,
      createdAt: _monthAgo.add(const Duration(days: 7)),
      performedByName: 'Priya Singh',
    ),
    LeadActivityEntity(
      id: 'act-007',
      leadId: 'lead-002',
      activityType: 'test_ride',
      description: 'Completed 20-minute test ride. Customer loved the acceleration and dashboard features. Discussing FAME II subsidy.',
      performedBy: _staffPriya,
      createdAt: _now.subtract(const Duration(days: 2)),
      performedByName: 'Priya Singh',
    ),
    // Suresh Joshi lead activity
    LeadActivityEntity(
      id: 'act-008',
      leadId: 'lead-003',
      activityType: 'call',
      description: 'Follow-up call. Customer comparing Hunter 350 with RE Classic 350. Highlighted MYBIKE exclusive accessories offer.',
      performedBy: _staffAmit,
      createdAt: _now.subtract(const Duration(days: 1)),
      performedByName: 'Amit Desai',
    ),
    // Karthik Rajan lead activity
    LeadActivityEntity(
      id: 'act-009',
      leadId: 'lead-004',
      activityType: 'follow_up',
      description: 'Customer confirmed booking. Waiting for UPI payment confirmation for ₹3,000 token advance.',
      performedBy: _staffPriya,
      createdAt: _now.subtract(const Duration(days: 1)),
      performedByName: 'Priya Singh',
    ),
  ];

  // ─── Seeded Bookings ───
  static final List<BookingEntity> _devBookings = [
    // Rajesh Sharma — Confirmed booking, vehicle allocated
    BookingEntity(
      id: 'booking-001',
      showroomId: _mumbaiId,
      customerId: 'cust-001',
      leadId: 'lead-001',
      bookingNumber: 'BK-IND-MAIN-2026-0001',
      variantId: _cb350VariantId,
      colorId: _cb350ColorRedId,
      allocatedVehicleId: _invVehicle1,
      status: 'allocated',
      bookingAmount: 5000.0,
      paymentMode: 'upi',
      paymentReference: 'UPI-RAJESH-20260815-001',
      exShowroomPrice: 223000.0,
      onRoadPrice: 258500.0,
      expectedDeliveryDate: _now.add(const Duration(days: 5)),
      financeRequired: false,
      exchangeVehicle: true,
      exchangeDetails: 'Honda Activa 6G (2022), KA-01-AB-1234, ~15000 km, estimated value ₹45,000',
      bookedBy: _staffRahul,
      notes: 'Vehicle allocated. PDI pending. Exchange vehicle evaluation done.',
      createdAt: _weekAgo,
      updatedAt: _now.subtract(const Duration(days: 2)),
      customerName: 'Rajesh Sharma',
      variantName: 'DLX Pro',
      colorName: 'Radiant Red Metallic',
      colorHex: 'DC143C',
      modelName: 'CB350 Highness',
      allocatedVin: 'ME4NC5800N8000101',
      bookedByName: 'Rahul Verma',
      showroomName: 'Mumbai Flagship',
    ),
    // Priya Deshmukh — Pending confirmation (finance pending)
    BookingEntity(
      id: 'booking-002',
      showroomId: _mumbaiId,
      customerId: 'cust-002',
      leadId: 'lead-002',
      bookingNumber: 'BK-IND-MAIN-2026-0002',
      variantId: _ather450xVariantId,
      colorId: _ather450xColorWhiteId,
      status: 'pending',
      bookingAmount: 3000.0,
      paymentMode: 'upi',
      paymentReference: 'UPI-PRIYA-20260910-001',
      exShowroomPrice: 155000.0,
      onRoadPrice: 142500.0, // After FAME II subsidy
      expectedDeliveryDate: _now.add(const Duration(days: 15)),
      financeRequired: true,
      financeProvider: 'HDFC Bank',
      loanAmount: 100000.0,
      bookedBy: _staffPriya,
      notes: 'FAME II subsidy applicable. Finance application submitted to HDFC Bank.',
      createdAt: _now.subtract(const Duration(days: 2)),
      updatedAt: _now.subtract(const Duration(days: 2)),
      customerName: 'Priya Deshmukh',
      variantName: '3.7 Pro',
      colorName: 'True White',
      colorHex: 'FFFFFF',
      modelName: 'Ather 450X',
      bookedByName: 'Priya Singh',
      showroomName: 'Mumbai Flagship',
    ),
    // Vikram Patel — Corporate fleet booking, delivered
    BookingEntity(
      id: 'booking-003',
      showroomId: _mumbaiId,
      customerId: 'cust-003',
      bookingNumber: 'BK-IND-MAIN-2026-0003',
      variantId: _ather450xVariantId,
      colorId: _ather450xColorWhiteId,
      allocatedVehicleId: _invVehicle2,
      status: 'delivered',
      bookingAmount: 10000.0,
      paymentMode: 'neft',
      paymentReference: 'NEFT-CORPFLEET-20260801-001',
      exShowroomPrice: 155000.0,
      onRoadPrice: 142500.0,
      expectedDeliveryDate: _twoWeeksAgo,
      actualDeliveryDate: _twoWeeksAgo,
      financeRequired: false,
      bookedBy: _staffRahul,
      notes: 'Corporate fleet delivery. Invoice raised. Payment received in full.',
      createdAt: _monthAgo,
      updatedAt: _twoWeeksAgo,
      customerName: 'Vikram Patel',
      variantName: '3.7 Pro',
      colorName: 'True White',
      colorHex: 'FFFFFF',
      modelName: 'Ather 450X',
      allocatedVin: 'MALJA450XN0000103',
      bookedByName: 'Rahul Verma',
      showroomName: 'Mumbai Flagship',
    ),
    // Suresh Joshi — Confirmed, pending allocation
    BookingEntity(
      id: 'booking-004',
      showroomId: _puneId,
      customerId: 'cust-005',
      leadId: 'lead-003',
      bookingNumber: 'BK-IND-WEST-2026-0001',
      variantId: _hunter350VariantId,
      colorId: _hunter350ColorGreenId,
      status: 'confirmed',
      bookingAmount: 5000.0,
      paymentMode: 'cash',
      exShowroomPrice: 165000.0,
      onRoadPrice: 192000.0,
      expectedDeliveryDate: _now.add(const Duration(days: 10)),
      financeRequired: true,
      financeProvider: 'Bajaj Finserv',
      loanAmount: 150000.0,
      bookedBy: _staffAmit,
      notes: 'Confirmed booking. Waiting for factory dispatch of Hunter 350 Metro in Dapper Green.',
      createdAt: _now.subtract(const Duration(days: 1)),
      updatedAt: _now.subtract(const Duration(days: 1)),
      customerName: 'Suresh Joshi',
      variantName: 'Metro',
      colorName: 'Dapper Green',
      colorHex: '2E8B57',
      modelName: 'Hunter 350',
      bookedByName: 'Amit Desai',
      showroomName: 'Pune West',
    ),
    // Arun Mehta — Fleet booking, cancelled
    BookingEntity(
      id: 'booking-005',
      showroomId: _puneId,
      customerId: 'cust-007',
      bookingNumber: 'BK-IND-WEST-2026-0002',
      variantId: _atherRiztaVariantId,
      colorId: _atherRiztaColorBlueId,
      status: 'cancelled',
      bookingAmount: 10000.0,
      paymentMode: 'neft',
      exShowroomPrice: 145000.0,
      onRoadPrice: 135000.0,
      financeRequired: false,
      cancelledReason: 'Fleet purchase budget reallocated to other vendor. Customer may return next quarter.',
      cancelledAt: _weekAgo,
      bookedBy: _staffAmit,
      createdAt: _twoWeeksAgo,
      updatedAt: _weekAgo,
      customerName: 'Arun Mehta',
      variantName: 'Z',
      colorName: 'Cyber Blue',
      colorHex: '1E90FF',
      modelName: 'Ather Rizta',
      bookedByName: 'Amit Desai',
      showroomName: 'Pune West',
    ),
    // Karthik Rajan — Pending booking
    BookingEntity(
      id: 'booking-006',
      showroomId: _bangaloreId,
      customerId: 'cust-008',
      leadId: 'lead-004',
      bookingNumber: 'BK-IND-SOUTH-2026-0001',
      variantId: _ather450xVariantId,
      colorId: _ather450xColorWhiteId,
      status: 'pending',
      bookingAmount: 3000.0,
      paymentMode: 'upi',
      exShowroomPrice: 155000.0,
      onRoadPrice: 142500.0,
      expectedDeliveryDate: _now.add(const Duration(days: 20)),
      financeRequired: true,
      financeProvider: 'State Bank of India',
      loanAmount: 120000.0,
      bookedBy: _staffPriya,
      notes: 'Pending booking confirmation. Waiting for SBI loan pre-approval.',
      createdAt: _now.subtract(const Duration(days: 1)),
      updatedAt: _now.subtract(const Duration(days: 1)),
      customerName: 'Karthik Rajan',
      variantName: '3.7 Pro',
      colorName: 'True White',
      colorHex: 'FFFFFF',
      modelName: 'Ather 450X',
      bookedByName: 'Priya Singh',
      showroomName: 'Bangalore Metro',
    ),
  ];

  // Mutable copies for dev mode operations
  late List<CustomerEntity> _customers = List.from(_devCustomers);
  late List<CustomerDocumentEntity> _documents = List.from(_devDocuments);
  late List<LeadEntity> _leads = List.from(_devLeads);
  late List<LeadActivityEntity> _activities = List.from(_devActivities);
  late List<BookingEntity> _bookings = List.from(_devBookings);
  int _customerSeq = 13;
  int _leadSeq = 9;
  int _bookingSeq = 7;

  /// Reset in-memory dev data to initial seeded state (used for testing)
  void resetDevData() {
    _customers = List.from(_devCustomers);
    _documents = List.from(_devDocuments);
    _leads = List.from(_devLeads);
    _activities = List.from(_devActivities);
    _bookings = List.from(_devBookings);
    _customerSeq = 13;
    _leadSeq = 9;
    _bookingSeq = 7;
  }

  // ═══════════════════════════════════════════════════════════════════
  // CUSTOMER OPERATIONS
  // ═══════════════════════════════════════════════════════════════════

  /// Fetch customers with optional filters
  Future<List<CustomerEntity>> fetchCustomers({
    String? showroomId,
    String? search,
    String? kycStatus,
    String? customerType,
  }) async {
    if (!_isSupabaseLive) {
      await SupabaseService.devLatency();
      return _fetchDevCustomers(
        showroomId: showroomId,
        search: search,
        kycStatus: kycStatus,
        customerType: customerType,
      );
    }
    try {
      var query = SupabaseService.client!.from('customers').select();
      if (showroomId != null) query = query.eq('showroom_id', showroomId);
      if (kycStatus != null) query = query.eq('kyc_status', kycStatus);
      if (customerType != null) query = query.eq('customer_type', customerType);
      final response = await query.order('created_at', ascending: false);
      final results = (response as List).map((e) => CustomerModel.fromJson(e as Map<String, dynamic>)).toList();
      if (search != null && search.isNotEmpty) {
        final s = search.toLowerCase();
        return results.where((c) =>
            c.fullName.toLowerCase().contains(s) ||
            c.mobilePrimary.contains(s) ||
            c.customerNumber.toLowerCase().contains(s)).toList();
      }
      return results;
    } catch (e) {
      debugPrint('CustomerManagementService.fetchCustomers error: $e');
      return _fetchDevCustomers(showroomId: showroomId, search: search, kycStatus: kycStatus, customerType: customerType);
    }
  }

  List<CustomerEntity> _fetchDevCustomers({
    String? showroomId,
    String? search,
    String? kycStatus,
    String? customerType,
  }) {
    var result = List<CustomerEntity>.from(_customers);
    if (showroomId != null) {
      result = result.where((c) => c.showroomId == showroomId).toList();
    }
    if (kycStatus != null) {
      result = result.where((c) => c.kycStatus == kycStatus).toList();
    }
    if (customerType != null) {
      result = result.where((c) => c.customerType == customerType).toList();
    }
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      result = result.where((c) =>
          c.fullName.toLowerCase().contains(s) ||
          c.mobilePrimary.contains(s) ||
          c.customerNumber.toLowerCase().contains(s)).toList();
    }
    return result;
  }

  /// Fetch a single customer by ID
  Future<CustomerEntity?> fetchCustomerById(String id) async {
    if (!_isSupabaseLive) {
      await SupabaseService.devLatency();
      return _customers.cast<CustomerEntity?>().firstWhere((c) => c!.id == id, orElse: () => null);
    }
    try {
      final response = await SupabaseService.client!.from('customers').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return CustomerModel.fromJson(response);
    } catch (e) {
      debugPrint('CustomerManagementService.fetchCustomerById error: $e');
      return _customers.cast<CustomerEntity?>().firstWhere((c) => c!.id == id, orElse: () => null);
    }
  }

  /// Create a new customer, returns the created entity
  Future<CustomerEntity> createCustomer(CustomerEntity customer) async {
    final newCustomer = customer.copyWith(
      id: 'cust-${_customerSeq.toString().padLeft(3, '0')}',
      customerNumber: 'CUST-DEV-${_customerSeq.toString().padLeft(4, '0')}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _customerSeq++;

    if (!_isSupabaseLive) {
      _customers.add(newCustomer);
      return newCustomer;
    }
    try {
      final response = await SupabaseService.client!
          .from('customers')
          .insert(CustomerModel.toInsertJson(newCustomer))
          .select()
          .single();
      return CustomerModel.fromJson(response);
    } catch (e) {
      debugPrint('CustomerManagementService.createCustomer error: $e');
      _customers.add(newCustomer);
      return newCustomer;
    }
  }

  /// Update an existing customer
  Future<CustomerEntity> updateCustomer(String id, CustomerEntity customer) async {
    final updated = customer.copyWith(updatedAt: DateTime.now());

    if (!_isSupabaseLive) {
      final idx = _customers.indexWhere((c) => c.id == id);
      if (idx >= 0) _customers[idx] = updated;
      return updated;
    }
    try {
      final response = await SupabaseService.client!
          .from('customers')
          .update(CustomerModel.toInsertJson(updated))
          .eq('id', id)
          .select()
          .single();
      return CustomerModel.fromJson(response);
    } catch (e) {
      debugPrint('CustomerManagementService.updateCustomer error: $e');
      final idx = _customers.indexWhere((c) => c.id == id);
      if (idx >= 0) _customers[idx] = updated;
      return updated;
    }
  }

  /// Update KYC status
  Future<void> updateKycStatus(String customerId, String status, {String? verifiedBy}) async {
    final idx = _customers.indexWhere((c) => c.id == customerId);
    if (idx >= 0) {
      _customers[idx] = _customers[idx].copyWith(
        kycStatus: status,
        kycVerifiedBy: verifiedBy,
        kycVerifiedAt: status == 'verified' ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // DOCUMENT OPERATIONS
  // ═══════════════════════════════════════════════════════════════════

  /// Fetch documents for a customer
  Future<List<CustomerDocumentEntity>> fetchCustomerDocuments(String customerId) async {
    if (!_isSupabaseLive) {
      await SupabaseService.devLatency();
      return _documents.where((d) => d.customerId == customerId).toList();
    }
    try {
      final response = await SupabaseService.client!
          .from('customer_documents')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      return (response as List)
          .map((e) => CustomerDocumentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('CustomerManagementService.fetchCustomerDocuments error: $e');
      return _documents.where((d) => d.customerId == customerId).toList();
    }
  }

  /// Add a new KYC document
  Future<CustomerDocumentEntity> addCustomerDocument(CustomerDocumentEntity doc) async {
    final newDoc = CustomerDocumentEntity(
      id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
      customerId: doc.customerId,
      documentType: doc.documentType,
      documentNumber: doc.documentNumber,
      fileName: doc.fileName,
      fileUrl: doc.fileUrl,
      fileSizeBytes: doc.fileSizeBytes,
      mimeType: doc.mimeType,
      createdAt: DateTime.now(),
    );
    _documents.add(newDoc);
    return newDoc;
  }

  /// Verify a KYC document
  Future<void> verifyDocument(String docId, {String? verifiedBy}) async {
    final idx = _documents.indexWhere((d) => d.id == docId);
    if (idx >= 0) {
      final old = _documents[idx];
      _documents[idx] = CustomerDocumentEntity(
        id: old.id,
        customerId: old.customerId,
        documentType: old.documentType,
        documentNumber: old.documentNumber,
        fileName: old.fileName,
        fileUrl: old.fileUrl,
        fileSizeBytes: old.fileSizeBytes,
        mimeType: old.mimeType,
        verificationStatus: 'verified',
        verifiedBy: verifiedBy,
        verifiedAt: DateTime.now(),
        expiryDate: old.expiryDate,
        createdAt: old.createdAt,
      );
    }
  }

  /// Reject a KYC document
  Future<void> rejectDocument(String docId, String reason, {String? verifiedBy}) async {
    final idx = _documents.indexWhere((d) => d.id == docId);
    if (idx >= 0) {
      final old = _documents[idx];
      _documents[idx] = CustomerDocumentEntity(
        id: old.id,
        customerId: old.customerId,
        documentType: old.documentType,
        documentNumber: old.documentNumber,
        fileName: old.fileName,
        fileUrl: old.fileUrl,
        fileSizeBytes: old.fileSizeBytes,
        mimeType: old.mimeType,
        verificationStatus: 'rejected',
        verifiedBy: verifiedBy,
        verifiedAt: DateTime.now(),
        rejectionReason: reason,
        expiryDate: old.expiryDate,
        createdAt: old.createdAt,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LEAD OPERATIONS
  // ═══════════════════════════════════════════════════════════════════

  /// Fetch leads with optional filters
  Future<List<LeadEntity>> fetchLeads({
    String? showroomId,
    String? status,
    String? priority,
    String? assignedTo,
    String? search,
  }) async {
    if (!_isSupabaseLive) {
      await SupabaseService.devLatency();
      return _fetchDevLeads(
        showroomId: showroomId,
        status: status,
        priority: priority,
        assignedTo: assignedTo,
        search: search,
      );
    }
    try {
      var query = SupabaseService.client!.from('leads').select();
      if (showroomId != null) query = query.eq('showroom_id', showroomId);
      if (status != null) query = query.eq('status', status);
      if (priority != null) query = query.eq('priority', priority);
      if (assignedTo != null) query = query.eq('assigned_to', assignedTo);
      final response = await query.order('created_at', ascending: false);
      return (response as List).map((e) => LeadModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('CustomerManagementService.fetchLeads error: $e');
      return _fetchDevLeads(showroomId: showroomId, status: status, priority: priority, assignedTo: assignedTo, search: search);
    }
  }

  List<LeadEntity> _fetchDevLeads({
    String? showroomId,
    String? status,
    String? priority,
    String? assignedTo,
    String? search,
  }) {
    var result = List<LeadEntity>.from(_leads);
    if (showroomId != null) result = result.where((l) => l.showroomId == showroomId).toList();
    if (status != null) result = result.where((l) => l.status == status).toList();
    if (priority != null) result = result.where((l) => l.priority == priority).toList();
    if (assignedTo != null) result = result.where((l) => l.assignedTo == assignedTo).toList();
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      result = result.where((l) =>
          l.displayName.toLowerCase().contains(s) ||
          l.leadNumber.toLowerCase().contains(s)).toList();
    }
    return result;
  }

  /// Fetch a single lead by ID
  Future<LeadEntity?> fetchLeadById(String id) async {
    if (!_isSupabaseLive) {
      await SupabaseService.devLatency();
      return _leads.cast<LeadEntity?>().firstWhere((l) => l!.id == id, orElse: () => null);
    }
    try {
      final response = await SupabaseService.client!.from('leads').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return LeadModel.fromJson(response);
    } catch (e) {
      debugPrint('CustomerManagementService.fetchLeadById error: $e');
      return _leads.cast<LeadEntity?>().firstWhere((l) => l!.id == id, orElse: () => null);
    }
  }

  /// Create a new lead
  Future<LeadEntity> createLead(LeadEntity lead) async {
    final newLead = lead.copyWith(
      id: 'lead-${_leadSeq.toString().padLeft(3, '0')}',
      leadNumber: 'LEAD-DEV-${_leadSeq.toString().padLeft(4, '0')}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _leadSeq++;
    _leads.add(newLead);
    return newLead;
  }

  /// Update lead status
  Future<LeadEntity> updateLead(String id, LeadEntity lead) async {
    final updated = lead.copyWith(updatedAt: DateTime.now());
    final idx = _leads.indexWhere((l) => l.id == id);
    if (idx >= 0) _leads[idx] = updated;
    return updated;
  }

  /// Fetch lead activities
  Future<List<LeadActivityEntity>> fetchLeadActivities(String leadId) async {
    if (!_isSupabaseLive) {
      await SupabaseService.devLatency();
      return _activities.where((a) => a.leadId == leadId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    try {
      final response = await SupabaseService.client!
          .from('lead_activities')
          .select()
          .eq('lead_id', leadId)
          .order('created_at', ascending: false);
      return (response as List)
          .map((e) => LeadActivityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('CustomerManagementService.fetchLeadActivities error: $e');
      return _activities.where((a) => a.leadId == leadId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  /// Add a lead activity
  Future<LeadActivityEntity> addLeadActivity(LeadActivityEntity activity) async {
    final newActivity = LeadActivityEntity(
      id: 'act-${DateTime.now().millisecondsSinceEpoch}',
      leadId: activity.leadId,
      activityType: activity.activityType,
      description: activity.description,
      performedBy: activity.performedBy,
      createdAt: DateTime.now(),
      performedByName: activity.performedByName,
    );
    _activities.add(newActivity);
    return newActivity;
  }

  /// Convert a lead to booking
  Future<BookingEntity> convertLeadToBooking(String leadId, BookingEntity booking) async {
    // Update lead status
    final leadIdx = _leads.indexWhere((l) => l.id == leadId);
    if (leadIdx >= 0) {
      _leads[leadIdx] = _leads[leadIdx].copyWith(status: 'converted', updatedAt: DateTime.now());
    }
    // Create booking
    return createBooking(booking.copyWith(leadId: leadId));
  }

  // ═══════════════════════════════════════════════════════════════════
  // BOOKING OPERATIONS
  // ═══════════════════════════════════════════════════════════════════

  /// Fetch bookings with optional filters
  Future<List<BookingEntity>> fetchBookings({
    String? showroomId,
    String? status,
    String? customerId,
    String? search,
  }) async {
    if (!_isSupabaseLive) {
      await SupabaseService.devLatency();
      return _fetchDevBookings(
        showroomId: showroomId,
        status: status,
        customerId: customerId,
        search: search,
      );
    }
    try {
      var query = SupabaseService.client!.from('bookings').select();
      if (showroomId != null) query = query.eq('showroom_id', showroomId);
      if (status != null) query = query.eq('status', status);
      if (customerId != null) query = query.eq('customer_id', customerId);
      final response = await query.order('created_at', ascending: false);
      return (response as List).map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('CustomerManagementService.fetchBookings error: $e');
      return _fetchDevBookings(showroomId: showroomId, status: status, customerId: customerId, search: search);
    }
  }

  List<BookingEntity> _fetchDevBookings({
    String? showroomId,
    String? status,
    String? customerId,
    String? search,
  }) {
    var result = List<BookingEntity>.from(_bookings);
    if (showroomId != null) result = result.where((b) => b.showroomId == showroomId).toList();
    if (status != null) result = result.where((b) => b.status == status).toList();
    if (customerId != null) result = result.where((b) => b.customerId == customerId).toList();
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      result = result.where((b) =>
          b.bookingNumber.toLowerCase().contains(s) ||
          (b.customerName?.toLowerCase().contains(s) ?? false)).toList();
    }
    return result;
  }

  /// Fetch a single booking by ID
  Future<BookingEntity?> fetchBookingById(String id) async {
    if (!_isSupabaseLive) {
      await SupabaseService.devLatency();
      return _bookings.cast<BookingEntity?>().firstWhere((b) => b!.id == id, orElse: () => null);
    }
    try {
      final response = await SupabaseService.client!.from('bookings').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return BookingModel.fromJson(response);
    } catch (e) {
      debugPrint('CustomerManagementService.fetchBookingById error: $e');
      return _bookings.cast<BookingEntity?>().firstWhere((b) => b!.id == id, orElse: () => null);
    }
  }

  /// Create a new booking
  Future<BookingEntity> createBooking(BookingEntity booking) async {
    final newBooking = booking.copyWith(
      id: 'booking-${_bookingSeq.toString().padLeft(3, '0')}',
      bookingNumber: 'BK-DEV-${_bookingSeq.toString().padLeft(4, '0')}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _bookingSeq++;
    _bookings.add(newBooking);
    return newBooking;
  }

  /// Update booking status
  Future<BookingEntity> updateBookingStatus(String id, String status) async {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx >= 0) {
      _bookings[idx] = _bookings[idx].copyWith(
        status: status,
        updatedAt: DateTime.now(),
        cancelledAt: status == 'cancelled' ? DateTime.now() : null,
        actualDeliveryDate: status == 'delivered' ? DateTime.now() : null,
      );
      return _bookings[idx];
    }
    throw Exception('Booking not found: $id');
  }

  /// Allocate a vehicle (VIN) to a booking
  Future<BookingEntity> allocateVehicleToBooking(String bookingId, String vehicleId) async {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx >= 0) {
      _bookings[idx] = _bookings[idx].copyWith(
        allocatedVehicleId: vehicleId,
        status: 'allocated',
        updatedAt: DateTime.now(),
      );
      return _bookings[idx];
    }
    throw Exception('Booking not found: $bookingId');
  }

  /// Cancel a booking with reason
  Future<BookingEntity> cancelBooking(String bookingId, String reason) async {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx >= 0) {
      _bookings[idx] = _bookings[idx].copyWith(
        status: 'cancelled',
        cancelledReason: reason,
        cancelledAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return _bookings[idx];
    }
    throw Exception('Booking not found: $bookingId');
  }
}
