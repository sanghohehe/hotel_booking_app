import 'package:booking_app/src/core/module/admin/domain/repositories/i_hotel_repository.dart';
import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';
import 'package:image_picker/image_picker.dart';

class SaveHotelUseCase {
  final IHotelRepository repository;
  SaveHotelUseCase(this.repository);

  Future<List<String>> execute({
    required HotelModel? existing,
    required String name,
    required String city,
    required String address,
    String? description,
    required double starRating,
    required List<XFile> images,
    required List<String> existingImages, 
  }) async {
    return await repository.saveHotel(
      existingHotel: existing,
      name: name,
      city: city,
      address: address,
      description: description,
      starRating: starRating,
      multipleImages: images,
      existingImages: existingImages, 
    );
  }
}
