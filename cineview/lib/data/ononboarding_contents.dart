class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Review Jujur.",
    image: "assets/images/Rating.png",
    desc:
        "Baca ulasan otentik dari komunitas pecinta film sebelum kamu memutuskan untuk menonton.",
  ),
  OnboardingContents(
    title: "Share Opinimu.",
    image: "assets/images/Rating.png",
    desc:
        "Jadilah kritikus. Berikan rating, tulis ulasan, dan diskusikan plot twist favoritmu.",
  ),
  OnboardingContents(
    title: "Atur Watchlist.",
    image: "assets/images/Rating.png",
    desc:
        "Simpan film yang ingin ditonton nanti. Jangan pernah ketinggalan film-film terbaik.",
  ),
];
