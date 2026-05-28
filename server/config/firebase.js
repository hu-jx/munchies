import admin from "firebase-admin";
import { config } from 'dotenv';
config({quiet: true})
import serviceAccount from "../munchies-auth-firebase-key.json" with {type: 'json'}
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

export const getAuth = admin.auth()
