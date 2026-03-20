import 'package:nsg_mobile/features/share/domain/entities/post.dart';

const shareCategories = ['장소', '기숙사', '대마고', '기타'];

List<Post> _posts(String category, int count, int startId) => List.generate(
      count,
      (i) => Post(
        id: '${startId + i}',
        title: '화장실 변기가 막혔다고요???  당장 들어오세요',
        content:
            '화장실 변기가 너무 자주 막히시죠?? 그래서 제가 오늘 끊어왔습니다~~~ 변기를 잘 뚫는 법 ~!! 끼얏호~',
        category: category,
        likes: 99,
        comments: 99,
      ),
    );

final dummyPopularPosts = [
  ..._posts('장소', 3, 1),
  ..._posts('기숙사', 3, 4),
  ..._posts('대마고', 2, 7),
  ..._posts('기타', 2, 9),
];

final dummyRecentPosts = [
  ..._posts('기숙사', 3, 11),
  ..._posts('장소', 3, 14),
  ..._posts('기타', 2, 17),
  ..._posts('대마고', 2, 19),
];
