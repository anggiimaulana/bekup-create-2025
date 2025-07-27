enum ThemeState {
  lightTheme,
  darkTheme;

  bool get isLight => this == ThemeState.lightTheme;
}

extension BoolExtension on bool {
  ThemeState get isLight =>
      this == true ? ThemeState.lightTheme : ThemeState.darkTheme;
}
