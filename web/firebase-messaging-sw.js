// firebase-messaging-sw.js
// Import the Firebase SDK for web
importScripts('https://www.gstatic.com/firebasejs/10.1.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.1.0/firebase-messaging-compat.js');

const mm = "🥬🥬🥬 Firebase Messaging Service Worker 🥬🥬🥬 "

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config object.
// https://firebase.google.com/docs/web/setup#config-object
 console.log('${mm} 🔷 🔷 🔷 setting up Firebase ...');

const firebaseApp = firebase.initializeApp({
    apiKey: "AIzaSyAbBpkSCLwy2p4dimBjXNh5XXIiQSz9FnI",
    authDomain: "kasie-transie-4.firebaseapp.com",
    projectId: "kasie-transie-4",
    storageBucket: "kasie-transie-4.firebasestorage.app",
    messagingSenderId: "657690570978",
    appId: "1:657690570978:web:eb0213c719834e4a646ebb",
    measurementId: "G-HH2PQG54B2"
});
console.log(`${mm} firebaseApp: ${JSON.stringify(firebaseApp)}`);

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging(firebaseApp);
console.log(`${mm} messaging : ${JSON.stringify(messaging)}`);
const tok = messaging.getToken();
console.log(`🔷 🔷 🔷 Firebase token: ${tok}`);
// Customize notification here
//  const notificationTitle = payload.notification?.title || 'Background Message Title';
//  const notificationOptions = {
//    body: payload.notification?.body || 'Background Message Body',
//    icon: '/icons/icon-192x192.png', // Path to your app icon
//  };
//
//  // Show the notification
//  self.registration.showNotification(notificationTitle, notificationOptions);
// console.log('${mm} 🔷 🔷 🔷 setting up onMessage ...');
//
// messaging.onMessage( (payload) => {
//  console.log('🔷 🔷 🔷 Firebase onMessage fired: ${JSON.stringify(payload)} 🔷 🔷 calling Dart method?');
//      callDartMethod(payload);
//    });
//
// console.log('🔷 🔷 🔷 Firebase onMessage seems alright');
 // Optional:
  console.log('${mm} 🔷 🔷 🔷 setting up onBackgroundMessage ...');

 messaging.onBackgroundMessage((message) => {
   console.log("onBackgroundMessage", message);
 });

 console.log('🔷 🔷 🔷 Firebase onBackgroundMessage seems alright');
