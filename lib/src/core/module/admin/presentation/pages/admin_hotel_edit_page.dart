import 'dart:io';

import 'package:booking_app/src/core/module/admin/domain/usecases/image_picker_usecase.dart';
import 'package:booking_app/src/core/module/admin/domain/usecases/init_hotel_usecase.dart';
import 'package:booking_app/src/core/module/admin/domain/usecases/load_rooms_usecase.dart';
import 'package:booking_app/src/core/module/admin/domain/usecases/save_room_type_usecase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:booking_app/src/core/module/hotel/data/hotel_api.dart';
import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';
import 'package:booking_app/src/core/module/admin/presentation/widgets/room_type_item.dart';
import 'package:booking_app/src/core/module/admin/presentation/widgets/room_type_form_sheet.dart';

import '../cubit/admin_hotel_edit_cubit.dart';
import '../cubit/admin_hotel_edit_state.dart';

import '../../domain/usecases/save_hotel_usecase.dart';
import '../../domain/usecases/delete_room_usecase.dart';
import '../../data/repositories/hotel_repository_impl.dart';

class AdminHotelEditPage extends StatefulWidget {
  final HotelModel? hotel;
  const AdminHotelEditPage({super.key, this.hotel});

  @override
  State<AdminHotelEditPage> createState() => _AdminHotelEditPageState();
}

class _AdminHotelEditPageState extends State<AdminHotelEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _detailAddrCtrl = TextEditingController();

  late final AdminHotelEditCubit _cubit;

  @override
  void initState() {
    super.initState();

    final repo = HotelRepositoryImpl(HotelApi());
    _cubit = AdminHotelEditCubit(
      saveHotelUseCase: SaveHotelUseCase(repo),
      deleteRoomUseCase: DeleteRoomUseCase(repo),
      loadRoomsUseCase: LoadRoomsUseCase(repo),
      initHotelUseCase: InitHotelUseCase(),
      pickImagesUseCase: PickImagesUseCase(ImagePicker()),
      saveRoomTypeUseCase: SaveRoomTypeUseCase(repo),
    );

    _nameCtrl.text = widget.hotel?.name ?? '';
    _descCtrl.text = widget.hotel?.description ?? '';

    if (widget.hotel != null) {
      final parts = widget.hotel!.address.split(',');
      if (parts.isNotEmpty) {
        _detailAddrCtrl.text = parts[0].trim();
      }
    }

    _cubit.loadLocationData().then((_) {
      if (widget.hotel != null) {
        _cubit.initHotel(widget.hotel!);
        _cubit.loadRooms(widget.hotel!.id);
      }
    });
  }

  @override
  void dispose() {
    _cubit.close();
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _addrCtrl.dispose();
    _descCtrl.dispose();
    _detailAddrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<AdminHotelEditCubit, AdminHotelEditState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật thành công!')),
            );
            Navigator.pop(context, true);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.hotel == null ? "Thêm khách sạn" : "Sửa khách sạn",
              ),
            ),
            body: _buildInputs(context, state, Theme.of(context)),
            bottomNavigationBar: _buildBottomBar(
              context,
              state,
              Theme.of(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGallery(BuildContext context, AdminHotelEditState state) {
    final images = [
      ...state.existingImages,
      ...state.newImages.map((e) => e.path),
    ];

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child:
            images.isEmpty
                ? InkWell(
                  onTap: () => context.read<AdminHotelEditCubit>().pickImages(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Nhấn để tải ảnh lên",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
                : Stack(
                  children: [
                    PageView.builder(
                      itemCount: images.length,
                      onPageChanged:
                          (i) => context
                              .read<AdminHotelEditCubit>()
                              .setCurrentIndex(i),
                      itemBuilder: (_, index) {
                        final img = images[index];
                        final isNetwork = img.startsWith('http');
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            isNetwork
                                ? CachedNetworkImage(
                                  imageUrl: img,
                                  fit: BoxFit.cover,
                                  // Hiển thị loading khi đang tải ảnh
                                  placeholder:
                                      (context, url) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  // Hiển thị icon lỗi nếu không tải được ảnh
                                  errorWidget:
                                      (context, url, error) =>
                                          const Icon(Icons.error),
                                )
                                : Image.file(File(img), fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    final cubit =
                                        context.read<AdminHotelEditCubit>();
                                    if (index < state.existingImages.length) {
                                      cubit.removeExistingImage(index);
                                    } else {
                                      cubit.removeNewImage(
                                        index - state.existingImages.length,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${state.currentIndex + 1}/${images.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: FloatingActionButton.small(
                        heroTag: 'add_img',
                        onPressed:
                            () =>
                                context
                                    .read<AdminHotelEditCubit>()
                                    .pickImages(),
                        child: const Icon(Icons.add_a_photo),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildInputs(
    BuildContext context,
    AdminHotelEditState state,
    ThemeData theme,
  ) {
    final cubit = context.read<AdminHotelEditCubit>();
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionTitle(context, "Hình ảnh", Icons.image),
            const SizedBox(height: 12),
            _buildGallery(context, state),

            const SizedBox(height: 24),
            _buildSectionTitle(context, "Thông tin chung", Icons.info_outline),
            const SizedBox(height: 12),
            _customTextField(
              controller: _nameCtrl,
              label: "Tên khách sạn",
              icon: Icons.hotel,
            ),
            const SizedBox(height: 16),

            _buildDropdown(
              label: "Tỉnh / Thành phố",
              value: state.selectedProvince,
              items: state.provinces,
              onChanged: (val) => cubit.onProvinceChanged(val),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: "Quận / Huyện",
              value: state.selectedDistrict,
              items: state.districts,
              onChanged: (val) => cubit.onDistrictChanged(val),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: "Phường / Xã",
              value: state.selectedWard,
              items: state.wards,
              onChanged: (val) {
                cubit.onWardChanged(val);
                _addrCtrl.text =
                    "$val, ${state.selectedDistrict}, ${state.selectedProvince}";
              },
            ),
            const SizedBox(height: 16),
            _customTextField(
              controller: _detailAddrCtrl,
              label: "Số nhà, tên đường",
              icon: Icons.location_on_outlined,
              hint: "Ví dụ: 123 Võ Nguyên Giáp",
            ),
            const SizedBox(height: 16),

            _customTextField(
              controller: _descCtrl,
              label: "Mô tả",
              icon: Icons.description,
              maxLines: 3,
            ),

            const SizedBox(height: 24),
            _buildSectionTitle(context, "Loại phòng", Icons.meeting_room),
            const SizedBox(height: 12),
            _buildRoomList(context, state),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<dynamic> items,
    required Function(String?) onChanged,
  }) {
    final bool hasValue = items.any((item) => item['name'] == value);

    return DropdownButtonFormField<String>(
      value: hasValue ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          items.map<DropdownMenuItem<String>>((item) {
            return DropdownMenuItem<String>(
              value: item['name'] as String,
              child: Text(
                item['name'] as String,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, size: 22, color: Colors.blueGrey[600]),
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Thông tin này không được bỏ trống';
        }
        return null;
      },
    );
  }

  Widget _buildRoomList(BuildContext context, AdminHotelEditState state) {
    if (state.roomTypes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "Chưa có loại phòng nào được tạo",
            style: TextStyle(
              color: Colors.grey[400],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.roomTypes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final room = state.roomTypes[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5),
            ],
          ),
          child: RoomTypeItem(
            room: room,
            onEdit: () => _openEditRoom(context, room),
            onDelete:
                () => _showDeleteDialog(context, room.id, widget.hotel!.id),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    AdminHotelEditState state,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed:
              state.isSaving
                  ? null
                  : () {
                    if (_formKey.currentState!.validate()) {
                      context.read<AdminHotelEditCubit>().onSave(
                        existing: widget.hotel,
                        name: _nameCtrl.text,
                        city: state.selectedProvince ?? '',
                        address: _addrCtrl.text,
                        desc: _descCtrl.text,
                        detailAddress: _detailAddrCtrl.text,
                      );
                    }
                  },
          child:
              state.isSaving
                  ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text(
                    "XÁC NHẬN LƯU",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
        ),
      ),
    );
  }

  void _openEditRoom(BuildContext context, RoomTypeModel room) {
    final cubit = context.read<AdminHotelEditCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return RoomTypeFormSheet(
          room: room,
          onSave: (
            name,
            price,
            capacity,
            bed,
            desc,
            amenities,
            newImages,
            existingImages,
          ) async {
            try {
              final updatedRoom = RoomTypeModel(
                id: room.id,
                name: name,
                description: desc,
                capacity: capacity,
                bedType: bed,
                pricePerNight: price,
                isActive: room.isActive,
                inventory: room.inventory,
                imageUrl: existingImages,
                amenities: amenities,
              );

              await cubit.saveRoomType(
                hotelId: widget.hotel!.id,
                room: updatedRoom,
                newImages: newImages,
              );

              if (!context.mounted) return;
              Navigator.pop(sheetContext);
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
            }
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String roomId, String hotelId) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Xóa phòng"),
            content: const Text("Bạn chắc chắn muốn xóa?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () {
                  context.read<AdminHotelEditCubit>().deleteRoom(
                    roomId,
                    hotelId,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Xóa", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
