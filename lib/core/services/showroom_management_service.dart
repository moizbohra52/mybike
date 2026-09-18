import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import 'supabase_service.dart';
import '../../features/showroom/domain/entities/showroom_entity.dart';
import '../../features/showroom/data/models/showroom_model.dart';
import '../../features/showroom/domain/entities/invoice_sequence_entity.dart';
import '../../features/showroom/data/models/invoice_sequence_model.dart';
import 'user_management_service.dart';

/// Showroom domain model enriched with calculated staff and sequence counts
class ShowroomWithStats {
  final ShowroomEntity showroom;
  final int staffCount;
  final int activeSequencesCount;

  const ShowroomWithStats({
    required this.showroom,
    this.staffCount = 0,
    this.activeSequencesCount = 0,
  });
}

/// Comprehensive Showroom and Sequence Management Service
class ShowroomManagementService {
  ShowroomManagementService._();
  static final ShowroomManagementService instance = ShowroomManagementService._();

  // ─── Indian States & Union Territories List ───
  static const List<String> indianStatesAndUTs = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  // ─── In-Memory Dev State ───
  List<ShowroomModel>? _devShowrooms;
  List<InvoiceSequenceModel>? _devSequences;

  void _initDevData() {
    if (_devShowrooms != null) return;

    final now = DateTime.now();

    _devShowrooms = [
      ShowroomModel(
        id: 'sh-001',
        name: 'MYBIKE Flagship Central',
        code: 'IND-MAIN',
        address: 'Plot 42, Bandra Kurla Complex, Bandra East',
        city: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400051',
        phone: '+91 22 2650 1000',
        email: 'mumbai.central@mybike.com',
        gstin: '27AABCU9603R1ZM',
        pan: 'AABCU9603R',
        bankName: 'HDFC Bank',
        bankAccountNumber: '50200012345678',
        bankIfsc: 'HDFC0000042',
        bankBranch: 'BKC Branch, Mumbai',
        invoicePrefix: 'MB-MUM',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now,
      ),
      ShowroomModel(
        id: 'sh-002',
        name: 'MYBIKE West Hub',
        code: 'IND-WEST',
        address: 'Survey 108/2, Baner Road, Near Balewadi High Street',
        city: 'Pune',
        state: 'Maharashtra',
        pincode: '411045',
        phone: '+91 20 6700 2000',
        email: 'pune.west@mybike.com',
        gstin: '27AABCU9603R2ZN',
        pan: 'AABCU9603R',
        bankName: 'ICICI Bank',
        bankAccountNumber: '004505001122',
        bankIfsc: 'ICIC0000045',
        bankBranch: 'Baner Road, Pune',
        invoicePrefix: 'MB-PUN',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 240)),
        updatedAt: now,
      ),
      ShowroomModel(
        id: 'sh-003',
        name: 'MYBIKE Metro Branch',
        code: 'IND-SOUTH',
        address: '84/1, 100 Feet Road, HAL 2nd Stage, Indiranagar',
        city: 'Bangalore',
        state: 'Karnataka',
        pincode: '560038',
        phone: '+91 80 4120 3000',
        email: 'bangalore.metro@mybike.com',
        gstin: '29AABCU9603R1ZK',
        pan: 'AABCU9603R',
        bankName: 'Axis Bank',
        bankAccountNumber: '918020033445566',
        bankIfsc: 'UTIB0000123',
        bankBranch: 'Indiranagar, Bangalore',
        invoicePrefix: 'MB-BLR',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now,
      ),
    ];

    _devSequences = [];
    for (final showroom in _devShowrooms!) {
      _generateDefaultSequencesForShowroom(showroom.id, showroom.invoicePrefix);
    }
  }

  void _generateDefaultSequencesForShowroom(String showroomId, String showroomPrefix) {
    final now = DateTime.now();
    for (final docType in DealershipDocType.values) {
      final prefix = '$showroomPrefix-${docType.defaultPrefix}-';
      _devSequences!.add(
        InvoiceSequenceModel(
          id: 'seq-$showroomId-${docType.key}',
          showroomId: showroomId,
          docType: docType.key,
          prefix: prefix,
          currentNumber: docType == DealershipDocType.saleInvoice ? 184 : 42,
          paddingZeros: 5,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  /// Reset in-memory dev data (used for testing)
  void resetDevData() {
    _devShowrooms = null;
    _devSequences = null;
    _initDevData();
  }

  // ─── Showroom Queries ───

  /// Fetch all showrooms with search, filters, and computed staff metrics
  Future<List<ShowroomWithStats>> fetchShowrooms({
    String? search,
    bool? isActive,
    String? city,
    String? state,
  }) async {
    // ─── Live Supabase ───
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;
        var query = client.from('showrooms').select('*, user_showrooms(count), invoice_sequences(count)');

        if (search != null && search.isNotEmpty) {
          query = query.or('name.ilike.%$search%,code.ilike.%$search%,city.ilike.%$search%');
        }
        if (isActive != null) {
          query = query.eq('is_active', isActive);
        }
        if (city != null && city.isNotEmpty) {
          query = query.eq('city', city);
        }
        if (state != null && state.isNotEmpty) {
          query = query.eq('state', state);
        }

        final data = await query.order('created_at', ascending: true);
        return (data as List).map((row) {
          final sModel = ShowroomModel.fromJson(row);
          final staffCnt = (row['user_showrooms'] as List?)?.length ?? 0;
          final seqCnt = (row['invoice_sequences'] as List?)?.length ?? 0;
          return ShowroomWithStats(
            showroom: sModel,
            staffCount: staffCnt,
            activeSequencesCount: seqCnt,
          );
        }).toList();
      } catch (e) {
        debugPrint('Supabase fetchShowrooms error: $e, falling back to dev mode');
      }
    }

    // ─── In-Memory Dev Mode ───
    _initDevData();
    var list = List<ShowroomModel>.from(_devShowrooms!);

    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.code.toLowerCase().contains(q) ||
            s.city.toLowerCase().contains(q) ||
            s.state.toLowerCase().contains(q);
      }).toList();
    }

    if (isActive != null) {
      list = list.where((s) => s.isActive == isActive).toList();
    }

    if (city != null && city.isNotEmpty) {
      list = list.where((s) => s.city.toLowerCase() == city.toLowerCase()).toList();
    }

    if (state != null && state.isNotEmpty) {
      list = list.where((s) => s.state.toLowerCase() == state.toLowerCase()).toList();
    }

    // Calculate staff count per showroom from dev users
    final allUsers = await UserManagementService.instance.fetchUsers();

    return list.map((showroom) {
      final staffCount = allUsers.users.where((u) {
        return u.showrooms.any((s) => s.id == showroom.id);
      }).length;

      final seqCount = _devSequences!.where((seq) => seq.showroomId == showroom.id).length;

      return ShowroomWithStats(
        showroom: showroom,
        staffCount: staffCount,
        activeSequencesCount: seqCount,
      );
    }).toList();
  }

  /// Fetch single showroom by ID
  Future<ShowroomEntity?> fetchShowroomById(String showroomId) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;
        final data = await client.from('showrooms').select().eq('id', showroomId).maybeSingle();
        if (data != null) return ShowroomModel.fromJson(data);
      } catch (e) {
        debugPrint('Supabase fetchShowroomById error: $e');
      }
    }

    _initDevData();
    final matches = _devShowrooms!.where((s) => s.id == showroomId);
    return matches.isNotEmpty ? matches.first : null;
  }

  /// Create a new showroom and auto-generate its 5 default document sequence counters
  Future<ShowroomEntity> createShowroom(
    ShowroomEntity entity, {
    List<InvoiceSequenceEntity>? initialSequences,
  }) async {
    final now = DateTime.now();

    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;
        final model = ShowroomModel.fromEntity(entity);
        final res = await client.from('showrooms').insert(model.toJson()).select().single();
        final createdShowroom = ShowroomModel.fromJson(res);

        // Auto-create document sequences
        final sequencesToInsert = <Map<String, dynamic>>[];
        final prefix = createdShowroom.invoicePrefix;

        for (final docType in DealershipDocType.values) {
          sequencesToInsert.add({
            'showroom_id': createdShowroom.id,
            'doc_type': docType.key,
            'prefix': '$prefix-${docType.defaultPrefix}-',
            'current_number': 0,
            'padding_zeros': 5,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          });
        }

        await client.from('invoice_sequences').insert(sequencesToInsert);
        return createdShowroom;
      } catch (e) {
        debugPrint('Supabase createShowroom error: $e');
        rethrow;
      }
    }

    // Dev Mode
    _initDevData();
    final newId = 'sh-${DateTime.now().millisecondsSinceEpoch % 10000}';
    final created = ShowroomModel(
      id: newId,
      name: entity.name,
      code: entity.code.toUpperCase().trim(),
      address: entity.address,
      city: entity.city,
      state: entity.state,
      pincode: entity.pincode,
      phone: entity.phone,
      email: entity.email,
      gstin: entity.gstin?.toUpperCase().trim(),
      pan: entity.pan?.toUpperCase().trim(),
      bankName: entity.bankName,
      bankAccountNumber: entity.bankAccountNumber,
      bankIfsc: entity.bankIfsc?.toUpperCase().trim(),
      bankBranch: entity.bankBranch,
      invoicePrefix: entity.invoicePrefix.toUpperCase().trim(),
      isActive: entity.isActive,
      createdAt: now,
      updatedAt: now,
    );

    _devShowrooms!.add(created);
    _generateDefaultSequencesForShowroom(newId, created.invoicePrefix);

    return created;
  }

  /// Update showroom details
  Future<ShowroomEntity> updateShowroom(ShowroomEntity entity) async {
    final now = DateTime.now();

    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;
        final model = ShowroomModel.fromEntity(entity);
        final updatePayload = model.toJson()..['updated_at'] = now.toIso8601String();
        final res = await client
            .from('showrooms')
            .update(updatePayload)
            .eq('id', entity.id)
            .select()
            .single();
        return ShowroomModel.fromJson(res);
      } catch (e) {
        debugPrint('Supabase updateShowroom error: $e');
        rethrow;
      }
    }

    // Dev Mode
    _initDevData();
    final index = _devShowrooms!.indexWhere((s) => s.id == entity.id);
    if (index == -1) {
      throw Exception('Showroom not found: ${entity.id}');
    }

    final updated = ShowroomModel(
      id: entity.id,
      name: entity.name,
      code: entity.code.toUpperCase().trim(),
      address: entity.address,
      city: entity.city,
      state: entity.state,
      pincode: entity.pincode,
      phone: entity.phone,
      email: entity.email,
      gstin: entity.gstin?.toUpperCase().trim(),
      pan: entity.pan?.toUpperCase().trim(),
      bankName: entity.bankName,
      bankAccountNumber: entity.bankAccountNumber,
      bankIfsc: entity.bankIfsc?.toUpperCase().trim(),
      bankBranch: entity.bankBranch,
      invoicePrefix: entity.invoicePrefix.toUpperCase().trim(),
      isActive: entity.isActive,
      createdAt: _devShowrooms![index].createdAt,
      updatedAt: now,
    );

    _devShowrooms![index] = updated;
    return updated;
  }

  /// Toggle active / inactive status for showroom
  Future<bool> toggleShowroomStatus(String showroomId, bool isActive) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;
        await client.from('showrooms').update({
          'is_active': isActive,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', showroomId);
        return true;
      } catch (e) {
        debugPrint('Supabase toggleShowroomStatus error: $e');
        rethrow;
      }
    }

    _initDevData();
    final index = _devShowrooms!.indexWhere((s) => s.id == showroomId);
    if (index != -1) {
      final s = _devShowrooms![index];
      _devShowrooms![index] = ShowroomModel(
        id: s.id,
        name: s.name,
        code: s.code,
        address: s.address,
        city: s.city,
        state: s.state,
        pincode: s.pincode,
        phone: s.phone,
        email: s.email,
        gstin: s.gstin,
        pan: s.pan,
        bankName: s.bankName,
        bankAccountNumber: s.bankAccountNumber,
        bankIfsc: s.bankIfsc,
        bankBranch: s.bankBranch,
        invoicePrefix: s.invoicePrefix,
        isActive: isActive,
        createdAt: s.createdAt,
        updatedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  /// Fetch staff members assigned to this showroom
  Future<List<ManagedUser>> fetchShowroomStaff(String showroomId) async {
    final paginated = await UserManagementService.instance.fetchUsers(showroomFilter: showroomId);
    return paginated.users;
  }

  /// Fetch document sequence numbering counters for a showroom
  Future<List<InvoiceSequenceEntity>> fetchShowroomSequences(String showroomId) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;
        final data = await client
            .from('invoice_sequences')
            .select()
            .eq('showroom_id', showroomId)
            .order('doc_type');
        return (data as List).map((row) => InvoiceSequenceModel.fromJson(row)).toList();
      } catch (e) {
        debugPrint('Supabase fetchShowroomSequences error: $e');
      }
    }

    _initDevData();
    return _devSequences!.where((seq) => seq.showroomId == showroomId).toList();
  }

  /// Update invoice sequence counter parameters
  Future<InvoiceSequenceEntity> updateInvoiceSequence(
    String sequenceId, {
    String? prefix,
    int? nextNumber,
    int? paddingZeros,
  }) async {
    final now = DateTime.now();

    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;
        final updates = <String, dynamic>{
          'updated_at': now.toIso8601String(),
        };
        if (prefix != null) updates['prefix'] = prefix.toUpperCase().trim();
        if (nextNumber != null) updates['current_number'] = nextNumber - 1;
        if (paddingZeros != null) updates['padding_zeros'] = paddingZeros;

        final res = await client
            .from('invoice_sequences')
            .update(updates)
            .eq('id', sequenceId)
            .select()
            .single();
        return InvoiceSequenceModel.fromJson(res);
      } catch (e) {
        debugPrint('Supabase updateInvoiceSequence error: $e');
        rethrow;
      }
    }

    // Dev Mode
    _initDevData();
    final index = _devSequences!.indexWhere((s) => s.id == sequenceId);
    if (index == -1) {
      throw Exception('Sequence not found: $sequenceId');
    }

    final current = _devSequences![index];
    final updated = current.copyWith(
      prefix: prefix?.toUpperCase().trim() ?? current.prefix,
      currentNumber: nextNumber != null ? (nextNumber - 1) : current.currentNumber,
      paddingZeros: paddingZeros ?? current.paddingZeros,
      updatedAt: now,
    );

    _devSequences![index] = InvoiceSequenceModel.fromEntity(updated);
    return updated;
  }
}
