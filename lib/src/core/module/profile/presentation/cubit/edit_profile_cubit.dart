import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_profile_state.dart';
import '../../data/profile_api.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final _api = ProfileApi();

  EditProfileCubit() : super(EditProfileInitial());

  Future<void> updateProfile({
    required String fullName,
    String? phoneNumber,
    DateTime? dob,
    String? address,
    String? currentAvatarUrl,
    XFile? newAvatarFile,
  }) async {
    emit(EditProfileSaving());
    try {
      String? avatarUrl = currentAvatarUrl;

      // Xử lý upload ảnh nếu có file mới
      if (newAvatarFile != null) {
        final bytes = await newAvatarFile.readAsBytes();
        final ext = newAvatarFile.name.split('.').last.toLowerCase();
        avatarUrl = await _api.uploadAvatar(bytes, ext);
      }

      // Upsert profile
      await _api.upsertMyProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        dateOfBirth: dob,
        address: address,
        avatarUrl: avatarUrl,
      );

      emit(EditProfileSuccess());
    } catch (e) {
      emit(EditProfileError(e.toString()));
    }
  }
}