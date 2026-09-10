enum PortalNavigationKind { page, download, external, unsupported }

class PortalUrlClassifier {
  const PortalUrlClassifier._();

  static const _downloadExtensions = {
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'csv',
    'zip',
    'jpg',
    'jpeg',
    'png',
  };

  static bool isDownload(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    if (uri.scheme == 'blob' || uri.scheme == 'data') return true;
    final segment = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
    final dot = segment.lastIndexOf('.');
    return dot >= 0 &&
        _downloadExtensions.contains(segment.substring(dot + 1).toLowerCase());
  }

  static bool isAllowedPage(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return false;
    }
    final host = uri.host.toLowerCase();
    return host == 'nust.edu.pk' ||
        host.endsWith('.nust.edu.pk') ||
        host == 'app.kuickpay.com';
  }

  static PortalNavigationKind classify(String value) {
    if (isDownload(value)) return PortalNavigationKind.download;
    final uri = Uri.tryParse(value);
    if (uri == null) return PortalNavigationKind.unsupported;
    if (isAllowedPage(value)) return PortalNavigationKind.page;
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      return PortalNavigationKind.external;
    }
    return PortalNavigationKind.unsupported;
  }
}
