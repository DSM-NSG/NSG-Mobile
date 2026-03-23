import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/features/write/domain/entities/write_category.dart';

const writeCategories = [
  WriteCategory(
    label: '장소\n공유하기',
    icon: Symbols.person_pin,
    route: '/write/place',
    imagePath: 'assets/svg/place_write.png',
  ),
  WriteCategory(
    label: '기숙사 꿀팁\n공유하기',
    icon: Symbols.bed,
    route: '/write/dormitory',
    imagePath: 'assets/svg/dorm_write.png',
  ),
  WriteCategory(
    label: '대마고 꿀팁\n공유하기',
    icon: Symbols.school,
    route: '/write/school',
    imagePath: 'assets/svg/school_write.png',
  ),
  WriteCategory(
    label: '기타 꿀팁\n공유하기',
    icon: Symbols.local_fire_department,
    route: '/write/etc',
    imagePath: 'assets/svg/etc_write.png',
  ),
  WriteCategory(
    label: '전공 꿀팁\n공유하기',
    icon: Symbols.laptop_mac,
    route: '/write/major',
    imagePath: 'assets/svg/major_write.png',
  ),
];
