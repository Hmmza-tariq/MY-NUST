# Security and public-source guidance

Report security concerns privately to **HexagonePk@gmail.com**. Describe the affected version, reproduction steps and impact. Do not send portal passwords, session cookies, private academic records, signing credentials or identifiable screenshots. Public GitHub issues should contain redacted technical details only.

## Client configuration and secrets

The distributed mobile app includes its `.env` asset. Values in a client binary can be extracted; they must not be treated as privileged server secrets. The local file, signing keys, account settings and device captures are excluded from Git. Copy `.env.example` for a fork and configure your own Firebase project, local preferences key and signing setup.

The bundled local-preferences key does not provide the same protection as a per-device key protected by the operating system. Local encryption cannot guarantee protection on a compromised device, and platform backups can retain copies.

Firebase client API keys and app/project identifiers are public configuration, not authorization to read protected data. Apply appropriate Firebase Security Rules, access controls and API restrictions for your deployment; the presence of a client key is not proof that those controls have been reviewed. Never commit service-account private keys or signing passwords.

## Connections and analytics

Android 3.0.3 denies cleartext traffic, trusts system certificate authorities and enables downloader certificate validation. In-app portal and native download entry points require HTTPS and reject URLs with embedded credentials. iOS source explicitly retains App Transport Security; iOS release validation is separate. External applications handle links opened outside the app.

Analytics is disabled until opt-in. Advertising consent remains denied and Android advertising identifier permissions are excluded. The central service permits only fixed events, values and screen names; it excludes credentials, academic values and private content. With consent, Firebase can derive approximate location from IP addresses and process the disclosed app/device and interaction information. The privacy policy describes support correspondence and direct portal traffic separately.

## Release checks

Review the staged diff and run a secret scanner before public pushes. Manually review findings and all new text, binary assets and archives. Use sample data for public screenshots. Keep private plans, correspondence, device backups and build artifacts outside the public commit. Scanner results and a successful build do not prove the absence of every vulnerability or leaked value.

Run the checks in [the testing runbook](docs/TESTING_AND_RELEASE.md), review [analytics disclosures](docs/ANALYTICS.md), and verify the live privacy policy before distribution. Portal authorization, live Firebase/GA4 configuration, Play Data Safety and store acceptance need their own review.
