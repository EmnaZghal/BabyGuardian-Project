class BabyListItem {
  final int id;
  final String name;
  final String ageLabel;
  final int? gender;

  BabyListItem({
    required this.id,
    required this.name,
    required this.ageLabel,
    this.gender,
  });

  factory BabyListItem.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'] ?? json['babyId'] ?? json['baby_id'] ?? 0;
    final nameVal = json['name'] ?? json['fullName'] ?? 'Baby';

    // essaye ageMonths puis sinon "age" string
    final months = json['ageMonths'] ?? json['age_months'];
    String ageLabel = '—';
    if (months is int) ageLabel = '$months months';
    if (months is num) ageLabel = '${months.toInt()} months';
    if (months is String && int.tryParse(months) != null) {
      ageLabel = '${int.parse(months)} months';
    }
    if (json['age'] != null) ageLabel = json['age'].toString();

    int? gender;
    final g = json['gender'] ?? json['sex'] ?? json['sexBin'];
    if (g is int) gender = g;
    if (g is num) gender = g.toInt();
    if (g is String) gender = int.tryParse(g);

    return BabyListItem(
      id: (idVal as num).toInt(),
      name: nameVal.toString(),
      ageLabel: ageLabel,
      gender: gender,
    );
  }
}
