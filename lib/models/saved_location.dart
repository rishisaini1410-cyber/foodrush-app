class SavedLocation {
  final String id;
  final String label;
  final String address;
  final String? landmark;
  final bool isDefault;

  const SavedLocation({
    required this.id,
    required this.label,
    required this.address,
    this.landmark,
    this.isDefault = false,
  });

  String get displayLine =>
      landmark != null && landmark!.isNotEmpty ? '$address • $landmark' : address;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'address': address,
        'landmark': landmark,
        'isDefault': isDefault,
      };

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['id'] ?? '',
      label: json['label'] ?? 'Saved',
      address: json['address'] ?? '',
      landmark: json['landmark'],
      isDefault: json['isDefault'] == true,
    );
  }

  SavedLocation copyWith({
    String? label,
    String? address,
    String? landmark,
    bool? isDefault,
  }) {
    return SavedLocation(
      id: id,
      label: label ?? this.label,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
