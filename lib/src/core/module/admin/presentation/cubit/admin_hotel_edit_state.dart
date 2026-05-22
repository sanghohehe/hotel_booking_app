import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';
import 'package:image_picker/image_picker.dart';

class _Undefined {
  const _Undefined();
}
const _undefined = _Undefined();

class AdminHotelEditState {
  final List<RoomTypeModel> roomTypes;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool isSuccess;
  final double rating;

  final List<String> existingImages;
  final List<XFile> newImages;
  final int currentIndex;

  final List<dynamic> provinces;
  final List<dynamic> districts;
  final List<dynamic> wards;

  final String? selectedProvince;
  final String? selectedDistrict;
  final String? selectedWard;

  AdminHotelEditState({
    this.roomTypes = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.isSuccess = false,
    this.rating = 4.0,
    this.existingImages = const [],
    this.newImages = const [],
    this.currentIndex = 0,
    this.provinces = const [],
    this.districts = const [],
    this.wards = const [],
    this.selectedProvince,
    this.selectedDistrict,
    this.selectedWard,
  });

  AdminHotelEditState copyWith({
    List<RoomTypeModel>? roomTypes,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? isSuccess,
    double? rating,
    List<String>? existingImages,
    List<XFile>? newImages,
    int? currentIndex,
    List<dynamic>? provinces,
    List<dynamic>? districts,
    List<dynamic>? wards,
    Object? selectedProvince = _undefined,
    Object? selectedDistrict = _undefined,
    Object? selectedWard = _undefined,
  }) {
    return AdminHotelEditState(
      provinces: provinces ?? this.provinces,
      districts: districts ?? this.districts,
      wards: wards ?? this.wards,
      selectedProvince: selectedProvince is _Undefined
          ? this.selectedProvince
          : selectedProvince as String?,
      selectedDistrict: selectedDistrict is _Undefined
          ? this.selectedDistrict
          : selectedDistrict as String?,
      selectedWard: selectedWard is _Undefined
          ? this.selectedWard
          : selectedWard as String?,
      roomTypes: roomTypes ?? this.roomTypes,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
      rating: rating ?? this.rating,
      existingImages: existingImages ?? this.existingImages,
      newImages: newImages ?? this.newImages,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}