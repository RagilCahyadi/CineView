import 'package:cineview/data/models/dummy_data_film.dart';

class DummyDataActor {
  final String firstName;
  final String lastName;
  final String image;
  final String biography;
  final String birthDate;
  final String birthPlace;
  final List<DummyDataFilm> movies;

  DummyDataActor({
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.biography,
    required this.birthDate,
    required this.birthPlace,
    required this.movies,
  });

  // Getter untuk nama lengkap
  String get fullName => '$firstName $lastName';
}

// Daftar aktor dummy
List<DummyDataActor> actors = [
  DummyDataActor(
    firstName: 'Robert',
    lastName: 'Downey Jr.',
    image: 'assets/images/avatar.jpg',
    biography:
        'Robert John Downey Jr. adalah aktor dan produser Amerika yang karirnya telah mencakup lebih dari lima dekade. Dia mulai berakting sebagai anak-anak dan menjadi terkenal dengan perannya sebagai Tony Stark / Iron Man dalam Marvel Cinematic Universe.',
    birthDate: 'April 4, 1965',
    birthPlace: 'Manhattan, New York, USA',
    movies: contents.take(4).toList(),
  ),
  DummyDataActor(
    firstName: 'Scarlett',
    lastName: 'Johansson',
    image: 'assets/images/avatar.jpg',
    biography:
        'Scarlett Ingrid Johansson adalah aktris dan penyanyi Amerika. Dia adalah salah satu aktris dengan bayaran tertinggi di dunia dan telah tampil dalam berbagai film Hollywood blockbuster.',
    birthDate: 'November 22, 1984',
    birthPlace: 'New York City, USA',
    movies: contents.take(3).toList(),
  ),
  DummyDataActor(
    firstName: 'Chris',
    lastName: 'Hemsworth',
    image: 'assets/images/avatar.jpg',
    biography:
        'Christopher Hemsworth adalah aktor Australia. Dia dikenal karena perannya sebagai Thor dalam Marvel Cinematic Universe dan telah membintangi berbagai film action dan drama.',
    birthDate: 'August 11, 1983',
    birthPlace: 'Melbourne, Victoria, Australia',
    movies: contents.take(5).toList(),
  ),
  DummyDataActor(
    firstName: 'Zendaya',
    lastName: 'Coleman',
    image: 'assets/images/avatar.jpg',
    biography:
        'Zendaya Maree Stoermer Coleman adalah aktris dan penyanyi Amerika. Dia dikenal karena perannya dalam serial Euphoria dan film Spider-Man sebagai MJ.',
    birthDate: 'September 1, 1996',
    birthPlace: 'Oakland, California, USA',
    movies: contents.take(4).toList(),
  ),
  DummyDataActor(
    firstName: 'Tom',
    lastName: 'Holland',
    image: 'assets/images/avatar.jpg',
    biography:
        'Thomas Stanley Holland adalah aktor Inggris. Dia paling dikenal karena perannya sebagai Spider-Man dalam Marvel Cinematic Universe.',
    birthDate: 'June 1, 1996',
    birthPlace: 'Kingston upon Thames, England',
    movies: contents.take(5).toList(),
  ),
];
