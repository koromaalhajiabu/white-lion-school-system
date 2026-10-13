'use strict';
/* White Lion Professional Edition. First open while online so React can be cached. */
const CACHE_NAME = 'white-lion-professional-shell-v1';
const APP_BASE = new URL('./', self.location.href);
const LOCAL_ASSETS = [
  new URL('index.html', APP_BASE).href,
  new URL('manifest.webmanifest', APP_BASE).href,
  new URL('icon.svg', APP_BASE).href
];
const CDN_ASSETS = [
  'https://cdnjs.cloudflare.com/ajax/libs/react/18.3.1/umd/react.production.min.js',
  'https://cdnjs.cloudflare.com/ajax/libs/react-dom/18.3.1/umd/react-dom.production.min.js'
];
self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    await cache.addAll(LOCAL_ASSETS);
    await Promise.all(CDN_ASSETS.map(async url => {
      try {
        const response = await fetch(url, {mode:'cors', cache:'reload'});
        if (response.ok) await cache.put(url, response.clone());
      } catch (_) { /* first visit needs internet; retry when scripts are requested online */ }
    }));
    await self.skipWaiting();
  })());
});
self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter(key => key.startsWith('white-lion-professional-') && key !== CACHE_NAME).map(key => caches.delete(key)));
    await self.clients.claim();
  })());
});
self.addEventListener('fetch', event => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  const isCdnScript = CDN_ASSETS.includes(url.href);
  const isAppNavigation = request.mode === 'navigate' && url.origin === self.location.origin;
  if (!isCdnScript && !isAppNavigation && url.origin !== self.location.origin) return;
  event.respondWith((async () => {
    const cache = await caches.open(CACHE_NAME);
    const cached = await cache.match(request) || await cache.match(url.href);
    if (cached) {
      if (isCdnScript || isAppNavigation) {
        fetch(request).then(response => { if (response && response.ok) cache.put(request, response.clone()); }).catch(() => {});
      }
      return cached;
    }
    try {
      const response = await fetch(request);
      if (response && response.ok && (isCdnScript || url.origin === self.location.origin)) await cache.put(request, response.clone());
      return response;
    } catch (error) {
      if (isAppNavigation) {
        const fallback = await cache.match(new URL('index.html', APP_BASE).href);
        if (fallback) return fallback;
      }
      throw error;
    }
  })());
});