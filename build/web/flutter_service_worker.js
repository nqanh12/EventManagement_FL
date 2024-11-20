'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "4c29d041f16fed5f6261caf0b194fe34",
"assets/AssetManifest.bin.json": "5861f4b5753d9406522c47790b96bb28",
"assets/AssetManifest.json": "653aa874b8e09d57c42002f3e898d789",
"assets/assets/images/add.png": "18e5fbcdff99a375ce8488514243b693",
"assets/assets/images/avatar.png": "f38ce2c473c23864c5d5ba870415548e",
"assets/assets/images/background.png": "3563685fb944a1e15ebf1b737171cf84",
"assets/assets/images/confirm.png": "b047408d033324832459ced05d20f3e7",
"assets/assets/images/delete.png": "b8fb3571b71a371cf468eddd6aaf25ca",
"assets/assets/images/edit.png": "e8995fb64d3a61af7ba3e2df93025f0a",
"assets/assets/images/importExcel.png": "816af0706e7c0936ac0776e702a7bacd",
"assets/assets/images/logo.png": "0f4e359035a4f63761590b5ca723508e",
"assets/assets/images/person.png": "383672ed5f5b3b386d14a094dc3a4222",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "a80360f5e89ec8b54143c722e9995c88",
"assets/lib/Component/button_access.dart": "d501fc5b0916951f194a52b882040b28",
"assets/lib/Component/button_crud.dart": "45ad89603812e49de0fbbb11d1e3d720",
"assets/lib/Component/decription_text.dart": "4819fe22c781f982b817bfd6afbf1d13",
"assets/lib/Component/decription_text.dart~": "dbc60d4e89863a6522aee8a3c702bfcc",
"assets/lib/Component/diglog_load.dart": "be2fe70bc41cd12fcdca7e41e5fa61c0",
"assets/lib/Component/diglog_warning.dart": "902e60f233cb4aebfc1960ca4da3501e",
"assets/lib/Component/diglog_warning.dart~": "be2e864ea21cde98b3b1703512dc4b94",
"assets/lib/Component/event_card.dart": "a54922a92a1de8483fbea4a268bb5e41",
"assets/lib/Component/form_add_account.dart": "de2afa29adafb347f9a9063c2331cfc8",
"assets/lib/Component/form_add_event.dart": "2bf67cdd87ad1d71255ced1686c86f07",
"assets/lib/Component/form_CR.dart~": "00c5b99c6129ed706e39d17107d9dd55",
"assets/lib/Component/form_edit_event.dart": "4c591ddc5df108252fb94e997f76fc2b",
"assets/lib/Component/form_edit_role.dart": "43162a46a11f66e23066d95b29a5fca9",
"assets/lib/Component/form_type.dart": "c9f29da01f23197e145418d86bf00e26",
"assets/lib/Component/icon_crud.dart": "77d9df564e84289924e763e56b674b86",
"assets/lib/Component/listtile.dart": "9bc8c9341e78aa4513d580247e9f90d7",
"assets/lib/Component/logout.dart": "382d36e74e7ae819cef59cbdf423900f",
"assets/lib/Component/search_event.dart": "f90d839a4fe7112c09c65e531212e249",
"assets/lib/Component/search_user.dart": "3e575154496906a018484f7c0a62d7a0",
"assets/lib/Component/search_user.dart~": "1bd2114a96d36b2c2e6606ac593d7089",
"assets/lib/Component/summary_card.dart": "a2a05f2e264879cda69d9cd172b34cbb",
"assets/lib/Component/text_field.dart": "fbd8d16c232cff0b19ee2d547b5a984e",
"assets/lib/Component/text_font_family.dart": "e32f30db04c9f44772149045111768c9",
"assets/lib/Component/text_font_list.dart": "8e0450c7d1cfd3a53cc59b3f4462e368",
"assets/lib/Service/crud_account_service.dart": "6fb8fc8e2a8c80170bf6077df2ae1957",
"assets/lib/Service/crud_event_service.dart": "fcc4cf59f347440d6ef725235714e8de",
"assets/lib/Service/event_service.dart": "1549050461bc4261617a53cf021e8220",
"assets/lib/Service/event_service.dart~": "d0e0a0765fbae623e3fc00ff784454ae",
"assets/lib/Service/excel_service.dart": "27f4330755f719c4e9146d2c0bbce8ea",
"assets/lib/Service/info_account.dart": "ce3d4638425eb5dd5866fd551221e820",
"assets/lib/Service/localhost.dart": "b4b9f0c142740efc4d920e4f649c128c",
"assets/lib/Service/login_service.dart": "974074063f653cda2df5066b6f8abb69",
"assets/lib/Service/participant_list_service.dart": "94082b229730119913fc7015729c38c3",
"assets/lib/Service/user_service.dart": "ee046f7f1f3a4af6871325f701b77234",
"assets/NOTICES": "d56000e196a77579f94af2bde900fc64",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_bootstrap.js": "8e8f52056ae9fa2258256e4695ccde9e",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-logo.png": "0f4e359035a4f63761590b5ca723508e",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "32894bd3181fcb54623a22d9c693f551",
"/": "32894bd3181fcb54623a22d9c693f551",
"index.html~": "4d634e89d77ab7c608cfe3ee3f4ce229",
"main.dart.js": "52d186dfaa48cb28f08450ad9f9cef00",
"manifest.json": "283965bb4a3e093acb9599f9605b50bf",
"version.json": "b70d5508e5686fd74507c3f08d460ce1"};
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
