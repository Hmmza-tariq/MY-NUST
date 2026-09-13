# My NUST website

Static landing page, privacy policy and terms. No build step, analytics or cookies
added by this site. Screenshot artwork uses sample data.

Serve locally with any static server whose root is this directory. For example,
from the repository root: `ruby -run -e httpd site -p 8080`.

Deploy Hosting only (never database rules or other services):

```bash
firebase deploy --only hosting --config firebase.hosting.json --project nust---a-student-app --account thehexagone.contact@gmail.com
```

The configured Hosting site is `mynust`, for `https://mynust.web.app/`, under
the app's existing Firebase project. It was deployed on 13 September 2026 with
the Hexagone account above. Home, Privacy and Terms returned HTTP 200.
`nust.web.app` was unavailable because its name is reserved by another project.

The app's `.env`, `.env.example` and About link fallbacks now use
`https://mynust.web.app/privacy/` and `https://mynust.web.app/terms/`.
After future deployments, verify the three pages and images still return 200.

`node tool/preview_site.cjs` runs the local preview from the repository root.
`tool/check_site.cjs` uses Playwright to check all pages at three widths in both
themes. Set `SITE_ORIGIN=https://mynust.web.app` to run those checks against the
live site. Install Playwright in your development environment before running it.

The policies were drafted against the current source and Firebase privacy
documentation. Have the owner review the contact details, data practices and
legal wording before release. They are not a legal compliance certification.
