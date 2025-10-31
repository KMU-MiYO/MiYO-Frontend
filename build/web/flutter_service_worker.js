'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "4c3d3823d55b5fbd18427c74ad799d42",
"assets/AssetManifest.bin.json": "a433a1d01c90d47c776bba4f820e6804",
"assets/AssetManifest.json": "9afce47c98ff092a4ec77b6e268065bb",
"assets/assets/fonts/Pretendard-Black.otf": "de507f665f6ea63a94678e529b2a4ff0",
"assets/assets/fonts/Pretendard-Bold.otf": "f8a9b84216af5155ffe0e8661203f36f",
"assets/assets/fonts/Pretendard-ExtraBold.otf": "67e8e4773c05f2988c52dfe6ea337f33",
"assets/assets/fonts/Pretendard-Light.otf": "de308b576c70af4871d436e89918fdf6",
"assets/assets/fonts/Pretendard-Medium.otf": "13a352bd44156de92cce335ce93cd02d",
"assets/assets/fonts/Pretendard-Regular.otf": "84c0ea9d65324c758c8bd9686207afea",
"assets/assets/fonts/Pretendard-SemiBold.otf": "6fe301765c4f438e2034a0a47b609c61",
"assets/assets/icons/app_icon.png": "996b63ecca5180066aad9b44c93f30f8",
"assets/assets/icons/miyo_splashicon.png": "58372b8c36016309612b276630f89fd5",
"assets/assets/images/challenge_icons/Commercial.png": "1be94f91a1b21d288b37023d7d941c0d",
"assets/assets/images/challenge_icons/CultureArts.png": "fa1af5b12e8d0e8cd781bd3b59b6ba72",
"assets/assets/images/challenge_icons/EnvironSustain.png": "dbd45a1e7365c243ef1c1f0c7d78dc15",
"assets/assets/images/challenge_icons/Life.png": "c0b6194d6666588c6236cffce6880160",
"assets/assets/images/challenge_icons/NaturePark.png": "d06f6a55bac5e1bb915f099739aeed22",
"assets/assets/images/challenge_icons/NightLandscape.png": "ce9ed1b8a1b1ec0ea9203180d8bc8968",
"assets/assets/images/challenge_icons/Transport.png": "95fa066afdd96e9b7b794d984eeab207",
"assets/assets/images/medal_1.png": "78ed7f59f9c7bab2ad110e86eda0359d",
"assets/assets/images/medal_2.png": "7e834a92b72d9ee23960acea504441fd",
"assets/assets/images/medal_3.png": "cf19b0c20511abf9d23731b3988fdc98",
"assets/assets/images/miyo_logo.png": "e883e14e32fc6351347da24b844853f1",
"assets/assets/images/miyo_profile.png": "a6ed097c1d4bb1a185930795bec0ffb6",
"assets/assets/images/test1.png": "551e5f70305941397bf1c80ea37c59bd",
"assets/FontManifest.json": "b5d56181d7fc23fe9c4e220b58cc1e9a",
"assets/fonts/MaterialIcons-Regular.otf": "375937e5d8140c205b8617bc9e6bccc3",
"assets/NOTICES": "2d0848d609dbe6115c733af62b050640",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_naver_map/assets/font/Inter-fnm-scalebar-ss540.otf": "0dcd56f6f89392eb4a438991e0e4692d",
"assets/packages/flutter_naver_map/assets/icon/location_overlay_icon.png": "c18d8758d9d961b87fb1e8522e89dc66",
"assets/packages/flutter_naver_map/assets/icon/location_overlay_sub_icon.png": "cbcc0806d9a1e8c4b995f7ade0c3bcb9",
"assets/packages/flutter_naver_map/assets/icon/location_overlay_sub_icon_face.png": "7068b8f349f637d4f1e0403da60cd11b",
"assets/packages/flutter_naver_map/version.json": "d15b08d82524cddeffb5c6491ad397fc",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "4216fac920c316995abb3d7ac13ef7a3",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "b5fa63557545cc0dcadc89e08ce51bf3",
"/": "b5fa63557545cc0dcadc89e08ce51bf3",
"main.dart.js": "66073bda85239be566cd4c39c47b876d",
"manifest.json": "efcd7e2f12963de470f3db868f87ee2d",
"splash/img/dark-1x.png": "d05b99d9b3286a3b68ebad9271006dc2",
"splash/img/dark-2x.png": "8d0b337c54bab85811aa7edfe3a74579",
"splash/img/dark-3x.png": "91c205171555338831f7705c7a454131",
"splash/img/dark-4x.png": "5ba783dcc5845e8950cbf0bb71f43cf8",
"splash/img/light-1x.png": "d05b99d9b3286a3b68ebad9271006dc2",
"splash/img/light-2x.png": "8d0b337c54bab85811aa7edfe3a74579",
"splash/img/light-3x.png": "91c205171555338831f7705c7a454131",
"splash/img/light-4x.png": "5ba783dcc5845e8950cbf0bb71f43cf8",
"version.json": "d8e2795e2ad23846eee04d7a8c712bc3",
"webview_test.html": "e62bdb4a721c97983ba7d995f5875bca"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
