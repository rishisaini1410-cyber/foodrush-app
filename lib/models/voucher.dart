class Voucher {
  final String id;
  final String title;
  final String code;
  final String discountText;
  final DateTime validUntil;
  final bool scratched;

  const Voucher({
    required this.id,
    required this.title,
    required this.code,
    required this.discountText,
    required this.validUntil,
    this.scratched = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'code': code,
        'discountText': discountText,
        'validUntil': validUntil.toIso8601String(),
        'scratched': scratched,
      };

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      code: json['code'] ?? '',
      discountText: json['discountText'] ?? '',
      validUntil:
          DateTime.tryParse(json['validUntil'] ?? '') ?? DateTime.now(),
      scratched: json['scratched'] == true,
    );
  }

  Voucher copyWith({bool? scratched}) {
    return Voucher(
      id: id,
      title: title,
      code: code,
      discountText: discountText,
      validUntil: validUntil,
      scratched: scratched ?? this.scratched,
    );
  }
}
