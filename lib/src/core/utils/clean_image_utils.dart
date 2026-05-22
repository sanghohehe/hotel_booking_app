class CleanImageUtils {
  static String cleanUrl(String url) {
    return url.trim().replaceAll('\n', '').replaceAll(' ', '');
  }

  static List<String> cleanUrlList(List<String> urls) {
    return urls
        .map((e) => cleanUrl(e))
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static List<String> safeToArray(dynamic data) {
    if (data == null) return [];
    if (data is List) return cleanUrlList(data.map((e) => e.toString()).toList());
    if (data is String) return [cleanUrl(data)];
    return [];
  }
}