class JanatyColors {
  static LightModeColors get light => LightModeColors();
  static DarkModeColors get dark => DarkModeColors();

  final int primary = 0xff0a2247;
  final int subhaListItemBg = 0;
  final int subhaLockBg = 0;
}

class DarkModeColors extends JanatyColors {
  @override
  int get subhaListItemBg => 0xffffc300;
  @override
  int get subhaLockBg => 0xff0a1b35;
}

class LightModeColors extends JanatyColors {
  @override
  int get subhaListItemBg => 0xffffffff;
  @override
  int get subhaLockBg => 0xffb3b3b3;
}
