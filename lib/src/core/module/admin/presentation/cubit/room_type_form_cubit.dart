import 'package:booking_app/src/core/module/admin/presentation/cubit/room_type_form_state.dart';
import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class RoomTypeFormCubit extends Cubit<RoomTypeFormState> {
  RoomTypeFormCubit() : super(const RoomTypeFormState());

  void init(RoomTypeModel? room) {
    emit(state.copyWith(
      name: room?.name ?? '',
      price: room?.pricePerNight.toString() ?? '',
      capacity: room?.capacity.toString() ?? '',
      bed: room?.bedType ?? '',
      desc: room?.description ?? '',
      amenities: List.from(room?.amenities ?? []),
      existingImages: List.from(room?.imageUrl ?? []),
    ));
  }

  void setName(String v) => emit(state.copyWith(name: v));
  void setPrice(String v) => emit(state.copyWith(price: v));
  void setCapacity(String v) => emit(state.copyWith(capacity: v));
  void setBed(String v) => emit(state.copyWith(bed: v));
  void setDesc(String v) => emit(state.copyWith(desc: v));

  void toggleAmenity(String a) {
    final list = List<String>.from(state.amenities);
    list.contains(a) ? list.remove(a) : list.add(a);
    emit(state.copyWith(amenities: list));
  }

  void addImages(List<XFile> imgs) {
    emit(state.copyWith(
      newImages: [...state.newImages, ...imgs],
    ));
  }

  void removeExisting(int index) {
    final list = List<String>.from(state.existingImages);
    list.removeAt(index);
    emit(state.copyWith(existingImages: list));
  }

  void removeNew(int index) {
    final list = List<XFile>.from(state.newImages);
    list.removeAt(index);
    emit(state.copyWith(newImages: list));
  }
}