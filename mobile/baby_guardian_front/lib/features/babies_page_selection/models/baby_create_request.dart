class BabyCreateRequest {
  final String firstName;
  final int gender;
  final String birthDate; // yyyy-MM-dd
  final double gestationalAgeWeeks;
  final double weightKg;

  const BabyCreateRequest({
    required this.firstName,
    required this.gender,
    required this.birthDate,
    required this.gestationalAgeWeeks,
    required this.weightKg,
  });

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "gender": gender,
        "birthDate": birthDate,
        "gestationalAgeWeeks": gestationalAgeWeeks,
        "weightKg": weightKg,
      };
}
