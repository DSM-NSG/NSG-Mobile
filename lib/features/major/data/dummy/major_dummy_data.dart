import 'package:nsg_mobile/features/share/domain/entities/post.dart';

const majorTrendingTopics = [
  (rank: 1, name: 'FE'),
  (rank: 2, name: 'Flutter'),
  (rank: 3, name: 'iOS'),
  (rank: 4, name: 'Design'),
  (rank: 5, name: 'BE'),
  (rank: 6, name: 'GO'),
  (rank: 7, name: 'HOME'),
  (rank: 8, name: 'tired'),
  (rank: 9, name: 'why'),
  (rank: 10, name: 'bomb'),
];

const majorSearchSuggestions = [
  'Swift',
  'Flutter',
  'iOS',
  'Android',
  'Design',
  'BE',
  'FE',
  'GO',
  'React',
  'Vue',
  'Angular',
  'Node',
  'Python',
  'Java',
  'Kotlin',
  'Snake',
  'Spider',
  'pineapples',
];

List<Post> _posts(String category, int count, int startId) => List.generate(
  count,
  (i) => Post(
    id: 'major_${startId + i}',
    title: 'Swift',
    content:
        'Swift Swift Swift Swift Swift Swift Swift Swift Swift Swift Swift Swift',
    category: category,
    likes: 99,
    comments: 99,
  ),
);

final dummyMajorPopularPosts = [..._posts('기숙사', 3, 1), ..._posts('장소', 2, 4)];

final dummyMajorRecentPosts = [
  ..._posts('기숙사', 4, 6),
  ..._posts('장소', 2, 10),
  ..._posts('대마고', 2, 12),
];
