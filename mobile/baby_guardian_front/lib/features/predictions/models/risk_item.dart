class RiskItem {
  final String label;
  final double score; // 0..1 ou % selon ton backend
  final String? details;

  RiskItem({
    required this.label,
    required this.score,
    this.details,
  });

  factory RiskItem.fromJson(Map<String, dynamic> json) {
    return RiskItem(
      label: (json['label'] ?? json['name'] ?? json['risk'] ?? '').toString(),
      score: _toDouble(json['score'] ?? json['value'] ?? json['probability'] ?? 0),
      details: json['details']?.toString(),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
