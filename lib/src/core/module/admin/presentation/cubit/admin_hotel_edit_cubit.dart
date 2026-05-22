import 'dart:convert';

import 'package:booking_app/src/core/module/admin/domain/usecases/delete_room_usecase.dart';
import 'package:booking_app/src/core/module/admin/domain/usecases/image_picker_usecase.dart';
import 'package:booking_app/src/core/module/admin/domain/usecases/init_hotel_usecase.dart';
import 'package:booking_app/src/core/module/admin/domain/usecases/load_rooms_usecase.dart';
import 'package:booking_app/src/core/module/admin/domain/usecases/save_hotel_usecase.dart';
import 'package:booking_app/src/core/module/admin/domain/usecases/save_room_type_usecase.dart';
import 'package:booking_app/src/core/module/admin/presentation/cubit/admin_hotel_edit_state.dart';
import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AdminHotelEditCubit extends Cubit<AdminHotelEditState> {
  final SaveHotelUseCase saveHotelUseCase;
  final DeleteRoomUseCase deleteRoomUseCase;
  final LoadRoomsUseCase loadRoomsUseCase;
  final InitHotelUseCase initHotelUseCase;
  final PickImagesUseCase pickImagesUseCase;
  final SaveRoomTypeUseCase saveRoomTypeUseCase;

  AdminHotelEditCubit({
    required this.saveHotelUseCase,
    required this.deleteRoomUseCase,
    required this.loadRoomsUseCase,
    required this.initHotelUseCase,
    required this.pickImagesUseCase,
    required this.saveRoomTypeUseCase,
  }) : super(AdminHotelEditState());

  void initHotel(HotelModel hotel) {
    // 1. Tìm tỉnh thành trong danh sách đã load
    final province = state.provinces.firstWhere(
      (p) => p['name'] == hotel.city,
      orElse: () => null,
    );

    List<dynamic> districts = [];
    List<dynamic> wards = [];
    String? selectedDistrict;
    String? selectedWard;

    if (province != null) {
      districts = List<dynamic>.from(province['districts']);

      // 2. Tách chuỗi địa chỉ: "Số nhà, Phường, Quận, Thành phố"
      final parts = hotel.address.split(',').map((e) => e.trim()).toList();

      // Logic tách ngược từ cuối chuỗi lên
      if (parts.length >= 3) {
        selectedDistrict = parts[parts.length - 2]; // Quận/Huyện nằm kế cuối
        selectedWard = parts[parts.length - 3]; // Phường/Xã nằm trước Quận

        // 3. Tìm danh sách phường dựa trên Quận đã tách
        final district = districts.firstWhere(
          (d) => d['name'] == selectedDistrict,
          orElse: () => null,
        );
        if (district != null) {
          wards = List<dynamic>.from(district['wards']);
        }
      }
    }

    emit(
      state.copyWith(
        existingImages: hotel.images, // Hiện lại ảnh cũ
        selectedProvince: hotel.city,
        selectedDistrict: selectedDistrict,
        selectedWard: selectedWard,
        districts: districts,
        wards: wards,
      ),
    );
  }

  // IMAGE
  Future<void> pickImages() async {
    final images = await pickImagesUseCase.execute();
    if (images.isNotEmpty) {
      emit(state.copyWith(newImages: [...state.newImages, ...images]));
    }
  }

  void removeExistingImage(int index) {
    final updated = List<String>.from(state.existingImages)..removeAt(index);
    emit(state.copyWith(existingImages: updated));
  }

  void removeNewImage(int index) {
    final updated = List<XFile>.from(state.newImages)..removeAt(index);
    emit(state.copyWith(newImages: updated));
  }

  void setAsCover(int index) {
    final list = List<String>.from(state.existingImages);
    final item = list.removeAt(index);
    list.insert(0, item);
    emit(state.copyWith(existingImages: list));
  }

  void setCurrentIndex(int i) => emit(state.copyWith(currentIndex: i));
  void setRating(double r) => emit(state.copyWith(rating: r));

  // LOAD ROOMS
  Future<void> loadRooms(String hotelId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final rooms = await loadRoomsUseCase.execute(hotelId);
      emit(state.copyWith(roomTypes: rooms, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // SAVE HOTEL
  Future<void> onSave({
    required HotelModel? existing,
    required String name,
    required String city,
    required String address,
    required String desc,
    required String detailAddress, // Nhận dữ liệu từ TextField địa chỉ chi tiết
  }) async {
    emit(state.copyWith(isSaving: true, error: null));

    try {
      // 1. Xác định Thành phố: Ưu tiên dropdown, nếu không có thì dùng giá trị cũ
      final finalCity = state.selectedProvince ?? city;

      // 2. Gộp chuỗi địa chỉ: Detail + Ward + District + Province
      // Nếu user đã chọn đủ 3 cấp dropdown, ta gộp mới hoàn toàn
      final bool hasFullDropdown =
          state.selectedProvince != null &&
          state.selectedDistrict != null &&
          state.selectedWard != null;

      final finalAddress =
          hasFullDropdown
              ? "$detailAddress, ${state.selectedWard}, ${state.selectedDistrict}, ${state.selectedProvince}"
              : address; // Nếu chưa chọn đủ dropdown, giữ nguyên address cũ (hoặc xử lý tùy ý)

      final updatedImages = await saveHotelUseCase.execute(
        existing: existing,
        name: name,
        city: finalCity,
        address: finalAddress, // Truyền chuỗi đã gộp có kèm số nhà/tên đường
        description: desc,
        starRating: state.rating,
        images: state.newImages,
        existingImages: state.existingImages,
      );

      emit(
        state.copyWith(
          existingImages: updatedImages,
          newImages: [],
          isSaving: false,
          isSuccess: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  // DELETE ROOM
  Future<void> deleteRoom(String roomId, String hotelId) async {
    await deleteRoomUseCase.execute(roomId);
    await loadRooms(hotelId);
  }

  // SAVE ROOM TYPE (tách UI logic ra ngoài nếu muốn clean hơn nữa)
  Future<void> saveRoomType({
    required String hotelId,
    required RoomTypeModel room,
    required List<XFile> newImages,
  }) async {
    await saveRoomTypeUseCase.execute(
      hotelId: hotelId,
      room: room,
      newImages: newImages,
    );

    await loadRooms(hotelId);
  }

  Future<void> loadLocationData() async {
    final String response = await rootBundle.loadString(
      'assets/provinces/vietnam-provinces.json',
    );
    final data = json.decode(response);
    emit(state.copyWith(provinces: data));
  }

  void onProvinceChanged(String? provinceName) {
    if (provinceName == null) return;

    final province = state.provinces.firstWhere(
      (p) => p['name'] == provinceName,
    );
    emit(
      state.copyWith(
        selectedProvince: provinceName,
        districts: province['districts'],
        selectedDistrict: null,
        selectedWard: null,
        wards: [],
      ),
    );
  }

  void onDistrictChanged(String? districtName) {
    if (districtName == null) return;

    final district = state.districts.firstWhere(
      (d) => d['name'] == districtName,
    );
    emit(
      state.copyWith(
        selectedDistrict: districtName,
        wards: district['wards'],
        selectedWard: null,
      ),
    );
  }

  void onWardChanged(String? wardName) {
    emit(state.copyWith(selectedWard: wardName));
  }
}
