enum PortalPhase { initializing, loading, ready, slow, offline, failed }

extension PortalPhaseX on PortalPhase {
  bool get isBusy =>
      this == PortalPhase.initializing || this == PortalPhase.loading;
  bool get showsPage =>
      this == PortalPhase.loading ||
      this == PortalPhase.ready ||
      this == PortalPhase.slow;
}
