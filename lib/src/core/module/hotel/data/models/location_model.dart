class LocationModel {
  final String name;
  final List<LocationModel> children;

  LocationModel({required this.name, this.children = const []});

  factory LocationModel.fromJson(Map<String, dynamic> json, String type) {

    var childrenJson = (type == 'province') ? json['districts'] : json['wards'];
    return LocationModel(
      name: json['name'],
      children: childrenJson != null 
          ? (childrenJson as List).map((i) => LocationModel.fromJson(i, type == 'province' ? 'district' : 'ward')).toList()
          : [],
    );
  }
}