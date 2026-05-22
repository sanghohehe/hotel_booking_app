import 'dart:async';

import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';
import 'package:booking_app/src/core/module/hotel/data/recently_viewed_service.dart';
import 'package:booking_app/src/core/module/hotel/domain/entities/hotel_entity.dart';
import 'package:booking_app/src/core/module/hotel/presentation/cubit/hotelState.dart';
import 'package:booking_app/src/core/module/hotel/presentation/cubit/hotel_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/city_api.dart';
import '../../data/models/city_model.dart';

import 'hotel_detail_page.dart';

class HotelListPage extends StatefulWidget {
  const HotelListPage({super.key});

  @override
  State<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage> {
  final _cityApi = CityApi();

  double? _selectedMinRating;
  final List<double?> _ratingFilters = [null, 4.0, 4.5, 5.0];
  String? _selectedCity;

  String? _searchKeyword;
  Timer? _debounce;

  bool _loadingCities = false;
  final ScrollController _scrollController = ScrollController();
  List<CityModel> _cities = [];
  List<HotelEntity> _recentlyViewed = [];

  @override
  void initState() {
    super.initState();
    _loadCities();
    _loadRecentlyViewed();
    context.read<HotelCubit>().fetchHotels();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentlyViewed() async {
    final hotels = await RecentlyViewedService.getHotels();
    debugPrint('Recently viewed count: ${hotels.length}');
    if (mounted) setState(() => _recentlyViewed = hotels);
  }

  Future<void> _loadCities() async {
    setState(() => _loadingCities = true);
    try {
      final data = await _cityApi.getCities();
      if (!mounted) return;
      setState(() => _cities = data);
    } catch (e) {
      debugPrint("Error loading cities: $e");
    } finally {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  void _reload() {
    context.read<HotelCubit>().fetchHotels(
      minRating: _selectedMinRating,
      city: _selectedCity,
      keyword: _searchKeyword,
      page: 1,
    );
  }

  void _onSearchChanged(String value) {
    _searchKeyword = value.isEmpty ? null : value;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _reload();
    });
  }

  void _clearSearch() {
    _searchKeyword = null;
    _reload();
    setState(() {});
  }

  void _openCityFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select City',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Option clear filter
              ListTile(
                title: const Text(
                  'All Cities',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                leading: const Icon(Icons.public, color: Colors.teal),
                selected: _selectedCity == null,
                selectedTileColor: Colors.teal.withOpacity(0.1),
                onTap: () {
                  setState(() => _selectedCity = null);
                  _reload();
                  Navigator.pop(context);
                },
              ),

              const Divider(),

              ..._cities.map(
                (city) => ListTile(
                  title: Text(city.name),
                  leading: const Icon(Icons.location_city),
                  selected: _selectedCity == city.name,
                  selectedTileColor: Colors.teal.withOpacity(0.1),
                  onTap: () {
                    setState(() => _selectedCity = city.name);
                    _reload();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
    );
  }

  String _getMinPrice(HotelEntity hotel) {
    if (hotel.roomTypes.isEmpty) return 'N/A';

    final prices =
        hotel.roomTypes
            .whereType<RoomTypeModel>()
            .map((r) => r.pricePerNight)
            .toList();

    if (prices.isEmpty) return 'N/A';

    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    return 'From \$${minPrice.toStringAsFixed(0)}/night';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // APP BAR
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              centerTitle: false,
              title: Text(
                'Explore Hotels',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),

          // FILTER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _openCityFilter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    _selectedCity != null
                                        ? '$_selectedCity - Search hotel...'
                                        : 'Where are you going?',
                              ),
                            ),
                          ),
                          if (_searchKeyword != null &&
                              _searchKeyword!.isNotEmpty)
                            GestureDetector(
                              onTap: _clearSearch,
                              child: const Icon(Icons.clear),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Chip hiển thị thành phố đang filter
                  if (_selectedCity != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        children: [
                          Chip(
                            avatar: const Icon(Icons.location_city, size: 16),
                            label: Text(_selectedCity!),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() => _selectedCity = null);
                              _reload();
                            },
                            backgroundColor: Colors.teal.withOpacity(0.1),
                            side: const BorderSide(color: Colors.teal),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Rating filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _ratingFilters.map((value) {
                            final isSelected = value == _selectedMinRating;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  value == null ? 'All' : '$value+ ⭐',
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(
                                    () =>
                                        _selectedMinRating =
                                            isSelected ? null : value,
                                  );
                                  _reload();
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_recentlyViewed.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🕐 Recently Viewed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await RecentlyViewedService.clear();
                            setState(() => _recentlyViewed = []);
                          },
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 170, // Tăng nhẹ chiều cao để ảnh hiển thị đẹp hơn
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _recentlyViewed.length,
                      itemBuilder: (_, index) {
                        final hotel = _recentlyViewed[index];
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HotelDetailPage(hotel: hotel),
                              ),
                            );
                            _loadRecentlyViewed(); // ✅ reload sau khi back
                          },
                          child: SizedBox(
                            width:
                                130, // Thu gọn bề ngang thẻ để trông thanh thoát hơn
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: Stack(
                                children: [
                                  // 1. Hình ảnh bo tròn
                                  // THAY THẾ PHẦN NÀY
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: hotel.thumbnailUrl ?? '',
                                      height: 170,
                                      width: 130,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) => Container(
                                            height: 170,
                                            width: 130,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.hotel,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                                    ),
                                  ),

                                  // 2. Lớp Gradient tối làm nền cho chữ
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black54,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // 3. Nội dung chữ
                                  Positioned(
                                    bottom: 12,
                                    left: 10,
                                    right: 10,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          hotel.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          hotel.city,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

          // HOTEL GRID + PAGINATION
          BlocBuilder<HotelCubit, HotelState>(
            builder: (context, state) {
              if (state is HotelLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is HotelError) {
                return SliverFillRemaining(
                  child: Center(child: Text(state.message)),
                );
              }

              if (state is HotelLoadedWithPagination) {
                final hotels = state.hotels;

                if (hotels.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No hotels found 🏨')),
                  );
                }

                return SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Grid 2 cột
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.65,
                            ),
                        itemCount: hotels.length,
                        itemBuilder:
                            (_, index) =>
                                _buildHotelCard(hotels[index], primaryColor),
                      ),

                      const SizedBox(height: 16),

                      // Pagination
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(state.totalPages, (index) {
                          final page = index + 1;
                          final isSelected = page == state.currentPage;

                          return GestureDetector(
                            onTap: () {
                              context.read<HotelCubit>().fetchHotels(
                                page: page,
                                minRating: _selectedMinRating,
                                city: _selectedCity,
                                keyword: _searchKeyword,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? primaryColor
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$page',
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }

              return const SliverToBoxAdapter();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(HotelEntity hotel, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HotelDetailPage(hotel: hotel)),
          );
          _loadRecentlyViewed(); // ✅ reload sau khi back từ detail
        },

        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                // THAY THẾ PHẦN NÀY
                // THAY THẾ PHẦN NÀY
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: hotel.thumbnailUrl ?? '',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[200],
                          height: 150,
                          child: const Icon(
                            Icons.hotel,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          hotel.starRating.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Info
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 11,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          hotel.city,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getMinPrice(hotel),
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // ✅ Thêm description vào đây
                  if (hotel.description != null &&
                      hotel.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      hotel.description!,
                      style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
