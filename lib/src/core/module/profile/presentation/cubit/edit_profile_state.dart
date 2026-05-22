abstract class EditProfileState {}

class EditProfileInitial extends EditProfileState {}

class EditProfileSaving extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {}

class EditProfileError extends EditProfileState {
  final String message;
  EditProfileError(this.message);
}