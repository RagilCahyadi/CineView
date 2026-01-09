class DummyDataFilm {
  final String title;
  final List<String> genre;
  final String image;
  final String year;
  final String rating;
  final String rated;
  final String duration;
  final String synopsis; 
  final String releaseDate;
  final String voteCount;
  final String ageRating;
  final List<Map<String, String>> cast;

  DummyDataFilm({
    required this.title,
    required this.genre,
    required this.image,
    required this.year,
    required this.rating,
    required this.rated,
    required this.duration,
    required this.synopsis,
    required this.releaseDate,
    required this.voteCount,
    required this.ageRating,
    required this.cast,
  });
}

List<DummyDataFilm> contents = [
  DummyDataFilm(
    title: "A Minecraft Movie",
    genre: ['Action', 'Fantasy'],
    image: "assets/images/avatar.jpg",
    year: "2025",
    rating: "5.9",
    rated: "PG",
    duration: "101",
    synopsis:
        "Four misfits are suddenly pulled through a mysterious portal into a bizarre, cubic wonderland.",
    releaseDate: "April 4 2025",
    voteCount: "79k",
    ageRating: "6+",
    cast: [
      {"name": "Jack Black", "image": "assets/images/avatar.jpg"},
      {"name": "Jason Momoa", "image": "assets/images/avatar.jpg"},
      {"name": "Emma Myers", "image": "assets/images/avatar.jpg"},
    ],
  ),
  DummyDataFilm(
    title: "Avatar 2",
    genre: ['Sci-Fi', 'Adventure'],
    image: "assets/images/avatar.jpg",
    year: "2024",
    rating: "8.5",
    rated: "PG-13",
    duration: "192",
    synopsis:
        "Jake Sully lives with his newfound family formed on the extrasolar moon Pandora.",
    releaseDate: "December 16 2024",
    voteCount: "150k",
    ageRating: "13+",
    cast: [
      {"name": "Sam Worthington", "image": "assets/images/avatar.jpg"},
      {"name": "Zoe Saldana", "image": "assets/images/avatar.jpg"},
      {"name": "Sigourney Weaver", "image": "assets/images/avatar.jpg"},
    ],
  ),
  DummyDataFilm(
    title: "The Batman",
    genre: ['Action', 'Crime', 'Drama'],
    image: "assets/images/avatar.jpg",
    year: "2024",
    rating: "9.0",
    rated: "PG-13",
    duration: "176",
    synopsis:
        "When a sadistic serial killer begins murdering key political figures in Gotham, Batman is forced to investigate.",
    releaseDate: "March 4 2024",
    voteCount: "200k",
    ageRating: "13+",
    cast: [
      {"name": "Robert Pattinson", "image": "assets/images/avatar.jpg"},
      {"name": "Zoë Kravitz", "image": "assets/images/avatar.jpg"},
      {"name": "Paul Dano", "image": "assets/images/avatar.jpg"},
    ],
  ),
  DummyDataFilm(
    title: "Dune Part Two",
    genre: ['Sci-Fi', 'Adventure'],
    image: "assets/images/avatar.jpg",
    year: "2024",
    rating: "8.8",
    rated: "PG-13",
    duration: "166",
    synopsis:
        "Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.",
    releaseDate: "March 1 2024",
    voteCount: "180k",
    ageRating: "13+",
    cast: [
      {"name": "Timothée Chalamet", "image": "assets/images/avatar.jpg"},
      {"name": "Zendaya", "image": "assets/images/avatar.jpg"},
      {"name": "Rebecca Ferguson", "image": "assets/images/avatar.jpg"},
    ],
  ),
  DummyDataFilm(
    title: "Spider-Man: No Way Home",
    genre: ['Action', 'Adventure'],
    image: "assets/images/avatar.jpg",
    year: "2024",
    rating: "8.7",
    rated: "PG-13",
    duration: "148",
    synopsis:
        "With Spider-Man's identity now revealed, Peter asks Doctor Strange for help. When a spell goes wrong, dangerous foes from other worlds start to appear.",
    releaseDate: "December 17 2024",
    voteCount: "250k",
    ageRating: "13+",
    cast: [
      {"name": "Tom Holland", "image": "assets/images/avatar.jpg"},
      {"name": "Zendaya", "image": "assets/images/avatar.jpg"},
      {"name": "Benedict Cumberbatch", "image": "assets/images/avatar.jpg"},
    ],
  ),
];
