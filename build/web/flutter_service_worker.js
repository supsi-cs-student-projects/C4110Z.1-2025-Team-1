'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "89ad412f0eb915d6178a166a7a260021",
"version.json": "18840f54b32f8d6ec5a87d0ef6de5382",
"index.html": "5337ed82f10357aefd2024a210554da0",
"/": "5337ed82f10357aefd2024a210554da0",
"LucaBTE.github.io/flutter_bootstrap.js": "5b19736b4cfaa0293b18b84126559933",
"LucaBTE.github.io/version.json": "18840f54b32f8d6ec5a87d0ef6de5382",
"LucaBTE.github.io/index.html": "f4dfa794f897cae4c7c0719daa6e5233",
"LucaBTE.github.io/index.php": "e51b7d4534a49792f02e71f88a02f03f",
"LucaBTE.github.io/main.dart.js": "24165a2b8cd65b6d945d248bc88a0a92",
"LucaBTE.github.io/flutter.js": "76f08d47ff9f5715220992f993002504",
"LucaBTE.github.io/favicon.png": "d73083ba0fe6c987768c0f51892d2d01",
"LucaBTE.github.io/icons/Icon-192.png": "e1b919ef0aff339090efcb5f92e70302",
"LucaBTE.github.io/icons/Icon-maskable-192.png": "15e6210cf3bbe080c538568e765074a6",
"LucaBTE.github.io/icons/Icon-maskable-512.png": "985cf0b68680535cab620f45337c8160",
"LucaBTE.github.io/icons/Icon-512.png": "63a148f1740ad1cf4cc28f5511f53346",
"LucaBTE.github.io/manifest.json": "db971c6900e2cc0ef1922f156cc61363",
"LucaBTE.github.io/.git/config": "7bf8158ecb62b4ecf9394729ab4275ea",
"LucaBTE.github.io/.git/objects/pack/pack-a59126872adea2ef4ba7c0fa287cc80a27833a5b.pack": "6cbe26822dc5a7076a5494258f29ba98",
"LucaBTE.github.io/.git/objects/pack/pack-a59126872adea2ef4ba7c0fa287cc80a27833a5b.idx": "80d53f6be04a9f03001d960836d25d72",
"LucaBTE.github.io/.git/HEAD": "f01ada5d23bdfc8d97a8a8b3d70490c2",
"LucaBTE.github.io/.git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
"LucaBTE.github.io/.git/logs/HEAD": "8f6578a62a1d29eb5b16f89fa8620a79",
"LucaBTE.github.io/.git/logs/refs/heads/dev": "8f6578a62a1d29eb5b16f89fa8620a79",
"LucaBTE.github.io/.git/logs/refs/remotes/origin/HEAD": "8f6578a62a1d29eb5b16f89fa8620a79",
"LucaBTE.github.io/.git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
"LucaBTE.github.io/.git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
"LucaBTE.github.io/.git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
"LucaBTE.github.io/.git/hooks/pre-commit.sample": "305eadbbcd6f6d2567e033ad12aabbc4",
"LucaBTE.github.io/.git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
"LucaBTE.github.io/.git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
"LucaBTE.github.io/.git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
"LucaBTE.github.io/.git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
"LucaBTE.github.io/.git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
"LucaBTE.github.io/.git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
"LucaBTE.github.io/.git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
"LucaBTE.github.io/.git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
"LucaBTE.github.io/.git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
"LucaBTE.github.io/.git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
"LucaBTE.github.io/.git/refs/heads/dev": "5d001a947e4c1c662e8502c08303c11b",
"LucaBTE.github.io/.git/refs/remotes/origin/HEAD": "ab5b7854f7f3ff71dd12c8c1178362e5",
"LucaBTE.github.io/.git/index": "e32387e0e19e6f10565f0ee123357409",
"LucaBTE.github.io/.git/packed-refs": "a6f663d4682c835241e4db247035709b",
"LucaBTE.github.io/assets/AssetManifest.json": "97bf7f23f09c24f9d5eb63f8b8eaaa38",
"LucaBTE.github.io/assets/NOTICES": "5f430565a7abb94e455fa303dc7264fc",
"LucaBTE.github.io/assets/FontManifest.json": "f924339a6a130cb6bfdbb85a71dc1c4a",
"LucaBTE.github.io/assets/AssetManifest.bin.json": "c3c6c35806fe3580b69672d43d90753f",
"LucaBTE.github.io/assets/packages/window_manager/images/ic_chrome_unmaximize.png": "4a90c1909cb74e8f0d35794e2f61d8bf",
"LucaBTE.github.io/assets/packages/window_manager/images/ic_chrome_minimize.png": "4282cd84cb36edf2efb950ad9269ca62",
"LucaBTE.github.io/assets/packages/window_manager/images/ic_chrome_maximize.png": "af7499d7657c8b69d23b85156b60298c",
"LucaBTE.github.io/assets/packages/window_manager/images/ic_chrome_close.png": "75f4b8ab3608a05461a31fc18d6b47c2",
"LucaBTE.github.io/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"LucaBTE.github.io/assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"LucaBTE.github.io/assets/AssetManifest.bin": "cdb21d0b21842751294f5e8aa2a6bbf0",
"LucaBTE.github.io/assets/fonts/PixelFont.otf": "ed759aee379c82aecccdf2f72d89e32e",
"LucaBTE.github.io/assets/fonts/RetroGaming.ttf": "4c19fc875e7ba1e6831129de3ab5ac0b",
"LucaBTE.github.io/assets/fonts/MaterialIcons-Regular.otf": "92828b3183361ba128a646171f60dd1f",
"LucaBTE.github.io/assets/fonts/AvenirLTStd-Roman.otf": "b1d7c6e085a31e9f5e4745c9aef6eb4b",
"LucaBTE.github.io/assets/assets/images/statistics/stats_box.png": "bc875625a5a3159d77f118153fd7e9c4",
"LucaBTE.github.io/assets/assets/images/background/background2.jpg": "9179d6a65104b1ba760e75a84741cfed",
"LucaBTE.github.io/assets/assets/images/background/background3.png": "6930656ee5024c5e58d8497f50525207",
"LucaBTE.github.io/assets/assets/images/background/background1.png": "639845d15bb1fe5d32f1d6fd12b1d298",
"LucaBTE.github.io/assets/assets/images/background/clouds.jpg": "179a60c56950a617374b02cf8a28e380",
"LucaBTE.github.io/assets/assets/images/background/ground_horizontal.png": "19bfa435ef0336781922d5c7ac20b152",
"LucaBTE.github.io/assets/assets/images/background/ground_vertical.png": "8618c51d1679919bed7b00dd2c34935a",
"LucaBTE.github.io/assets/assets/images/buttons/games_button.png": "8a29b2d902e8980a331a7388edd2ce0b",
"LucaBTE.github.io/assets/assets/images/buttons/question_button.png": "b92c1583c4cc0628c08d03dac0888f8d",
"LucaBTE.github.io/assets/assets/images/buttons/logout_button.png": "68a6c4323a210569e04d6bcc93533c97",
"LucaBTE.github.io/assets/assets/images/buttons/back_button.png": "a09f13b7c1c7da7a56d3c3c6fdef2617",
"LucaBTE.github.io/assets/assets/images/AB_logo.png": "5ed57bb095692a7d9d8e234d0eef64e4",
"LucaBTE.github.io/assets/assets/images/plant/clouds.png": "126af81176978d5e1ad37f44d0c5031e",
"LucaBTE.github.io/assets/assets/images/plant/shadow_plant.png": "746c6b0b3790fff3ca6437a6a774eba2",
"LucaBTE.github.io/assets/assets/images/plant/plant_happy.png": "01e36e3c6b2942777a463bd5b2bbb10c",
"LucaBTE.github.io/assets/assets/images/plant/ground.png": "eca10c262390738722993801dd096e53",
"LucaBTE.github.io/assets/assets/images/plant/groundWithShadow.png": "efb6b61c50efe6368c370e00b1a5333c",
"LucaBTE.github.io/assets/assets/images/curiosities/CuriosityText.png": "f80b4e2d9d9a89533384e17295aad05a",
"LucaBTE.github.io/assets/assets/images/logo/Bloom_logo.png": "6df8c8f16e7bbb263a284f45e344f298",
"LucaBTE.github.io/assets/assets/images/pixel_animations/plant_idle.png": "6189a0851f167d2168ac32d7b4a91d9d",
"LucaBTE.github.io/assets/assets/images/pixel_animations/ground_pixel.png": "a05847b3c76d86ecd7162c2517ae998c",
"LucaBTE.github.io/assets/assets/images/sprites/tequila.png": "97f0a75395cd8bad3474ef83e72fb93e",
"LucaBTE.github.io/assets/assets/images/sprites/beer.png": "538d4f44f39129509a198702e51d7e4e",
"LucaBTE.github.io/assets/assets/images/sprites/wine.png": "443e4ab3f7cf4bd0ae8c7dfea0bbc2d4",
"LucaBTE.github.io/assets/assets/images/sprites/cider.png": "59d8638b4cff5235ec272b7325be3b6f",
"LucaBTE.github.io/assets/assets/images/sprites/whiskey.png": "3abda9065ad7ae0ab49b3d405f4eaaae",
"LucaBTE.github.io/assets/assets/images/sprites/rum.png": "4343b0a30a1dcef4d0ffa78638ce6174",
"LucaBTE.github.io/assets/assets/images/sprites/vodka.png": "5694021fb2b5195878360f7462a9a9e8",
"LucaBTE.github.io/assets/assets/images/sprites/gin.png": "fba2723be842b3d807d1e35c6b217bc2",
"LucaBTE.github.io/assets/assets/images/sprites/champagne.png": "aea5f5ccf3511d470429def73414e9c2",
"LucaBTE.github.io/assets/assets/images/faces/normal_face.png": "9d513b7441fddd58f3613f45d154f30e",
"LucaBTE.github.io/assets/assets/images/faces/sad_face.png": "502cb2dd574c7936548d87f524d6052c",
"LucaBTE.github.io/assets/assets/images/faces/happy_face.png": "e389db29e9ed6435e45a52e22c73101f",
"LucaBTE.github.io/assets/assets/higher_or_lower/question_box.png": "18f921bdd5cc969069a5fa7689ced203",
"LucaBTE.github.io/assets/assets/higher_or_lower/higher_or_lower_back.png": "7b538097a9c1e7c50914457758308e7f",
"LucaBTE.github.io/assets/assets/higher_or_lower/questions.txt": "094c95bb0e2ad252efb43d1508c38984",
"LucaBTE.github.io/assets/assets/higher_or_lower/game_over_box.png": "5e254284dd8837f90e7624c34255d6df",
"LucaBTE.github.io/assets/assets/higher_or_lower/higherorlower_vertical.png": "31e96fb70ec5aae271773c0e4651745d",
"LucaBTE.github.io/assets/assets/audio/homepage_music.ogg": "1a371b0246e6aa8430ce9dc74b49aec5",
"LucaBTE.github.io/assets/assets/audio/kwyd/choice/right.ogg": "758348dbebe7ef77f85d1c0b8c764a26",
"LucaBTE.github.io/assets/assets/infos/alcohols.txt": "d8c23c77b9a3055c889744602f2f7668",
"LucaBTE.github.io/assets/assets/infos/curiosities.txt": "571fd6a958150015a95f55e3e1db2277",
"LucaBTE.github.io/assets/assets/Animations/plant_lv1.json": "3d02d46d9f47634c1bf27a4d33f0387e",
"LucaBTE.github.io/assets/assets/Animations/click_plant.json": "959bc3d406db93320769d5026143894d",
"LucaBTE.github.io/assets/assets/Animations/initial_animation.json": "729a8cb305bedc0f36e6a1567d1b9ab8",
"LucaBTE.github.io/assets/assets/Animations/pixel_plant_idle.json": "c4537c8fcb20aadcf964c39f00b0aa20",
"LucaBTE.github.io/assets/assets/Animations/idle_plant.webp": "0cf16258d59521570b13db72ad3cdd01",
"LucaBTE.github.io/assets/assets/Animations/pixelart_test.gif": "d143de4ed3a83a749c0fa9698f0603f1",
"LucaBTE.github.io/assets/assets/Animations/plant_lv2.json": "e19b9ab46d16d949a4930cb3cb45d5fc",
"LucaBTE.github.io/assets/assets/Animations/plant_idle.json": "20cbe14148c7c7976665cd1a20fe8329",
"LucaBTE.github.io/canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"LucaBTE.github.io/canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"LucaBTE.github.io/canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"LucaBTE.github.io/canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"LucaBTE.github.io/canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"LucaBTE.github.io/canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"LucaBTE.github.io/canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"LucaBTE.github.io/canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"LucaBTE.github.io/canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"LucaBTE.github.io/canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"LucaBTE.github.io/canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"LucaBTE.github.io/canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"index.php": "e51b7d4534a49792f02e71f88a02f03f",
"main.dart.js": "add4086262049067242b516619cfef3a",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"favicon.png": "d73083ba0fe6c987768c0f51892d2d01",
"icons/Icon-192.png": "e1b919ef0aff339090efcb5f92e70302",
"icons/Icon-maskable-192.png": "15e6210cf3bbe080c538568e765074a6",
"icons/Icon-maskable-512.png": "985cf0b68680535cab620f45337c8160",
"icons/Icon-512.png": "63a148f1740ad1cf4cc28f5511f53346",
"manifest.json": "db971c6900e2cc0ef1922f156cc61363",
"assets/AssetManifest.json": "97bf7f23f09c24f9d5eb63f8b8eaaa38",
"assets/NOTICES": "706baec61baed5541d0c6e6e11d4351b",
"assets/FontManifest.json": "f924339a6a130cb6bfdbb85a71dc1c4a",
"assets/AssetManifest.bin.json": "c3c6c35806fe3580b69672d43d90753f",
"assets/packages/window_manager/images/ic_chrome_unmaximize.png": "4a90c1909cb74e8f0d35794e2f61d8bf",
"assets/packages/window_manager/images/ic_chrome_minimize.png": "4282cd84cb36edf2efb950ad9269ca62",
"assets/packages/window_manager/images/ic_chrome_maximize.png": "af7499d7657c8b69d23b85156b60298c",
"assets/packages/window_manager/images/ic_chrome_close.png": "75f4b8ab3608a05461a31fc18d6b47c2",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "cdb21d0b21842751294f5e8aa2a6bbf0",
"assets/fonts/PixelFont.otf": "ed759aee379c82aecccdf2f72d89e32e",
"assets/fonts/RetroGaming.ttf": "4c19fc875e7ba1e6831129de3ab5ac0b",
"assets/fonts/MaterialIcons-Regular.otf": "92828b3183361ba128a646171f60dd1f",
"assets/fonts/AvenirLTStd-Roman.otf": "b1d7c6e085a31e9f5e4745c9aef6eb4b",
"assets/assets/images/statistics/stats_box.png": "32597d5ddba2f8b085fe39f870991c93",
"assets/assets/images/background/background2.jpg": "9179d6a65104b1ba760e75a84741cfed",
"assets/assets/images/background/background3.png": "e3e4152d078d8a3f60a4775fa0e2014c",
"assets/assets/images/background/background1.png": "639845d15bb1fe5d32f1d6fd12b1d298",
"assets/assets/images/background/clouds.jpg": "27b6b96e16e0f65e283a6d8f96fc7be0",
"assets/assets/images/background/ground_horizontal.png": "0199ffc411853eb1ddf5a50449b8f634",
"assets/assets/images/background/ground_vertical.png": "8618c51d1679919bed7b00dd2c34935a",
"assets/assets/images/buttons/games_button.png": "8a29b2d902e8980a331a7388edd2ce0b",
"assets/assets/images/buttons/question_button.png": "b92c1583c4cc0628c08d03dac0888f8d",
"assets/assets/images/buttons/logout_button.png": "68a6c4323a210569e04d6bcc93533c97",
"assets/assets/images/buttons/back_button.png": "a09f13b7c1c7da7a56d3c3c6fdef2617",
"assets/assets/images/AB_logo.png": "5ed57bb095692a7d9d8e234d0eef64e4",
"assets/assets/images/plant/clouds.png": "126af81176978d5e1ad37f44d0c5031e",
"assets/assets/images/plant/shadow_plant.png": "746c6b0b3790fff3ca6437a6a774eba2",
"assets/assets/images/plant/plant_happy.png": "01e36e3c6b2942777a463bd5b2bbb10c",
"assets/assets/images/plant/ground.png": "eca10c262390738722993801dd096e53",
"assets/assets/images/plant/groundWithShadow.png": "efb6b61c50efe6368c370e00b1a5333c",
"assets/assets/images/curiosities/CuriosityText.png": "f80b4e2d9d9a89533384e17295aad05a",
"assets/assets/images/logo/Bloom_logo.png": "6df8c8f16e7bbb263a284f45e344f298",
"assets/assets/images/pixel_animations/plant_idle.png": "6189a0851f167d2168ac32d7b4a91d9d",
"assets/assets/images/pixel_animations/ground_pixel.png": "a05847b3c76d86ecd7162c2517ae998c",
"assets/assets/images/sprites/tequila.png": "97f0a75395cd8bad3474ef83e72fb93e",
"assets/assets/images/sprites/beer.png": "538d4f44f39129509a198702e51d7e4e",
"assets/assets/images/sprites/wine.png": "443e4ab3f7cf4bd0ae8c7dfea0bbc2d4",
"assets/assets/images/sprites/cider.png": "59d8638b4cff5235ec272b7325be3b6f",
"assets/assets/images/sprites/whiskey.png": "3abda9065ad7ae0ab49b3d405f4eaaae",
"assets/assets/images/sprites/rum.png": "4343b0a30a1dcef4d0ffa78638ce6174",
"assets/assets/images/sprites/vodka.png": "5694021fb2b5195878360f7462a9a9e8",
"assets/assets/images/sprites/gin.png": "fba2723be842b3d807d1e35c6b217bc2",
"assets/assets/images/sprites/champagne.png": "aea5f5ccf3511d470429def73414e9c2",
"assets/assets/images/faces/normal_face.png": "9d513b7441fddd58f3613f45d154f30e",
"assets/assets/images/faces/sad_face.png": "502cb2dd574c7936548d87f524d6052c",
"assets/assets/images/faces/happy_face.png": "e389db29e9ed6435e45a52e22c73101f",
"assets/assets/higher_or_lower/question_box.png": "18f921bdd5cc969069a5fa7689ced203",
"assets/assets/higher_or_lower/higher_or_lower_back.png": "7b538097a9c1e7c50914457758308e7f",
"assets/assets/higher_or_lower/questions.txt": "094c95bb0e2ad252efb43d1508c38984",
"assets/assets/higher_or_lower/game_over_box.png": "5e254284dd8837f90e7624c34255d6df",
"assets/assets/higher_or_lower/higherorlower_vertical.png": "31e96fb70ec5aae271773c0e4651745d",
"assets/assets/audio/homepage_music.ogg": "1a371b0246e6aa8430ce9dc74b49aec5",
"assets/assets/audio/kwyd/choice/right.ogg": "758348dbebe7ef77f85d1c0b8c764a26",
"assets/assets/infos/alcohols.txt": "d8c23c77b9a3055c889744602f2f7668",
"assets/assets/infos/curiosities.txt": "571fd6a958150015a95f55e3e1db2277",
"assets/assets/Animations/plant_lv1.json": "3d02d46d9f47634c1bf27a4d33f0387e",
"assets/assets/Animations/click_plant.json": "959bc3d406db93320769d5026143894d",
"assets/assets/Animations/initial_animation.json": "729a8cb305bedc0f36e6a1567d1b9ab8",
"assets/assets/Animations/pixel_plant_idle.json": "c4537c8fcb20aadcf964c39f00b0aa20",
"assets/assets/Animations/idle_plant.webp": "0cf16258d59521570b13db72ad3cdd01",
"assets/assets/Animations/pixelart_test.gif": "d143de4ed3a83a749c0fa9698f0603f1",
"assets/assets/Animations/plant_lv2.json": "e19b9ab46d16d949a4930cb3cb45d5fc",
"assets/assets/Animations/plant_idle.json": "20cbe14148c7c7976665cd1a20fe8329",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206"};
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
