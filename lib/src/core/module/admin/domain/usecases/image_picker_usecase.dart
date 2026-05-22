import 'package:image_picker/image_picker.dart';

class PickImagesUseCase {
  final ImagePicker picker;

  PickImagesUseCase(this.picker);

  Future<List<XFile>> execute() async {
    return await picker.pickMultiImage();
  }
}