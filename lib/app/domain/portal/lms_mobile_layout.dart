/// Scoped presentation fixes for the official LMS's custom mobile header.
/// Leaves portal content, navigation and accessibility controls intact.
const lmsMobileLayoutScript = r'''
(function () {
  if (location.hostname !== 'lms.nust.edu.pk') return;
  var viewport = document.querySelector('meta[name="viewport"]');
  if (!viewport) {
    viewport = document.createElement('meta');
    viewport.name = 'viewport';
    document.head.appendChild(viewport);
  }
  viewport.content = 'width=device-width, initial-scale=1';
  var style = document.getElementById('mynust-mobile-layout');
  if (!style) {
    style = document.createElement('style');
    style.id = 'mynust-mobile-layout';
    document.head.appendChild(style);
  }
  style.textContent = `
    @media (max-width: 600px) {
      #main-header { height: auto !important; }
      #master-header, #master-header .master-header-inner,
      #master-header .master-header-inner-bg { height: auto !important; min-height: 64px; }
      #master-header .flexcols {
        display: flex !important; flex-wrap: wrap !important;
        align-items: center !important; gap: 8px !important; padding: 8px 0 !important;
        height: auto !important; min-height: 64px;
      }
      #master-header .logo-wrap { min-width: 0; flex: 1 1 calc(100% - 60px); }
      #master-header .main-logo img { max-width: 150px !important; height: auto !important; }
      #master-header .menu-toggle { margin-left: auto; position: static !important; transform: none !important; order: 1; min-width: 44px; }
      #master-header .mb2-archival-lms-btn { margin: 0 !important; order: 2; flex: 1 1 calc(50% - 4px); text-align: center; }
      #master-header .mb2-useful-links { order: 3; flex: 1 1 calc(50% - 4px); }
      #master-header .mb2-useful-links-toggle { width: 100%; }
      #master-header .mb2-server-time { order: 4; flex-basis: 100%; margin: 0 !important; font-size: 12px; color: #465465; }
      #master-header .mb2-useful-links { position: relative !important; margin: 0 !important; }
      #master-header .mb2-pb-btn { padding: 8px 12px !important; font-size: 14px !important; }
      #master-header .dropdown-menu { max-width: calc(100vw - 32px); }
      .chatbox-toggle-container { padding: 0 !important; right: 16px !important; bottom: 88px !important; }
      .chatbox-toggle { width: 48px !important; height: 48px !important; padding: 8px !important; border-radius: 50% !important; }
      .chatbox-toggle img { width: 28px !important; height: 28px !important; }
      .chatbox-toggle-text { display: none !important; }
      #chat-api-block { max-width: calc(100vw - 24px) !important; max-height: 70vh !important; }
      .block .card-text img { max-width: 100%; }
      .breadcrumb { flex-wrap: wrap; }
      .table-responsive { max-width: 100%; overflow-x: auto; }
    }
  `;
})();
''';
