import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../cubit/edit_profile_cubit.dart';
import '../cubit/edit_profile_state.dart';
import '../../data/user_profile_model.dart';
import '../widgets/edit_avatar_section.dart';
import '../widgets/modern_text_field.dart';
import '../widgets/modern_date_picker.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfileModel? initialProfile;
  final String initialEmail;
  final String initialFullName;

  const EditProfilePage({
    super.key,
    required this.initialEmail,
    required this.initialFullName,
    this.initialProfile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  DateTime? _dob;
  XFile? _newAvatarFile;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _fullNameController = TextEditingController(
      text: p?.fullName ?? widget.initialFullName,
    );
    _phoneController = TextEditingController(text: p?.phoneNumber ?? '');
    _addressController = TextEditingController(text: p?.address ?? '');
    _dob = p?.dateOfBirth;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditProfileCubit(),
      child: BlocListener<EditProfileCubit, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileSuccess) {
            Navigator.pop(context, true);
          } else if (state is EditProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: _buildScaffold(context),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (context, setLocalState) {
                  return EditAvatarSection(
                    currentAvatarUrl: widget.initialProfile?.avatarUrl,
                    newAvatarFile: _newAvatarFile,
                    onPickImage: () async {
                      final file = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (file != null)
                        setLocalState(() => _newAvatarFile = file);
                    },
                  );
                },
              ),
              const SizedBox(height: 40),
              ModernTextField(
                label: 'Full Name',
                controller: _fullNameController,
                icon: Icons.person,
              ),
              const SizedBox(height: 20),
              ModernTextField(
                label: 'Email',
                initialValue: widget.initialEmail,
                icon: Icons.email,
                enabled: false,
              ),
              const SizedBox(height: 20),
              ModernTextField(
                label: 'Phone',
                controller: _phoneController,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (context, setLocalState) {
                  return ModernDatePicker(
                    label: 'Birthday',
                    selectedDate: _dob,
                    formattedDate:
                        _dob != null
                            ? DateFormat('dd/MM/yyyy').format(_dob!)
                            : '',
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dob ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setLocalState(() => _dob = picked);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              ModernTextField(
                label: 'Address',
                controller: _addressController,
                icon: Icons.location_on,
                maxLines: 2,
              ),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<EditProfileCubit, EditProfileState>(
      builder: (context, state) {
        final isLoading = state is EditProfileSaving;
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed:
                isLoading
                    ? null
                    : () {
                      if (_formKey.currentState!.validate()) {
                        context.read<EditProfileCubit>().updateProfile(
                          fullName: _fullNameController.text.trim(),
                          phoneNumber: _phoneController.text.trim(),
                          dob: _dob,
                          address: _addressController.text.trim(),
                          currentAvatarUrl: widget.initialProfile?.avatarUrl,
                          newAvatarFile: _newAvatarFile,
                        );
                      }
                    },
            child:
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
          ),
        );
      },
    );
  }
}
