# White Lion Multi-School Enterprise System

This package contains the existing school-management HTML app plus Progressive Web App (PWA) files to make the hosted site installable and cache its core files for offline opening.

## Included files
- `index.html` — the school-management application.
- `manifest.json` — installable-app metadata.
- `sw.js` — service worker for caching the app shell.
- `icons/icon.svg` — app icon.

## Important limitations to understand
1. **Offline cache:** The PWA cache works when served from HTTPS (for example, GitHub Pages) or localhost. Opening the HTML directly as a file does not allow service-worker installation. Browser local storage keeps records on that device/browser.
2. **No automatic cloud sync yet:** This package does not connect school data between devices. A GitHub Pages deployment hosts the application; it does not provide a database or secure user authentication. Cross-device sync needs a configured backend (for example, Firebase or Supabase), school/tenant IDs, authentication, and database access rules.
3. **Local PIN is not enterprise security:** The existing app's PIN and browser storage are local-only and should not be used to protect sensitive real student data on shared devices. Change the default PIN before testing, and use dummy data until a secure backend is implemented.
4. **Back up data:** Use the app's export/backup function regularly. Backups are JSON files and should be stored securely.

## Deploy using GitHub Pages (Android-friendly steps)
1. Extract this ZIP on your phone or computer.
2. Open your GitHub repository, choose **Add file → Upload files**, and upload the contents of this folder (not the ZIP itself). Make sure `index.html`, `manifest.json`, `sw.js`, and `icons/` are at the repository root.
3. Commit the files.
4. In the repository, open **Settings → Pages**. Select **Deploy from a branch**, choose the main branch and `/ (root)`, then Save.
5. Wait for GitHub Pages to publish, then open the provided HTTPS site link.
6. In Chrome on Android, use the browser menu and choose **Install app** or **Add to Home screen** if available.
7. Open the site once while online so the service worker can cache the app shell. Then test opening it again with internet off.

## Next step for true online/offline multi-device use
Configure a backend with real user sign-in, separate school IDs, database security rules, conflict handling, and sync status. Do not put service-account keys or private secrets in frontend files. Until this is completed, each device/browser stores its own records.
