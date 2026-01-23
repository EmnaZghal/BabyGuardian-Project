class BabyCreateResponse {
  final String babyId;

  const BabyCreateResponse({required this.babyId});

  factory BabyCreateResponse.fromJson(Map<String, dynamic> json) {
    return BabyCreateResponse(
      babyId: (json['babyId'] ?? '').toString(),
    );
  }
}