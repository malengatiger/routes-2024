import { initializeApp } from "firebase/app";
import { getMessaging } from "firebase/messaging/sw";

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config object.
// https://firebase.google.com/docs/web/setup#config-object
const firebaseApp = initializeApp({
  apiKey: "AIzaSyAbBpkSCLwy2p4dimBjXNh5XXIiQSz9FnI",
    authDomain: "kasie-transie-4.firebaseapp.com",
    projectId: "kasie-transie-4",
    storageBucket: "kasie-transie-4.firebasestorage.app",
    messagingSenderId: "657690570978",
    appId: "1:657690570978:web:eb0213c719834e4a646ebb",
    measurementId: "G-HH2PQG54B2"
});
console.log(`firebaseApp: ${firebaseApp}`)
// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = getMessaging(firebaseApp);
