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
    title: "Temukan Film Impianmu.",
    image: "assets/images/film.png",
    desc:
        "Jelajahi ribuan film dari berbagai genre. Dari drama menyentuh hingga action mendebarkan, semua ada di sini.",
  ),
  OnboardingContents(
    title: "Suaramu Berarti.",
    image: "assets/images/rating.png",
    desc:
        "Tulis review, beri rating, dan bantu pengguna lain menemukan film terbaik berikutnya.",
  ),
  OnboardingContents(
    title: "Watchlist film Pribadimu.",
    image: "assets/images/watchlist.png",
    desc:
        "Simpan film yang ingin kamu tonton. Rencana movie marathon akhir pekan? Semua tersimpan rapi!",
  ),
];
