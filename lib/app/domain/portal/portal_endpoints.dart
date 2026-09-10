class PortalEndpoints {
  const PortalEndpoints._();

  static const lms = 'https://lms.nust.edu.pk/login/index.php';
  static const qalam = 'https://qalam.nust.edu.pk/';

  static String lmsFrom(String? configured) {
    final uri = Uri.tryParse(configured?.trim() ?? '');
    if (uri == null || uri.host.toLowerCase() != 'lms.nust.edu.pk') {
      return lms;
    }
    // The former /portal and /portal/my routes now return 404. This is the
    // current Moodle form action exposed by the official LMS home page.
    return lms;
  }

  static String qalamFrom(String? configured) {
    final uri = Uri.tryParse(configured?.trim() ?? '');
    if (uri == null || uri.host.toLowerCase() != 'qalam.nust.edu.pk') {
      return qalam;
    }
    // Start at the official root so server-side redirects remain current.
    return qalam;
  }
}
