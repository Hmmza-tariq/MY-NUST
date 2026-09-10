import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/domain/portal/portal_url_classifier.dart';
import 'package:nust/app/domain/portal/portal_endpoints.dart';

void main() {
  group('PortalUrlClassifier', () {
    test('allows NUST subdomains and Kuickpay', () {
      expect(
        PortalUrlClassifier.classify('https://qalam.nust.edu.pk/student'),
        PortalNavigationKind.page,
      );
      expect(
        PortalUrlClassifier.classify('https://app.kuickpay.com/pay'),
        PortalNavigationKind.page,
      );
    });

    test('detects documents with query parameters and mixed case', () {
      expect(
        PortalUrlClassifier.classify(
          'https://qalam.nust.edu.pk/invoice/Challan.PDF?token=abc',
        ),
        PortalNavigationKind.download,
      );
    });

    test('detects generated blob and data downloads', () {
      expect(
        PortalUrlClassifier.isDownload('blob:https://qalam.nust.edu.pk/1'),
        isTrue,
      );
      expect(
        PortalUrlClassifier.isDownload('data:application/pdf;base64,AA=='),
        isTrue,
      );
    });

    test('classifies third-party web links as external', () {
      expect(
        PortalUrlClassifier.classify('https://example.com/help'),
        PortalNavigationKind.external,
      );
    });

    test('rejects unsafe custom schemes', () {
      expect(
        PortalUrlClassifier.classify('javascript:alert(1)'),
        PortalNavigationKind.unsupported,
      );
    });
  });

  group('PortalEndpoints', () {
    test('replaces the retired LMS portal route with the current login', () {
      expect(
        PortalEndpoints.lmsFrom('https://lms.nust.edu.pk/portal/my'),
        'https://lms.nust.edu.pk/login/index.php',
      );
    });

    test('starts Qalam at its server-managed root', () {
      expect(
        PortalEndpoints.qalamFrom(
          'https://qalam.nust.edu.pk/student/profile',
        ),
        'https://qalam.nust.edu.pk/',
      );
    });
  });
}
