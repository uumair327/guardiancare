/**
 * Firebase User Migration Script
 * 
 * This script exports users from the old Firebase project and imports them
 * to a new project. Run this BEFORE the old project is deleted.
 * 
 * Prerequisites:
 * 1. Node.js installed
 * 2. npm install firebase-admin
 * 3. Download service account JSON from both projects
 * 
 * Usage:
 * 1. Export: node migrate-users.js export
 * 2. Import: node migrate-users.js import
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Configuration - Update these paths
const OLD_PROJECT_SERVICE_ACCOUNT = './old-project-service-account.json';
const NEW_PROJECT_SERVICE_ACCOUNT = './new-project-service-account.json';
const USERS_EXPORT_FILE = './exported-users.json';

async function exportUsers() {
    console.log('🔄 Initializing old Firebase project...');

    const oldServiceAccount = require(OLD_PROJECT_SERVICE_ACCOUNT);
    admin.initializeApp({
        credential: admin.credential.cert(oldServiceAccount)
    });

    console.log('📤 Exporting users...');

    const users = [];
    let pageToken;

    do {
        const result = await admin.auth().listUsers(1000, pageToken);
        result.users.forEach(user => {
            users.push({
                uid: user.uid,
                email: user.email,
                emailVerified: user.emailVerified,
                displayName: user.displayName,
                photoURL: user.photoURL,
                disabled: user.disabled,
                metadata: {
                    creationTime: user.metadata.creationTime,
                    lastSignInTime: user.metadata.lastSignInTime
                },
                providerData: user.providerData.map(provider => ({
                    providerId: provider.providerId,
                    uid: provider.uid,
                    email: provider.email,
                    displayName: provider.displayName,
                    photoURL: provider.photoURL
                }))
            });
        });
        pageToken = result.pageToken;
        console.log(`  Exported ${users.length} users...`);
    } while (pageToken);

    fs.writeFileSync(USERS_EXPORT_FILE, JSON.stringify(users, null, 2));
    console.log(`✅ Exported ${users.length} users to ${USERS_EXPORT_FILE}`);

    await admin.app().delete();
}

async function importUsers() {
    console.log('🔄 Initializing new Firebase project...');

    const newServiceAccount = require(NEW_PROJECT_SERVICE_ACCOUNT);
    admin.initializeApp({
        credential: admin.credential.cert(newServiceAccount)
    });

    console.log('📥 Reading exported users...');
    const users = JSON.parse(fs.readFileSync(USERS_EXPORT_FILE, 'utf8'));

    console.log(`📝 Importing ${users.length} users...`);

    let successCount = 0;
    let failCount = 0;

    for (const user of users) {
        try {
            // Note: We can't import passwords - users will need to re-authenticate
            // For Google Sign-In users, this is seamless
            await admin.auth().importUsers([{
                uid: user.uid,
                email: user.email,
                emailVerified: user.emailVerified,
                displayName: user.displayName,
                photoURL: user.photoURL,
                disabled: user.disabled,
                providerData: user.providerData
            }]);
            successCount++;
        } catch (error) {
            console.error(`  ❌ Failed to import ${user.email}: ${error.message}`);
            failCount++;
        }
    }

    console.log(`\n✅ Import complete!`);
    console.log(`   Success: ${successCount}`);
    console.log(`   Failed: ${failCount}`);

    await admin.app().delete();
}

// Main execution
const command = process.argv[2];

if (command === 'export') {
    exportUsers().catch(console.error);
} else if (command === 'import') {
    importUsers().catch(console.error);
} else {
    console.log(`
Firebase User Migration Script

Usage:
  node migrate-users.js export    Export users from old project
  node migrate-users.js import    Import users to new project

Before running:
1. Download service account JSON from old project
2. Save as: ${OLD_PROJECT_SERVICE_ACCOUNT}
3. Download service account JSON from new project  
4. Save as: ${NEW_PROJECT_SERVICE_ACCOUNT}
`);
}
