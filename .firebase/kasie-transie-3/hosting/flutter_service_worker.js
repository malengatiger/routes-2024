'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "845393193075f389989fc2f97365606d",
"version.json": "eb41fe1c5ba273847d0f15116c318b87",
"index.html": "67f16da09b6dc4bba242b9c3d0306447",
"/": "67f16da09b6dc4bba242b9c3d0306447",
"main.dart.js": "009e2747e08f74d12d8ab5cad152528b",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "5bea4328d20ad2ef87c0fd0d36ba736e",
"assets/AssetManifest.json": "74bf3b9009a330d4e80e63aedeff4142",
"assets/NOTICES": "9c06c273657badb3c91aec01435a8850",
"assets/FontManifest.json": "5a32d4310a6f5d9a6b651e75ba0d7372",
"assets/AssetManifest.bin.json": "b2494821d60531e432f73a58bc089f8e",
"assets/packages/intl_phone_field/assets/flags/tg.png": "7f91f02b26b74899ff882868bd611714",
"assets/packages/intl_phone_field/assets/flags/me.png": "590284bc85810635ace30a173e615ca4",
"assets/packages/intl_phone_field/assets/flags/la.png": "e8cd9c3ee6e134adcbe3e986e1974e4a",
"assets/packages/intl_phone_field/assets/flags/mr.png": "f2a62602d43a1ee14625af165b96ce2f",
"assets/packages/intl_phone_field/assets/flags/ni.png": "e398dc23e79d9ccd702546cc25f126bf",
"assets/packages/intl_phone_field/assets/flags/lv.png": "53105fea0cc9cc554e0ceaabc53a2d5d",
"assets/packages/intl_phone_field/assets/flags/om.png": "cebd9ab4b9ab071b2142e21ae2129efc",
"assets/packages/intl_phone_field/assets/flags/af.png": "ba710b50a060b5351381b55366396c30",
"assets/packages/intl_phone_field/assets/flags/cy.png": "7b36f4af86257a3f15f5a5a16f4a2fcd",
"assets/packages/intl_phone_field/assets/flags/bj.png": "6fdc6449f73d23ad3f07060f92db4423",
"assets/packages/intl_phone_field/assets/flags/aq.png": "0c586e7b91aa192758fdd0f03adb84d8",
"assets/packages/intl_phone_field/assets/flags/cn.png": "040539c2cdb60ebd9dc8957cdc6a8ad0",
"assets/packages/intl_phone_field/assets/flags/gb-sct.png": "75106a5e49e3e16da76cb33bdac102ab",
"assets/packages/intl_phone_field/assets/flags/co.png": "e3b1be16dcdae6cb72e9c238fdddce3c",
"assets/packages/intl_phone_field/assets/flags/cx.png": "8efa3231c8a3900a78f2b51d829f8c52",
"assets/packages/intl_phone_field/assets/flags/ag.png": "41c11d5668c93ba6e452f811defdbb24",
"assets/packages/intl_phone_field/assets/flags/ms.png": "9c955a926cf7d57fccb450a97192afa7",
"assets/packages/intl_phone_field/assets/flags/md.png": "8911d3d821b95b00abbba8771e997eb3",
"assets/packages/intl_phone_field/assets/flags/zm.png": "81cec35b715f227328cad8f314acd797",
"assets/packages/intl_phone_field/assets/flags/vn.png": "32ff65ccbf31a707a195be2a5141a89b",
"assets/packages/intl_phone_field/assets/flags/tf.png": "b2c044b86509e7960b5ba66b094ea285",
"assets/packages/intl_phone_field/assets/flags/td.png": "009303b6188ca0e30bd50074b16f0b16",
"assets/packages/intl_phone_field/assets/flags/yt.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/packages/intl_phone_field/assets/flags/lb.png": "f80cde345f0d9bd0086531808ce5166a",
"assets/packages/intl_phone_field/assets/flags/mf.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/packages/intl_phone_field/assets/flags/lu.png": "6274fd1cae3c7a425d25e4ccb0941bb8",
"assets/packages/intl_phone_field/assets/flags/mq.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/packages/intl_phone_field/assets/flags/cz.png": "73ecd64c6144786c4d03729b1dd9b1f3",
"assets/packages/intl_phone_field/assets/flags/ae.png": "792efc5eb6c31d780bd34bf4bad69f3f",
"assets/packages/intl_phone_field/assets/flags/cm.png": "42d52fa71e8b4dbb182ff431749e8d0d",
"assets/packages/intl_phone_field/assets/flags/bi.png": "adda8121501f0543f1075244a1acc275",
"assets/packages/intl_phone_field/assets/flags/ar.png": "3bd245f8c28f70c9ef9626dae27adc65",
"assets/packages/intl_phone_field/assets/flags/as.png": "d9c1da515c6f945c2e2554592a9dfaae",
"assets/packages/intl_phone_field/assets/flags/bh.png": "a1acd86ef0e19ea5f0297bbe1de6cfd4",
"assets/packages/intl_phone_field/assets/flags/cl.png": "6735e0e2d88c119e9ed1533be5249ef1",
"assets/packages/intl_phone_field/assets/flags/ad.png": "384e9845debe9aca8f8586d9bedcb7e6",
"assets/packages/intl_phone_field/assets/flags/mp.png": "87351c30a529071ee9a4bb67765fea4f",
"assets/packages/intl_phone_field/assets/flags/lt.png": "7df2cd6566725685f7feb2051f916a3e",
"assets/packages/intl_phone_field/assets/flags/mg.png": "0ef6271ad284ebc0069ff0aeb5a3ad1e",
"assets/packages/intl_phone_field/assets/flags/lc.png": "8c1a03a592aa0a99fcaf2b81508a87eb",
"assets/packages/intl_phone_field/assets/flags/tr.png": "27feab1a5ca390610d07e0c6bd4720d5",
"assets/packages/intl_phone_field/assets/flags/ua.png": "b4b10d893611470661b079cb30473871",
"assets/packages/intl_phone_field/assets/flags/tv.png": "c57025ed7ae482210f29b9da86b0d211",
"assets/packages/intl_phone_field/assets/flags/vi.png": "3f317c56f31971b3179abd4e03847036",
"assets/packages/intl_phone_field/assets/flags/mt.png": "f3119401ae0c3a9d6e2dc23803928c06",
"assets/packages/intl_phone_field/assets/flags/no.png": "33bc70259c4908b7b9adeef9436f7a9f",
"assets/packages/intl_phone_field/assets/flags/mc.png": "90c2ad7f144d73d4650cbea9dd621275",
"assets/packages/intl_phone_field/assets/flags/ch.png": "a251702f7760b0aac141428ed60b7b66",
"assets/packages/intl_phone_field/assets/flags/bl.png": "dae94f5465d3390fdc5929e4f74d3f5f",
"assets/packages/intl_phone_field/assets/flags/aw.png": "a93ddf8e32d246dc47f6631f38e0ed92",
"assets/packages/intl_phone_field/assets/flags/bz.png": "fd2d7d27a5ddabe4eb9a10b1d3a433e4",
"assets/packages/intl_phone_field/assets/flags/bm.png": "b366ba84cbc8286c830f392bb9086be5",
"assets/packages/intl_phone_field/assets/flags/ci.png": "7f5ca3779d5ff6ce0c803a6efa0d2da7",
"assets/packages/intl_phone_field/assets/flags/mu.png": "c5228d1e94501d846b5bf203f038ae49",
"assets/packages/intl_phone_field/assets/flags/us.png": "83b065848d14d33c0d10a13e01862f34",
"assets/packages/intl_phone_field/assets/flags/tw.png": "b1101fd5f871a9ffe7c9ad191a7d3304",
"assets/packages/intl_phone_field/assets/flags/ye.png": "4cf73209d90e9f02ead1565c8fdf59e5",
"assets/packages/intl_phone_field/assets/flags/mw.png": "ffc1f18eeedc1dfbb1080aa985ce7d05",
"assets/packages/intl_phone_field/assets/flags/nl.png": "3649c177693bfee9c2fcc63c191a51f1",
"assets/packages/intl_phone_field/assets/flags/ls.png": "2bca756f9313957347404557acb532b0",
"assets/packages/intl_phone_field/assets/flags/bo.png": "3ccf6fa7f9cbc27949b8418925e4e89c",
"assets/packages/intl_phone_field/assets/flags/at.png": "570c070177a5ea0fe03e20107ebf5283",
"assets/packages/intl_phone_field/assets/flags/ck.png": "39f343868a8dc8ca95d27b27a5caf480",
"assets/packages/intl_phone_field/assets/flags/by.png": "beabf61e94fb3a4f7c7a7890488b213d",
"assets/packages/intl_phone_field/assets/flags/au.png": "72be14316f0af3903cdca7a726c0c589",
"assets/packages/intl_phone_field/assets/flags/bn.png": "ed650de06fff61ff27ec92a872197948",
"assets/packages/intl_phone_field/assets/flags/ma.png": "057ea2e08587f1361b3547556adae0c2",
"assets/packages/intl_phone_field/assets/flags/nz.png": "65c811e96eb6c9da65538f899c110895",
"assets/packages/intl_phone_field/assets/flags/lr.png": "b92c75e18dd97349c75d6a43bd17ee94",
"assets/packages/intl_phone_field/assets/flags/mv.png": "d9245f74e34d5c054413ace4b86b4f16",
"assets/packages/intl_phone_field/assets/flags/tc.png": "d728d6763c17c520ad6bcf3c24282a29",
"assets/packages/intl_phone_field/assets/flags/ug.png": "9a0f358b1eb19863e21ae2063fab51c0",
"assets/packages/intl_phone_field/assets/flags/tt.png": "a8e1fc5c65dc8bc362a9453fadf9c4b3",
"assets/packages/intl_phone_field/assets/flags/pl.png": "f20e9ef473a9ed24176f5ad74dd0d50a",
"assets/packages/intl_phone_field/assets/flags/rs.png": "9dff535d2d08c504be63062f39eff0b7",
"assets/packages/intl_phone_field/assets/flags/in.png": "1dec13ba525529cffd4c7f8a35d51121",
"assets/packages/intl_phone_field/assets/flags/ge.png": "6fbd41f07921fa415347ebf6dff5b0f7",
"assets/packages/intl_phone_field/assets/flags/gr.png": "ec11281d7decbf07b81a23a72a609b59",
"assets/packages/intl_phone_field/assets/flags/gs.png": "419dd57836797a3f1bf6258ea6589f9a",
"assets/packages/intl_phone_field/assets/flags/gd.png": "7a4864ccfa2a0564041c2d1f8a13a8c9",
"assets/packages/intl_phone_field/assets/flags/io.png": "83d45bbbff087d47b2b39f1c20598f52",
"assets/packages/intl_phone_field/assets/flags/hk.png": "4b5ec424348c98ec71a46ad3dce3931d",
"assets/packages/intl_phone_field/assets/flags/kp.png": "e1c8bb52f31fca22d3368d8f492d8f27",
"assets/packages/intl_phone_field/assets/flags/gb-nir.png": "98773db151c150cabe845183241bfe6b",
"assets/packages/intl_phone_field/assets/flags/kg.png": "c4aa6d221d9a9d332155518d6b82dbc7",
"assets/packages/intl_phone_field/assets/flags/pm.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/packages/intl_phone_field/assets/flags/sv.png": "217b691efbef7a0f48cdd53e91997f0e",
"assets/packages/intl_phone_field/assets/flags/re.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/packages/intl_phone_field/assets/flags/sa.png": "7c95c1a877148e2aa21a213d720ff4fd",
"assets/packages/intl_phone_field/assets/flags/sc.png": "e969fd5afb1eb5902675b6bcf49a8c2e",
"assets/packages/intl_phone_field/assets/flags/st.png": "fef62c31713ff1063da2564df3f43eea",
"assets/packages/intl_phone_field/assets/flags/ke.png": "cf5aae3699d3cacb39db9803edae172b",
"assets/packages/intl_phone_field/assets/flags/im.png": "7c9ccb825f0fca557d795c4330cf4f50",
"assets/packages/intl_phone_field/assets/flags/kr.png": "a3b7da3b76b20a70e9cd63cc2315b51b",
"assets/packages/intl_phone_field/assets/flags/gf.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/packages/intl_phone_field/assets/flags/dj.png": "078bd37d41f746c3cb2d84c1e9611c55",
"assets/packages/intl_phone_field/assets/flags/gq.png": "4286e56f388a37f64b21eb56550c06d9",
"assets/packages/intl_phone_field/assets/flags/gp.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/packages/intl_phone_field/assets/flags/dk.png": "abcd01bdbcc02b4a29cbac237f29cd1d",
"assets/packages/intl_phone_field/assets/flags/gg.png": "eed435d25bd755aa7f9cd7004b9ed49d",
"assets/packages/intl_phone_field/assets/flags/il.png": "1e06ad7783f24332405d36561024cc4c",
"assets/packages/intl_phone_field/assets/flags/pn.png": "0b0641b356af4c3e3489192ff4b0be77",
"assets/packages/intl_phone_field/assets/flags/sb.png": "296ecedbd8d1c2a6422c3ba8e5cd54bd",
"assets/packages/intl_phone_field/assets/flags/py.png": "154d4add03b4878caf00bd3249e14f40",
"assets/packages/intl_phone_field/assets/flags/ru.png": "6974dcb42ad7eb3add1009ea0c6003e3",
"assets/packages/intl_phone_field/assets/flags/kw.png": "3ca448e219d0df506fb2efd5b91be092",
"assets/packages/intl_phone_field/assets/flags/do.png": "ed35983a9263bb5713be37d9a52caddc",
"assets/packages/intl_phone_field/assets/flags/gt.png": "706a0c3b5e0b589c843e2539e813839e",
"assets/packages/intl_phone_field/assets/flags/gb.png": "98773db151c150cabe845183241bfe6b",
"assets/packages/intl_phone_field/assets/flags/gu.png": "2acb614b442e55864411b6e418df6eab",
"assets/packages/intl_phone_field/assets/flags/je.png": "288f8dca26098e83ff0455b08cceca1b",
"assets/packages/intl_phone_field/assets/flags/hm.png": "72be14316f0af3903cdca7a726c0c589",
"assets/packages/intl_phone_field/assets/flags/sg.png": "bc772e50b8c79f08f3c2189f5d8ce491",
"assets/packages/intl_phone_field/assets/flags/pk.png": "7a6a621f7062589677b3296ca16c6718",
"assets/packages/intl_phone_field/assets/flags/sr.png": "9f912879f2829a625436ccd15e643e39",
"assets/packages/intl_phone_field/assets/flags/se.png": "25dd5434891ac1ca2ad1af59cda70f80",
"assets/packages/intl_phone_field/assets/flags/jp.png": "25ac778acd990bedcfdc02a9b4570045",
"assets/packages/intl_phone_field/assets/flags/gw.png": "05606b9a6393971bd87718b809e054f9",
"assets/packages/intl_phone_field/assets/flags/eh.png": "515a9cf2620c802e305b5412ac81aed2",
"assets/packages/intl_phone_field/assets/flags/dz.png": "132ceca353a95c8214676b2e94ecd40f",
"assets/packages/intl_phone_field/assets/flags/ga.png": "b0e5b2fa1b7106c7652a955db24c11c4",
"assets/packages/intl_phone_field/assets/flags/fr.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/packages/intl_phone_field/assets/flags/dm.png": "8886b222ed9ccd00f67e8bcf86dadcc2",
"assets/packages/intl_phone_field/assets/flags/hn.png": "9ecf68aed83c4a9b3f1e6275d96bfb04",
"assets/packages/intl_phone_field/assets/flags/sd.png": "65ce270762dfc87475ea99bd18f79025",
"assets/packages/intl_phone_field/assets/flags/rw.png": "d1aae0647a5b1ab977ae43ab894ce2c3",
"assets/packages/intl_phone_field/assets/flags/ph.png": "e4025d1395a8455f1ba038597a95228c",
"assets/packages/intl_phone_field/assets/flags/ss.png": "b0120cb000b31bb1a5c801c3592139bc",
"assets/packages/intl_phone_field/assets/flags/qa.png": "eb9b3388e554cf85aea1e739247548df",
"assets/packages/intl_phone_field/assets/flags/pe.png": "4d9249aab70a26fadabb14380b3b55d2",
"assets/packages/intl_phone_field/assets/flags/pr.png": "b97b2f4432c430bc340d893f36527e31",
"assets/packages/intl_phone_field/assets/flags/si.png": "24237e53b34752554915e71e346bb405",
"assets/packages/intl_phone_field/assets/flags/ht.png": "630f7f8567d87409a32955107ad11a86",
"assets/packages/intl_phone_field/assets/flags/es.png": "654965f9722f6706586476fb2f5d30dd",
"assets/packages/intl_phone_field/assets/flags/gl.png": "b79e24ee1889b7446ba3d65564b86810",
"assets/packages/intl_phone_field/assets/flags/gm.png": "7148d3715527544c2e7d8d6f4a445bb6",
"assets/packages/intl_phone_field/assets/flags/er.png": "8ca78e10878a2e97c1371b38c5d258a7",
"assets/packages/intl_phone_field/assets/flags/fi.png": "3ccd69a842e55183415b7ea2c04b15c8",
"assets/packages/intl_phone_field/assets/flags/ee.png": "e242645cae28bd5291116ea211f9a566",
"assets/packages/intl_phone_field/assets/flags/kn.png": "f318e2fd87e5fd2cabefe9ff252bba46",
"assets/packages/intl_phone_field/assets/flags/hu.png": "281582a753e643b46bdd894047db08bb",
"assets/packages/intl_phone_field/assets/flags/iq.png": "bc3e6f68c5188dbf99b473e2bea066f2",
"assets/packages/intl_phone_field/assets/flags/ky.png": "38e39eba673e82c48a1f25bd103a7e97",
"assets/packages/intl_phone_field/assets/flags/sh.png": "98773db151c150cabe845183241bfe6b",
"assets/packages/intl_phone_field/assets/flags/ps.png": "52a25a48658ca9274830ffa124a8c1db",
"assets/packages/intl_phone_field/assets/flags/pf.png": "1ae72c24380d087cbe2d0cd6c3b58821",
"assets/packages/intl_phone_field/assets/flags/sj.png": "33bc70259c4908b7b9adeef9436f7a9f",
"assets/packages/intl_phone_field/assets/flags/id.png": "80bb82d11d5bc144a21042e77972bca9",
"assets/packages/intl_phone_field/assets/flags/is.png": "907840430252c431518005b562707831",
"assets/packages/intl_phone_field/assets/flags/eg.png": "311d780e8e3dd43f87e6070f6feb74c7",
"assets/packages/intl_phone_field/assets/flags/fk.png": "da8b0fe48829aae2c8feb4839895de63",
"assets/packages/intl_phone_field/assets/flags/fj.png": "1c6a86752578eb132390febf12789cd6",
"assets/packages/intl_phone_field/assets/flags/gn.png": "b2287c03c88a72d968aa796a076ba056",
"assets/packages/intl_phone_field/assets/flags/gy.png": "159a260bf0217128ea7475ba5b272b6a",
"assets/packages/intl_phone_field/assets/flags/ir.png": "37f67c3141e9843196cb94815be7bd37",
"assets/packages/intl_phone_field/assets/flags/km.png": "5554c8746c16d4f482986fb78ffd9b36",
"assets/packages/intl_phone_field/assets/flags/ie.png": "1d91912afc591dd120b47b56ea78cdbf",
"assets/packages/intl_phone_field/assets/flags/kz.png": "cb3b0095281c9d7e7fb5ce1716ef8ee5",
"assets/packages/intl_phone_field/assets/flags/ro.png": "85af99741fe20664d9a7112cfd8d9722",
"assets/packages/intl_phone_field/assets/flags/sk.png": "2a1ee716d4b41c017ff1dbf3fd3ffc64",
"assets/packages/intl_phone_field/assets/flags/pg.png": "0f7e03465a93e0b4e3e1c9d3dd5814a4",
"assets/packages/intl_phone_field/assets/flags/pt.png": "eba93d33545c78cc67915d9be8323661",
"assets/packages/intl_phone_field/assets/flags/so.png": "1ce20d052f9d057250be96f42647513b",
"assets/packages/intl_phone_field/assets/flags/sx.png": "9c19254973d8acf81581ad95b408c7e6",
"assets/packages/intl_phone_field/assets/flags/hr.png": "69711b2ea009a3e7c40045b538768d4e",
"assets/packages/intl_phone_field/assets/flags/ki.png": "14db0fc29398730064503907bd696176",
"assets/packages/intl_phone_field/assets/flags/jm.png": "074400103847c56c37425a73f9d23665",
"assets/packages/intl_phone_field/assets/flags/eu.png": "c58ece3931acb87faadc5b940d4f7755",
"assets/packages/intl_phone_field/assets/flags/ec.png": "c1ae60d080be91f3be31e92e0a2d9555",
"assets/packages/intl_phone_field/assets/flags/et.png": "57edff61c7fddf2761a19948acef1498",
"assets/packages/intl_phone_field/assets/flags/fo.png": "2c7d9233582e83a86927e634897a2a90",
"assets/packages/intl_phone_field/assets/flags/kh.png": "d48d51e8769a26930da6edfc15de97fe",
"assets/packages/intl_phone_field/assets/flags/sy.png": "24186a0f4ce804a16c91592db5a16a3a",
"assets/packages/intl_phone_field/assets/flags/sn.png": "68eaa89bbc83b3f356e1ba2096b09b3c",
"assets/packages/intl_phone_field/assets/flags/pw.png": "2e697cc6907a7b94c7f94f5d9b3bdccc",
"assets/packages/intl_phone_field/assets/flags/sl.png": "61b9d992c8a6a83abc4d432069617811",
"assets/packages/intl_phone_field/assets/flags/gb-eng.png": "0d9f2a6775fd52b79e1d78eb1dda10cf",
"assets/packages/intl_phone_field/assets/flags/fm.png": "d571b8bc4b80980a81a5edbde788b6d2",
"assets/packages/intl_phone_field/assets/flags/gi.png": "446aa44aaa063d240adab88243b460d3",
"assets/packages/intl_phone_field/assets/flags/de.png": "5d9561246523cf6183928756fd605e25",
"assets/packages/intl_phone_field/assets/flags/gh.png": "b35464dca793fa33e51bf890b5f3d92b",
"assets/packages/intl_phone_field/assets/flags/jo.png": "c01cb41f74f9db0cf07ba20f0af83011",
"assets/packages/intl_phone_field/assets/flags/it.png": "5c8e910e6a33ec63dfcda6e8960dd19c",
"assets/packages/intl_phone_field/assets/flags/pa.png": "78e3e4fd56f0064837098fe3f22fb41b",
"assets/packages/intl_phone_field/assets/flags/sz.png": "d1829842e45c2b2b29222c1b7e201591",
"assets/packages/intl_phone_field/assets/flags/sm.png": "a8d6801cb7c5360e18f0a2ed146b396d",
"assets/packages/intl_phone_field/assets/flags/tn.png": "6612e9fec4bef022cbd45cbb7c02b2b6",
"assets/packages/intl_phone_field/assets/flags/ml.png": "0c50dfd539e87bb4313da0d4556e2d13",
"assets/packages/intl_phone_field/assets/flags/cg.png": "eca97338cc1cb5b5e91bec72af57b3d4",
"assets/packages/intl_phone_field/assets/flags/ax.png": "ec2062c36f09ed8fb90ac8992d010024",
"assets/packages/intl_phone_field/assets/flags/ao.png": "5f0a372aa3aa7150a3dafea97acfc10d",
"assets/packages/intl_phone_field/assets/flags/bt.png": "3cfe1440e952bc7266d71f7f1454fa23",
"assets/packages/intl_phone_field/assets/flags/an.png": "4e4b90fbca1275d1839ca5b44fc51071",
"assets/packages/intl_phone_field/assets/flags/bb.png": "a8473747387e4e7a8450c499529f1c93",
"assets/packages/intl_phone_field/assets/flags/cf.png": "263583ffdf7a888ce4fba8487d1da0b2",
"assets/packages/intl_phone_field/assets/flags/mm.png": "32e5293d6029d8294c7dfc3c3835c222",
"assets/packages/intl_phone_field/assets/flags/li.png": "ecdf7b3fe932378b110851674335d9ab",
"assets/packages/intl_phone_field/assets/flags/na.png": "cdc00e9267a873609b0abea944939ff7",
"assets/packages/intl_phone_field/assets/flags/mz.png": "1ab1ac750fbbb453d33e9f25850ac2a0",
"assets/packages/intl_phone_field/assets/flags/to.png": "1cdd716b5b5502f85d6161dac6ee6c5b",
"assets/packages/intl_phone_field/assets/flags/vg.png": "fc095e11f5b58604d6f4d3c2b43d167f",
"assets/packages/intl_phone_field/assets/flags/ve.png": "893391d65cbd10ca787a73578c77d3a7",
"assets/packages/intl_phone_field/assets/flags/tz.png": "56ec99c7e0f68b88a2210620d873683a",
"assets/packages/intl_phone_field/assets/flags/tm.png": "0980fb40ec450f70896f2c588510f933",
"assets/packages/intl_phone_field/assets/flags/mx.png": "84b12a569b209e213daccfcbdd1fc799",
"assets/packages/intl_phone_field/assets/flags/nc.png": "cb36e0c945b79d56def11b23c6a9c7e9",
"assets/packages/intl_phone_field/assets/flags/mo.png": "849848a26bbfc87024017418ad7a6233",
"assets/packages/intl_phone_field/assets/flags/lk.png": "5a3a063cfff4a92fb0ba6158e610e025",
"assets/packages/intl_phone_field/assets/flags/cd.png": "5b5f832ed6cd9f9240cb31229d8763dc",
"assets/packages/intl_phone_field/assets/flags/al.png": "722cf9e5c7a1d9c9e4608fb44dbb427d",
"assets/packages/intl_phone_field/assets/flags/bw.png": "fac8b90d7404728c08686dc39bab4fb3",
"assets/packages/intl_phone_field/assets/flags/cr.png": "bfd8b41e63fc3cc829c72c4b2e170532",
"assets/packages/intl_phone_field/assets/flags/bv.png": "33bc70259c4908b7b9adeef9436f7a9f",
"assets/packages/intl_phone_field/assets/flags/am.png": "aaa39141fbc80205bebaa0200b55a13a",
"assets/packages/intl_phone_field/assets/flags/az.png": "6ffa766f6883d2d3d350cdc22a062ca3",
"assets/packages/intl_phone_field/assets/flags/ba.png": "d415bad33b35de3f095177e8e86cbc82",
"assets/packages/intl_phone_field/assets/flags/mn.png": "16086e8d89c9067d29fd0f2ea7021a45",
"assets/packages/intl_phone_field/assets/flags/nu.png": "f4169998548e312584c67873e0d9352d",
"assets/packages/intl_phone_field/assets/flags/my.png": "f7f962e8a074387fd568c9d4024e0959",
"assets/packages/intl_phone_field/assets/flags/tl.png": "c80876dc80cda5ab6bb8ef078bc6b05d",
"assets/packages/intl_phone_field/assets/flags/ws.png": "f206322f3e22f175869869dbfadb6ce8",
"assets/packages/intl_phone_field/assets/flags/th.png": "11ce0c9f8c738fd217ea52b9bc29014b",
"assets/packages/intl_phone_field/assets/flags/xk.png": "079259fbcb1f3c78dafa944464295c16",
"assets/packages/intl_phone_field/assets/flags/nf.png": "1c2069b299ce3660a2a95ec574dfde25",
"assets/packages/intl_phone_field/assets/flags/ly.png": "8d65057351859065d64b4c118ff9e30e",
"assets/packages/intl_phone_field/assets/flags/ai.png": "ce5e91ed1725f0499b9231b69a7fd448",
"assets/packages/intl_phone_field/assets/flags/br.png": "5093e0cd8fd3c094664cd17ea8a36fd1",
"assets/packages/intl_phone_field/assets/flags/cv.png": "9b1f31f9fc0795d728328dedd33eb1c0",
"assets/packages/intl_phone_field/assets/flags/be.png": "7e5e1831cdd91935b38415479a7110eb",
"assets/packages/intl_phone_field/assets/flags/ca.png": "76f2fac1d3b2cc52ba6695c2e2941632",
"assets/packages/intl_phone_field/assets/flags/bd.png": "86a0e4bd8787dc8542137a407e0f987f",
"assets/packages/intl_phone_field/assets/flags/cw.png": "6c598eb0d331d6b238da57055ec00d33",
"assets/packages/intl_phone_field/assets/flags/bs.png": "2b9540c4fa514f71911a48de0bd77e71",
"assets/packages/intl_phone_field/assets/flags/ng.png": "aedbe364bd1543832e88e64b5817e877",
"assets/packages/intl_phone_field/assets/flags/mk.png": "835f2263974de523fa779d29c90595bf",
"assets/packages/intl_phone_field/assets/flags/np.png": "6e099fb1e063930bdd00e8df5cef73d4",
"assets/packages/intl_phone_field/assets/flags/va.png": "c010bf145f695d5c8fb551bafc081f77",
"assets/packages/intl_phone_field/assets/flags/uz.png": "3adad3bac322220cac8abc1c7cbaacac",
"assets/packages/intl_phone_field/assets/flags/um.png": "8fe7c4fed0a065fdfb9bd3125c6ecaa1",
"assets/packages/intl_phone_field/assets/flags/tk.png": "60428ff1cdbae680e5a0b8cde4677dd5",
"assets/packages/intl_phone_field/assets/flags/vc.png": "da3ca14a978717467abbcdece05d3544",
"assets/packages/intl_phone_field/assets/flags/zw.png": "078a3267ea8eabf88b2d43fe4aed5ce5",
"assets/packages/intl_phone_field/assets/flags/nr.png": "1316f3a8a419d8be1975912c712535ea",
"assets/packages/intl_phone_field/assets/flags/ne.png": "a20724c177e86d6a27143aa9c9664a6f",
"assets/packages/intl_phone_field/assets/flags/cu.png": "f41715bd51f63a9aebf543788543b4c4",
"assets/packages/intl_phone_field/assets/flags/bq.png": "3649c177693bfee9c2fcc63c191a51f1",
"assets/packages/intl_phone_field/assets/flags/bf.png": "63f1c67fca7ce8b52b3418a90af6ad37",
"assets/packages/intl_phone_field/assets/flags/bg.png": "1d24bc616e3389684ed2c9f18bcb0209",
"assets/packages/intl_phone_field/assets/flags/cc.png": "31a475216e12fef447382c97b42876ce",
"assets/packages/intl_phone_field/assets/flags/gb-wls.png": "d7d7c77c72cd425d993bdc50720f4d04",
"assets/packages/intl_phone_field/assets/flags/mh.png": "18dda388ef5c1cf37cae5e7d5fef39bc",
"assets/packages/intl_phone_field/assets/flags/za.png": "b28280c6c3eb4624c18b5455d4a1b1ff",
"assets/packages/intl_phone_field/assets/flags/uy.png": "da4247b21fcbd9e30dc2b3f7c5dccb64",
"assets/packages/intl_phone_field/assets/flags/wf.png": "6f1644b8f907d197c0ff7ed2f366ad64",
"assets/packages/intl_phone_field/assets/flags/vu.png": "3f201fdfb6d669a64c35c20a801016d1",
"assets/packages/intl_phone_field/assets/flags/tj.png": "c73b793f2acd262e71b9236e64c77636",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/simple_barcode_scanner/assets/barcode.html": "55dd479b440ade30760a1b3a4db300f1",
"assets/packages/simple_barcode_scanner/assets/html5-qrcode.min.js": "d88d3200cb547c9e86ee972975561dcd",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "c0b9fcf27580d9adabe4d60d8e715f8a",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "3ca5dc7621921b901d513cc1ce23788c",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "4769f3245a24c1fa9965f113ea85ec2a",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/getwidget/icons/slack.png": "19155b848beeb39c1ffcf743608e2fde",
"assets/packages/getwidget/icons/twitter.png": "caee56343a870ebd76a090642d838139",
"assets/packages/getwidget/icons/linkedin.png": "822742104a63a720313f6a14d3134f61",
"assets/packages/getwidget/icons/dribble.png": "1e36936e4411f32b0e28fd8335495647",
"assets/packages/getwidget/icons/youtube.png": "1bfda73ab724ad40eb8601f1e7dbc1b9",
"assets/packages/getwidget/icons/line.png": "da8d1b531d8189396d68dfcd8cb37a79",
"assets/packages/getwidget/icons/pinterest.png": "d52ccb1e2a8277e4c37b27b234c9f931",
"assets/packages/getwidget/icons/whatsapp.png": "30632e569686a4b84cc68169fb9ce2e1",
"assets/packages/getwidget/icons/google.png": "596c5544c21e9d6cb02b0768f60f589a",
"assets/packages/getwidget/icons/wechat.png": "ba10e8b2421bde565e50dfabc202feb7",
"assets/packages/getwidget/icons/facebook.png": "293dc099a89c74ae34a028b1ecd2c1f0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "d1ffa7e372b4d2d8f566d2e3743f17de",
"assets/fonts/MaterialIcons-Regular.otf": "0cf5f77446c1f841d6ed5ec332b31240",
"assets/assets/landmark.png": "58dcf5c4fe495a25242c21799248d9e1",
"assets/assets/car2.png": "27f02bf0b2a723dd3d10ed41e5de5bce",
"assets/assets/xd1.jpg": "70da3f953a212ffe60eb90ee54f16f29",
"assets/assets/batman.png": "573bbd2ec55aa637d539c3d0d18a25c6",
"assets/assets/car1.png": "1dc53a7f0d8f2f837d3d5c087c94bf87",
"assets/assets/l10n/zh.json": "a476644b14cf89635f84b6ef4246e777",
"assets/assets/l10n/xh.json": "82e02fd43347896ed4fd54e805433ebe",
"assets/assets/l10n/ig.json": "86097d278ecf80c4010b5aeccbcc90df",
"assets/assets/l10n/yo.json": "014511c8c45d161752a1c403633a03ad",
"assets/assets/l10n/st.json": "1e24b025c85c06d8b03d1a070f224db9",
"assets/assets/l10n/ts.json": "073068671ad20ca5e8b8250abfa2f150",
"assets/assets/l10n/de.json": "b0612d706416c48f035ee31cd02485f6",
"assets/assets/l10n/pt.json": "51a733b184e09070265b28c433a57d12",
"assets/assets/l10n/en.json": "3f6088c274a7f599742568af59f44bf0",
"assets/assets/l10n/zu.json": "20b880fe6d5079916f9d647e7df801cd",
"assets/assets/l10n/fr.json": "3e0dcb04f48aa5298dadf7bd1e94a04d",
"assets/assets/l10n/myKeys.txt": "cd32761d30727c54c73fe362d009a68d",
"assets/assets/l10n/sn.json": "4d96ae25c4ccfd674885ef3fcdeca349",
"assets/assets/l10n/af.json": "013f0c6e454e190be5818090b80e6d38",
"assets/assets/l10n/sw.json": "267de29715a6a40f561bed060caf2bf5",
"assets/assets/l10n/es.json": "395d14445b4be85110965a7655453b1b",
"assets/assets/intro/img4.jpeg": "b11380be09606e3c35f5e124cf201a68",
"assets/assets/intro/org.jpg": "ebf82766c72e2dc469aacb2769b7de18",
"assets/assets/intro/img8.jpeg": "54f9b317f3e50afe8ecb9278c3c57618",
"assets/assets/intro/img5.jpeg": "0bcf020d01467b88f2534e9d19e6068f",
"assets/assets/intro/img2.jpeg": "30d7b5cafc320b38d8095568d5a58804",
"assets/assets/intro/pic3.webp": "4e8a0a8afdce6876dc31d6abe2dc8af4",
"assets/assets/intro/pic1.jpg": "4d5e6e0dd5d07bd6421c2e6f26ab9cd8",
"assets/assets/intro/img7.jpg": "9271fa3219c250bbffef76f5d1f720c7",
"assets/assets/intro/pic2.jpg": "b3e615c161dcf4796b4240fb57c1d478",
"assets/assets/intro/img1.jpeg": "b928a363669e354a89cb5a9753ca4c3c",
"assets/assets/intro/pic6.jpg": "2725c43ab290309ecb2297fb3643bd1f",
"assets/assets/intro/img3.jpg": "c832beea0d9c6f4c696556aef686fcb6",
"assets/assets/intro/pic7.jpg": "4d3d616091b2ca039da564d58b6b2ad2",
"assets/assets/intro/thanks.webp": "a909c7b63637533c6373de68d939f1aa",
"assets/assets/intro/pic5.jpg": "56b84544aa6106059d4c1f04760647b5",
"assets/assets/intro/pic4.jpg": "2fcf8355cab00549df4314d9588bddc0",
"assets/assets/intro/img6.jpeg": "283158d2f232e6bb0851712698702467",
"assets/assets/intro/small.jpg": "cb70fe2b77555748458ac8ddc95357f8",
"assets/assets/markers/footprint.png": "3bc9ff173c619237c5932a9ad8c98890",
"assets/assets/markers/dot1.png": "c5a7bf1a1fafea0f160349efb9248126",
"assets/assets/markers/dot2.png": "54053643f626b8790ca009cd3c75dc03",
"assets/assets/markers/dot3.png": "b8b5404d7616bdebf765801e194f802e",
"assets/assets/markers/dot4white.png": "79b6d7828629fc57111d9afa3114438d",
"assets/assets/markers/dot_blue.png": "f89b20ae538bcb769e461bf8bd963f67",
"assets/assets/images/pp17.jpg": "abe0cf343ff4ca02f337691d1a8c7be5",
"assets/assets/images/pp6.jpeg": "2c2df115b45f1a17f87a616f28b98012",
"assets/assets/images/pp16.jpg": "5af42e8c9c5d007ff3ea14f5d43b9ff2",
"assets/assets/images/pp14.jpg": "f2ee7df33c753f7bb35962aa616208d1",
"assets/assets/images/pp11.jpg": "2803b26fcc1a4051344a1dc79266223a",
"assets/assets/images/pp2.webp": "e900c523c55f1d3c9c044d2221153bd6",
"assets/assets/images/8.jpg": "12f0f8d46c62a87c91f1b338372642a9",
"assets/assets/images/pp9.jpg": "584ac2daed7886d92942f79b6be782d1",
"assets/assets/images/pp7.jpeg": "73be26d8cf6db1ec7ee8111c62b6bf2f",
"assets/assets/images/9.jpg": "c436ad3cedd62efa341a7d2c87839774",
"assets/assets/images/pp13.webp": "e150c22bc940ec5ae9a3f03d18de472a",
"assets/assets/images/k1.png": "f6b75c8cc1a326c5833cfa320028cab9",
"assets/assets/images/k3.png": "9258cb593b8b6a192963e47aed8dc0a0",
"assets/assets/images/k2.png": "5768204cd4a17388b6d5fe95932f15e6",
"assets/assets/images/12.jpg": "a90901407ef1909b3ed3cf0861fae96d",
"assets/assets/images/13.jpg": "cef7f12416ed4ee6472b7bc1b0b29ac7",
"assets/assets/images/11.jpg": "e8b727568567356293aa5e6f31e2989c",
"assets/assets/images/k5.png": "9ead00d162d0e413e3b0a7bf47e1be35",
"assets/assets/images/pp12.webp": "07bb9e0417a8ca76033902cbbec25155",
"assets/assets/images/k4.png": "3562cf20e343f4163299aefeb0b30997",
"assets/assets/images/10.jpg": "ed6f1fc8a93f80e6f2e5bcd515b07e38",
"assets/assets/images/pp2.jpeg": "43be2f16551875e3cb60d820fa28db20",
"assets/assets/images/pp3.jpeg": "dd55d0895b8ac06191d2fc1b99d78ae1",
"assets/assets/images/pp15.jpeg": "a9457beec67c4d21fdc731cfb048439b",
"assets/assets/images/4.jpg": "3ccfe4abbe6a7ef7dbee76dac2fe8cae",
"assets/assets/images/pp4.jpeg": "7c28be6fcc744493b444e2e2f2780fb6",
"assets/assets/images/5.jpg": "14b584f6510215744c842ecec53ba970",
"assets/assets/images/7.jpg": "9088cc49955bd8c33f691048cb20530f",
"assets/assets/images/pp8.jpeg": "d0dd7f0c189e8f66b7a8d0e724cf1c86",
"assets/assets/images/6.jpg": "53eb54c0a81a777c2c3b58f90efb7012",
"assets/assets/images/2.jpg": "ab92a0b9f2a2ef7d071af42c1405b5f4",
"assets/assets/images/pp18.jpg": "97f756b3e35223c6c3c500908860a51c",
"assets/assets/images/pp19.jpg": "36c1c11bdcca13c12fb143b5a92816fc",
"assets/assets/images/3.jpg": "6280dd0fba263a64f5fe87409d611564",
"assets/assets/images/1.jpg": "3584d05a61c23d7e61103f799afdd839",
"assets/assets/images/pp20.webp": "2e615572c812287a2ce5a6c5c2eeb64c",
"assets/assets/images/pp5.jpeg": "dfa53035b382e2208ab8bc9c424516c9",
"assets/assets/images/pp1.jpg": "e63901c18fe916029199d807700bc7a8",
"assets/assets/payment/default_google_pay_config.json": "87c60619f4d96570d8fabc84b2b8df7d",
"assets/assets/payment/default_apple_pay_config.json": "052e73a7cb537a80e9a95fb245db74bf",
"assets/assets/projects/proj1.jpg": "d3589cc0e3072bee02a8f21b8ca054b7",
"assets/assets/projects/proj2.jpg": "4532101cbc4fa9287b23d8a8bef98240",
"assets/assets/projects/proj3.jpg": "429ca102fab1b61fd8810a346c9d22dd",
"assets/assets/projects/proj6.jpg": "6132c384ffc957723ac3b4536e1f0e67",
"assets/assets/projects/proj4.jpg": "e05b53872f3f806bef0e380e84f85901",
"assets/assets/projects/gps-on.png": "bb6c2b38671ca69d1921b40f078a22f9",
"assets/assets/projects/naviagtion.png": "e703f698e6e2f00acbb7796500ad19aa",
"assets/assets/projects/proj5.jpg": "db33748a0e9ec59e17cd6e06476ede2d",
"assets/assets/projects/microphone.png": "7a9368e4d0ad437bcadbca6f5d1c13b5",
"assets/assets/projects/camera.png": "1658e71bd60a6214bb60931c20b53ec8",
"assets/assets/projects/play.png": "df1a49442d0ac40adafb0fc7ccb862b4",
"assets/assets/ktlogo_red.png": "a7cfedb609acbe6839fadc7362de62b5",
"assets/assets/avatar.png": "350c75397a0b27bd3914e9e677695221",
"assets/assets/video3.png": "f58ae1704d0a1267f3e2f19a422f75ea",
"assets/assets/video2.jpg": "a9f5c3d1db4bed91ffdf214de9a1b432",
"assets/assets/video.png": "905f027d1f078f21100de96895776054",
"assets/assets/files/people.csv": "a34b97e9eefb05a9b9dc3c67683b05e2",
"assets/assets/files/people.json": "84754b88d6ee403b85ea888516dcda65",
"assets/assets/avatar1.png": "4b1348334edf0dc74bd82eb6548746bb",
"assets/assets/ktlogo_white.png": "501548b8f111eafc595e4db0466c771f",
"assets/assets/green_marker.png": "de344922f0f713507114816cc753c264",
"assets/assets/analysis_options.png": "6287f511a924214f4a17176481f1fb76",
"assets/assets/intl_en.arb": "93a6336247e0f64436c657499623a415",
"assets/assets/gio.png": "37f30e1889dc11ebfffb341e31281357",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c"};
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
