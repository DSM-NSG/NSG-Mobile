import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/features/write/domain/entities/write_category.dart';

const writeCategories = [
  WriteCategory(
    label: '장소\n공유하기',
    icon: Symbols.person_pin,
    route: '/write/place',
  ),
  WriteCategory(
    label: '기숙사 꿀팁\n공유하기',
    icon: Symbols.bed,
    route: '/write/dormitory',
  ),
  WriteCategory(
    label: '대마고 꿀팁\n공유하기',
    icon: Symbols.school,
    route: '/write/school',
  ),
  WriteCategory(
    label: '기타 꿀팁\n공유하기',
    icon: Symbols.local_fire_department,
    route: '/write/etc',
  ),
  WriteCategory(
    label: '전공 꿀팁\n공유하기',
    icon: Symbols.laptop_mac,
    route: '/write/major',
  ),
];
