WHITE LION SCHOOL MANAGEMENT SYSTEM — PROFESSIONAL EDITION
===========================================================

SAFE DEPLOYMENT
- This edition is published in the separate /professional/ folder.
- The existing live root application has not been replaced or overwritten.
- Test this version with sample data before using it for official school records.
- Keep the original HTML and JSON backups in a separate safe location.

OPEN ONLINE
https://koromaalhajiabu.github.io/white-lion-school-system/professional/

OFFLINE NOTES
- Open the hosted portal once while connected to the internet.
- Keep the app open long enough for the service worker to install and cache React.
- Then test airplane mode and reopen the hosted URL.
- Service workers require HTTPS or localhost; opening an HTML file directly from Downloads does not enable service workers.
- Records remain in this browser's local storage. Clearing site data or changing browsers/devices may make them unavailable. Export backups regularly.

IMPORTANT LIMITATION
This edition does not yet provide automatic multi-device data synchronization or production-grade authentication. GitHub Pages hosts static files and is not a shared database. Multi-device sync requires a secure backend, individual user authentication, school-scoped access rules, conflict handling, and tested restore procedures. Do not enter sensitive real student information until those protections are implemented.
