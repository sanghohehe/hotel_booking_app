import 'package:flutter/material.dart';
import '../../../hotel/data/hotel_api.dart';
import '../../../hotel/data/models/hotel_model.dart';
import '../../data/favorite_api.dart';
import '../../../hotel/presentation/pages/hotel_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _favoriteApi = FavoriteApi();
  final _hotelApi = HotelApi();
  late Future<List<HotelModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadFavoriteHotels();
  }

  Future<List<HotelModel>> _loadFavoriteHotels() async {
    final favIds = await _favoriteApi.getMyFavoriteHotelIds();
    if (favIds.isEmpty) return [];
    return _hotelApi.getHotelsByIds(favIds.toList());
  }

  void _reload() {
    setState(() {
      _future = _loadFavoriteHotels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _reload(),
          child: FutureBuilder<List<HotelModel>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildEmptyState('Lỗi: ${snapshot.error}');
              }

              final hotels = snapshot.data ?? [];
              if (hotels.isEmpty) {
                return _buildEmptyState('Bạn chưa yêu thích khách sạn nào.');
              }

              return ListView.separated(
                // Để padding top nhỏ (ví dụ 10) để sát với khu vực Favorites phía trên
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                itemCount: hotels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final hotel = hotels[index];
                  return _buildCard(context, hotel, theme);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, HotelModel hotel, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => HotelDetailPage(hotel: hotel.toEntity()),
              ),
            )
            .then((_) => _reload());
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        child: SizedBox(
          height: 110,
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child:
                    hotel.thumbnailUrl != null
                        ? Image.network(hotel.thumbnailUrl!, fit: BoxFit.cover)
                        : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.hotel),
                        ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hotel.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${hotel.city} • ${hotel.address}',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hotel.starRating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Center(
            child: Text(message, style: const TextStyle(color: Colors.grey)),
          ),
        ),
      ],
    );
  }
}
