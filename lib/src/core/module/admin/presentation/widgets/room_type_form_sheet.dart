import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../hotel/data/models/hotel_model.dart';

class RoomTypeFormSheet extends StatefulWidget {
  final RoomTypeModel? room;
  final Function(
    String name,
    double price,
    int capacity,
    String bed,
    String desc,
    List<String> amenities,
    List<XFile> newImages,
    List<String> existingImages,
  )
  onSave;

  const RoomTypeFormSheet({super.key, this.room, required this.onSave});

  @override
  State<RoomTypeFormSheet> createState() => _RoomTypeFormSheetState();
}

class _RoomTypeFormSheetState extends State<RoomTypeFormSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _capCtrl;
  late TextEditingController _bedCtrl;
  late TextEditingController _descCtrl;

  final List<XFile> _newImages = [];
  List<String> _existingImages = [];
  List<String> _amenities = [];

  final _picker = ImagePicker();

  final List<String> _commonAmenities = const [
    'Wifi',
    'Điều hòa',
    'Tivi',
    'Tủ lạnh',
    'Bồn tắm',
    'Ban công',
    'Minibar',
    'Máy sấy',
  ];

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.room?.name ?? '');
    _priceCtrl = TextEditingController(
      text: widget.room?.pricePerNight.toString() ?? '',
    );
    _capCtrl = TextEditingController(
      text: widget.room?.capacity.toString() ?? '',
    );
    _bedCtrl = TextEditingController(text: widget.room?.bedType ?? '');
    _descCtrl = TextEditingController(text: widget.room?.description ?? '');

    _existingImages = List.from(widget.room?.imageUrl ?? []);
    _amenities = List.from(widget.room?.amenities ?? []);
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _newImages.addAll(images));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0D47A1);
    const bg = Color(0xFFF4F7FA);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            _buildInput(_nameCtrl, "Tên loại phòng", Icons.bed, bg, primary),

            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    _priceCtrl,
                    "Giá",
                    Icons.money,
                    bg,
                    primary,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInput(
                    _capCtrl,
                    "Sức chứa",
                    Icons.people,
                    bg,
                    primary,
                    isNumber: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children:
                  _commonAmenities.map((a) {
                    final selected = _amenities.contains(a);
                    return FilterChip(
                      label: Text(a),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          v ? _amenities.add(a) : _amenities.remove(a);
                        });
                      },
                    );
                  }).toList(),
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(
                        right: 8,
                      ), // Thêm chút margin cho đẹp
                      color: Colors.grey[200],
                      child: const Icon(Icons.add_a_photo),
                    ),
                  ),

                  // Ảnh từ URL (Sử dụng CachedNetworkImage)
                  ..._existingImages.map((e) {
                    return _imageBox(
                      CachedNetworkImage(
                        imageUrl: e,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: Colors.grey[100],
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[100],
                              child: const Icon(Icons.broken_image),
                            ),
                      ),
                      () => setState(() => _existingImages.remove(e)),
                    );
                  }),

                  // Ảnh từ File local (Giữ nguyên Image.file)
                  ..._newImages.map((e) {
                    return _imageBox(
                      Image.file(File(e.path), fit: BoxFit.cover),
                      () => setState(() => _newImages.remove(e)),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                ),
                onPressed: () async {
                  await widget.onSave(
                    _nameCtrl.text,
                    double.tryParse(_priceCtrl.text) ?? 0,
                    int.tryParse(_capCtrl.text) ?? 0,
                    _bedCtrl.text,
                    _descCtrl.text,
                    _amenities,
                    _newImages,
                    _existingImages,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text("XÁC NHẬN LƯU"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageBox(Widget img, VoidCallback onDelete) {
    return Stack(
      children: [
        SizedBox(width: 80, height: 80, child: img),
        Positioned(
          right: 0,
          child: GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(
    TextEditingController c,
    String label,
    IconData icon,
    Color bg,
    Color primary, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primary),
        filled: true,
        fillColor: bg,
      ),
    );
  }
}
