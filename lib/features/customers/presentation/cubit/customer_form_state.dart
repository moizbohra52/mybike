import 'package:equatable/equatable.dart';

/// Customer Form View State
class CustomerFormState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final bool isSaved;
  final String? error;
  final bool isEditMode;
  final String? editCustomerId;
  // Form fields
  final String firstName;
  final String lastName;
  final String mobilePrimary;
  final String? mobileSecondary;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? pinCode;
  final String? landmark;
  final String customerType;
  final String? source;
  final String? preferredContactMethod;
  final String? notes;
  final String? selectedShowroomId;

  const CustomerFormState({
    this.isLoading = false,
    this.isSaving = false,
    this.isSaved = false,
    this.error,
    this.isEditMode = false,
    this.editCustomerId,
    this.firstName = '',
    this.lastName = '',
    this.mobilePrimary = '',
    this.mobileSecondary,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.pinCode,
    this.landmark,
    this.customerType = 'individual',
    this.source = 'walk_in',
    this.preferredContactMethod = 'phone',
    this.notes,
    this.selectedShowroomId,
  });

  CustomerFormState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isSaved,
    String? error,
    bool? isEditMode,
    String? editCustomerId,
    String? firstName,
    String? lastName,
    String? mobilePrimary,
    String? mobileSecondary,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pinCode,
    String? landmark,
    String? customerType,
    String? source,
    String? preferredContactMethod,
    String? notes,
    String? selectedShowroomId,
  }) {
    return CustomerFormState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      error: error,
      isEditMode: isEditMode ?? this.isEditMode,
      editCustomerId: editCustomerId ?? this.editCustomerId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobilePrimary: mobilePrimary ?? this.mobilePrimary,
      mobileSecondary: mobileSecondary ?? this.mobileSecondary,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      landmark: landmark ?? this.landmark,
      customerType: customerType ?? this.customerType,
      source: source ?? this.source,
      preferredContactMethod: preferredContactMethod ?? this.preferredContactMethod,
      notes: notes ?? this.notes,
      selectedShowroomId: selectedShowroomId ?? this.selectedShowroomId,
    );
  }

  @override
  List<Object?> get props => [
        isLoading, isSaving, isSaved, error, isEditMode, editCustomerId,
        firstName, lastName, mobilePrimary, mobileSecondary, email,
        dateOfBirth, gender, addressLine1, addressLine2, city, state,
        pinCode, landmark, customerType, source, preferredContactMethod,
        notes, selectedShowroomId,
      ];
}
