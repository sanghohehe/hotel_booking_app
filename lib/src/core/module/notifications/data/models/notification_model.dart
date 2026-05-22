class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'];
    final DateTime createdAt =
        (created is String) ? DateTime.parse(created) : (created as DateTime);

    final rawData = json['data'];
    Map<String, dynamic>? data;
    if (rawData is Map) data = Map<String, dynamic>.from(rawData);

    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      data: data,
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: createdAt,
    );
  }
}
