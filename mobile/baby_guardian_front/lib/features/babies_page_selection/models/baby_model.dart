class BabyModel {
  final int id;
  final String name;

  // Optionnel: ton backend peut renvoyer ageMonths ou birthDate
  final int? ageMonths;
  final DateTime? birthDate;

  // Optionnel: icône selon genre (si tu l’as)
  final int? gender; // 0/1

  BabyModel({
    required this.id,
    required this.name,
    this.ageMonths,
    this.birthDate,
    this.gender, required String ageLabel,
  });

  factory BabyModel.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'] ?? json['babyId'] ?? json['baby_id'];
    final nameVal = json['name'] ?? json['fullName'] ?? json['firstName'] ?? 'Baby';

    DateTime? bd;
    final birth = json['birthDate'] ?? json['birth_date'] ?? json['dob'];
    if (birth != null) bd = DateTime.tryParse(birth.toString());

    int? months;
    final m = json['ageMonths'] ?? json['age_months'];
    if (m is int) months = m;
    if (m is num) months = m.toInt();
    if (m is String) months = int.tryParse(m);

    int? gender;
    final g = json['gender'] ?? json['sex'] ?? json['sexBin'];
    if (g is int) gender = g;
    if (g is num) gender = g.toInt();
    if (g is String) gender = int.tryParse(g);

    return BabyModel(
      id: (idVal as num).toInt(),
      name: nameVal.toString(),
      birthDate: bd,
      ageMonths: months,
      gender: gender, ageLabel: '',
    );
  }

  String get ageLabel {
    final m = ageMonths ?? _monthsFromBirthDate();
    if (m == null) return '—';
    if (m <= 1) return '1 month';
    return '$m months';
  }

  int? _monthsFromBirthDate() {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int months = (now.year - birthDate!.year) * 12 + (now.month - birthDate!.month);
    if (now.day < birthDate!.day) months -= 1;
    if (months < 0) months = 0;
    return months;
  }
}
