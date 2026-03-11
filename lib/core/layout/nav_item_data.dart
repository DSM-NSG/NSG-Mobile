import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';

class NavItemData {
  final Widget icon;
  final Widget activeIcon;
  final String label;

  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

SvgPicture _svgIcon(String path, Color color) => SvgPicture.asset(
  path,
  width: 24,
  height: 24,
  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
);

final List<NavItemData> bottomNavItems = [
  const NavItemData(
    icon: Icon(
      Symbols.location_on,
      fill: 1,
      color: NsgColor.black400,
      size: 24,
    ),
    activeIcon: Icon(
      Symbols.location_on,
      fill: 1,
      color: NsgColor.orange400,
      size: 24,
    ),
    label: '지도',
  ),
  NavItemData(
    icon: _svgIcon('assets/svg/write_icon.svg', NsgColor.black400),
    activeIcon: _svgIcon('assets/svg/write_icon.svg', NsgColor.orange400),
    label: '작성',
  ),
  NavItemData(
    icon: _svgIcon('assets/svg/share_icon.svg', NsgColor.black400),
    activeIcon: _svgIcon('assets/svg/share_icon.svg', NsgColor.orange400),
    label: '공유',
  ),
  NavItemData(
    icon: _svgIcon('assets/svg/major_icon.svg', NsgColor.black400),
    activeIcon: _svgIcon('assets/svg/major_icon.svg', NsgColor.orange400),
    label: '전공',
  ),
  const NavItemData(
    icon: Icon(Symbols.person, fill: 1, color: NsgColor.black400, size: 24),
    activeIcon: Icon(
      Symbols.person,
      fill: 1,
      color: NsgColor.orange400,
      size: 24,
    ),
    label: '마이페이지',
  ),
];
