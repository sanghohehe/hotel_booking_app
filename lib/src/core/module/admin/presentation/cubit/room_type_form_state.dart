import 'package:image_picker/image_picker.dart';

class RoomTypeFormState {
  final String name;
  final String price;
  final String capacity;
  final String bed;
  final String desc;

  final List<String> amenities;
  final List<XFile> newImages;
  final List<String> existingImages;

  final bool isLoading;

  const RoomTypeFormState({
    this.name = '',
    this.price = '',
    this.capacity = '',
    this.bed = '',
    this.desc = '',
    this.amenities = const [],
    this.newImages = const [],
    this.existingImages = const [],
    this.isLoading = false,
  });

  RoomTypeFormState copyWith({
    String? name,
    String? price,
    String? capacity,
    String? bed,
    String? desc,
    List<String>? amenities,
    List<XFile>? newImages,
    List<String>? existingImages,
    bool? isLoading,
  }) {
    return RoomTypeFormState(
      name: name ?? this.name,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      bed: bed ?? this.bed,
      desc: desc ?? this.desc,
      amenities: amenities ?? this.amenities,
      newImages: newImages ?? this.newImages,
      existingImages: existingImages ?? this.existingImages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}