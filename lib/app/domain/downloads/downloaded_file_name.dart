class DownloadedFileName {
  const DownloadedFileName._();

  static bool matches({required String expected, required String actual}) {
    if (actual.toLowerCase() == expected.toLowerCase()) return true;
    final dot = expected.lastIndexOf('.');
    final stem = dot <= 0 ? expected : expected.substring(0, dot);
    final extension = dot <= 0 ? '' : expected.substring(dot);
    return RegExp(
      '^${RegExp.escape(stem)} \\([0-9]+\\)${RegExp.escape(extension)}\$',
      caseSensitive: false,
    ).hasMatch(actual);
  }
}
