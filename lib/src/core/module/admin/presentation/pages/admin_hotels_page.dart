import 'package:booking_app/src/core/module/admin/presentation/widgets/hotel_admin_card.dart';
import 'package:flutter/material.dart';
import '../../../hotel/data/hotel_api.dart';
import '../../../hotel/data/models/hotel_model.dart';
import 'admin_hotel_edit_page.dart';

class AdminHotelsPage extends StatefulWidget {
  const AdminHotelsPage({super.key});

  @override
  State<AdminHotelsPage> createState() => _AdminHotelsPageState();
}

class _AdminHotelsPageState extends State<AdminHotelsPage> {
  final _api = HotelApi();

  List<HotelModel> _allHotels = [];
  List<HotelModel> _filteredHotels = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Hàm loại bỏ dấu tiếng Việt
  String _removeDiacritics(String str) {
    var withDia =
        'àáâãèéêìíòóôõùúýỳỹỷỵựửữừứựụủướướưởứùủụưứừửữựàảãạăắằẳẵặâầẩẫậèẻẽẹêềểễệìỉĩịòỏõọôồổỗộơờởỡợùủũụưừửữựỳỵỷỹ';
    var withoutDia =
        'aaaaeeeeiioooouuyyyyyuuuuuuuuuuuuuuuuuaaaaaaaaaaaeeeeeeeeeeiiiioooooooooooouuuuuuuuuyyyy';

    if (str.isEmpty) return '';

    String result = str.toLowerCase();

    // Lấy độ dài nhỏ nhất để tránh lỗi RangeError
    int length =
        withDia.length < withoutDia.length ? withDia.length : withoutDia.length;

    for (int i = 0; i < length; i++) {
      result = result.replaceAll(withDia[i], withoutDia[i]);
    }

    // Xử lý thêm các ký tự đặc biệt như đ, Đ
    result = result.replaceAll('đ', 'd').replaceAll('đ', 'd');

    return result;
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getAllHotels();
      setState(() {
        _allHotels = data;
        _filteredHotels = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    }
  }

  void _filterHotels(String query) {
    setState(() {
      _searchQuery = query;
      String searchNormalized = _removeDiacritics(query);

      _filteredHotels =
          _allHotels.where((h) {
            String nameNormalized = _removeDiacritics(h.name);
            return nameNormalized.contains(searchNormalized);
          }).toList();
    });
  }

  Future<void> _openEditPage({HotelModel? hotel}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminHotelEditPage(hotel: hotel)),
    );
    if (result == true) _loadData();
  }

  Future<void> _confirmDelete(HotelModel hotel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Xác nhận xóa?'),
            content: Text(
              'Hành động này không thể hoàn tác. Xóa "${hotel.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Xóa', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _api.deleteHotel(hotel.id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã xóa khách sạn')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header cố định
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const SizedBox(height: 16), _buildSearchField()],
              ),
            ),

            // Danh sách cuộn
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                        onRefresh: _loadData,
                        child:
                            _filteredHotels.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    4,
                                    16,
                                    80,
                                  ),
                                  itemCount: _filteredHotels.length,
                                  itemBuilder: (context, index) {
                                    final h = _filteredHotels[index];
                                    return HotelAdminCard(
                                      hotel: h,
                                      onEdit: () => _openEditPage(hotel: h),
                                      onDelete: () => _confirmDelete(h),
                                    );
                                  },
                                ),
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditPage(),
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm mới',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: _filterHotels,
        decoration: InputDecoration(
          hintText: '',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _filterHotels('');
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Chưa có khách sạn nào'
                  : 'Không tìm thấy "$_searchQuery"',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
