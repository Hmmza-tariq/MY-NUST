import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/domain/downloads/downloaded_file_name.dart';

void main() {
  group('DownloadedFileName', () {
    test('matches the original downloader filename', () {
      expect(
        DownloadedFileName.matches(
          expected: 'semester-plan.pdf',
          actual: 'semester-plan.pdf',
        ),
        isTrue,
      );
    });

    test('matches Android MediaStore collision suffixes', () {
      expect(
        DownloadedFileName.matches(
          expected: 'semester-plan.pdf',
          actual: 'semester-plan (1).pdf',
        ),
        isTrue,
      );
      expect(
        DownloadedFileName.matches(
          expected: 'semester-plan.pdf',
          actual: 'semester-plan (12).PDF',
        ),
        isTrue,
      );
    });

    test('does not include unrelated personal downloads', () {
      expect(
        DownloadedFileName.matches(
          expected: 'semester-plan.pdf',
          actual: 'resume.pdf',
        ),
        isFalse,
      );
    });
  });
}
