import 'package:nsg_mobile/features/share/domain/entities/comment.dart';
import 'package:nsg_mobile/features/share/domain/entities/post_detail.dart';

const currentUserName = '정지윤';
const currentUserGeneration = '10기';

const _content =
    '여러분 학교 폭파시키고 싶지 않으세요?? 그래서 제가 생각해본 방법이 있는데요 일단 방학식 날이나 졸업식 날에 집을 갔다가 폭탄을 들고 와서 학교에 설치하고 한번에 날려버리는거에요';

const _defaultComments = [
  Comment(
    id: 'c1',
    authorName: '정지윤',
    generation: '10기',
    content: '정말 좋아요 저도 동참할래요',
  ),
  Comment(
    id: 'c2',
    authorName: '익명1',
    content: '와 이런 생각을??',
  ),
  Comment(
    id: 'c3',
    authorName: '익명1',
    content: '와 이런 생각을??',
    parentId: 'c2',
  ),
];

const _ownPostIds = {'7', '14', '19'};

const _imagePostIds = {'1', '11'};

PostDetail getPostDetail(String id) {
  return PostDetail(
    id: id,
    title: '화장실 변기가 막혔다고요??? 당장 들어오세요',
    content: _content,
    category: '장소',
    authorName: _ownPostIds.contains(id) ? currentUserName : '익명2',
    generation: _ownPostIds.contains(id) ? currentUserGeneration : null,
    isOwn: _ownPostIds.contains(id),
    likes: 99,
    imagePath: _imagePostIds.contains(id) ? 'assets/svg/place_write.png' : null,
    commentList: _defaultComments,
  );
}
