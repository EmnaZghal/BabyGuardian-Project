class GuideStep {
  final String title;
  final String subtitle;
  final String imageAsset;
  final List<String> bullets;

  // CTA optionnel
  final String? primaryCtaText;
  final String? primaryCtaRoute;

  const GuideStep({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.bullets,
    this.primaryCtaText,
    this.primaryCtaRoute,
  });
}
