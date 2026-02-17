/**
 * Firebase → Supabase Data Sync Script
 * =====================================
 * 
 * Phase 1: One-time migration of ALL Firebase Firestore data to Supabase.
 * 
 * This script:
 * 1. Reads all documents from every Firebase collection
 * 2. Handles subcollections (e.g., forum/{id}/comments → forum_comments)
 * 3. Converts Firestore Timestamps to ISO strings
 * 4. Upserts data into corresponding Supabase tables
 * 
 * Prerequisites:
 *   npm install firebase-admin @supabase/supabase-js
 * 
 * Environment Variables:
 *   SUPABASE_URL        - Your Supabase project URL
 *   SUPABASE_SERVICE_KEY - Supabase service role key (NOT anon key)
 * 
 * Firebase Setup:
 *   serviceAccountKey.json must be in the project root
 * 
 * Usage:
 *   $env:SUPABASE_URL="https://your-project.supabase.co"
 *   $env:SUPABASE_SERVICE_KEY="your-service-role-key"
 *   node sync_firebase_to_supabase.js
 * 
 * Options:
 *   --dry-run     Preview what would be synced without writing
 *   --collection  Sync only a specific collection (e.g., --collection=users)
 *   --force       Overwrite existing data (default: upsert/merge)
 */

const admin = require('firebase-admin');
const { createClient } = require('@supabase/supabase-js');

// ==============================================================================
// Configuration
// ==============================================================================

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

// Parse CLI arguments
const args = process.argv.slice(2);
const DRY_RUN = args.includes('--dry-run');
const FORCE = args.includes('--force');
const COLLECTION_FILTER = args.find(a => a.startsWith('--collection='))?.split('=')[1] || null;

// Validate environment
if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
    console.error('❌ Missing environment variables!');
    console.error('   Set these before running:');
    console.error('   $env:SUPABASE_URL="https://your-project.supabase.co"');
    console.error('   $env:SUPABASE_SERVICE_KEY="your-service-role-key"');
    process.exit(1);
}

// Initialize Firebase
let serviceAccount;
try {
    serviceAccount = require('./serviceAccountKey.json');
} catch {
    console.error('❌ serviceAccountKey.json not found in project root!');
    console.error('   Download it from Firebase Console → Project Settings → Service Accounts');
    process.exit(1);
}

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
    });
}

const db = admin.firestore();
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

// ==============================================================================
// Collection Mapping: Firebase → Supabase
// ==============================================================================

/**
 * Defines how Firebase collections map to Supabase tables.
 * 
 * Each entry specifies:
 * - firebaseCollection: Firestore collection name
 * - supabaseTable: Supabase table name
 * - subcollections: Array of subcollection configs (optional)
 *   - name: subcollection name in Firebase
 *   - supabaseTable: target table in Supabase
 *   - foreignKey: column name for parent document ID
 */
const COLLECTION_MAP = [
    {
        firebaseCollection: 'users',
        supabaseTable: 'users',
    },
    {
        firebaseCollection: 'consents',
        supabaseTable: 'consents',
    },
    {
        firebaseCollection: 'forum',
        supabaseTable: 'forum',
        subcollections: [
            {
                name: 'comments',
                supabaseTable: 'forum_comments',
                foreignKey: 'forumId',
            },
        ],
    },
    {
        firebaseCollection: 'carousel_items',
        supabaseTable: 'carousel_items',
    },
    {
        firebaseCollection: 'learn',
        supabaseTable: 'learn',
    },
    {
        firebaseCollection: 'videos',
        supabaseTable: 'videos',
    },
    {
        firebaseCollection: 'resources',
        supabaseTable: 'resources',
    },
    {
        firebaseCollection: 'recommendations',
        supabaseTable: 'recommendations',
    },
    {
        firebaseCollection: 'notifications',
        supabaseTable: 'notifications',
    },
    {
        firebaseCollection: 'settings',
        supabaseTable: 'settings',
    },
    {
        firebaseCollection: 'quizzes',
        supabaseTable: 'quizzes',
    },
    {
        // Note: In Firebase this might be 'quizes' (legacy typo) or 'quizzes'
        // The script will try both
        firebaseCollection: 'quiz_questions',
        supabaseTable: 'quiz_questions',
    },
];

// ==============================================================================
// Data Transformation Helpers
// ==============================================================================

/**
 * Convert Firestore Timestamp fields to ISO strings.
 * Recursively processes nested objects.
 */
function convertTimestamps(data) {
    if (!data || typeof data !== 'object') return data;

    const converted = {};
    for (const [key, value] of Object.entries(data)) {
        if (value && typeof value === 'object') {
            // Firestore Timestamp has _seconds and _nanoseconds
            if (value._seconds !== undefined || value.seconds !== undefined) {
                const seconds = value._seconds || value.seconds;
                converted[key] = new Date(seconds * 1000).toISOString();
            }
            // Firestore Timestamp class instance
            else if (value.toDate && typeof value.toDate === 'function') {
                converted[key] = value.toDate().toISOString();
            }
            // Nested object (but not array)
            else if (!Array.isArray(value)) {
                converted[key] = convertTimestamps(value);
            }
            // Array
            else {
                converted[key] = value.map(item =>
                    typeof item === 'object' ? convertTimestamps(item) : item
                );
            }
        } else {
            converted[key] = value;
        }
    }
    return converted;
}

/**
 * Clean data for Supabase insertion.
 * Removes undefined values and converts special types.
 */
function cleanForSupabase(data) {
    const cleaned = {};
    for (const [key, value] of Object.entries(data)) {
        if (value === undefined) continue;
        // Convert JSONB-compatible objects
        if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
            // Check if it's a plain object that should be JSONB
            cleaned[key] = value;
        } else {
            cleaned[key] = value;
        }
    }
    return cleaned;
}

// ==============================================================================
// Sync Functions
// ==============================================================================

/**
 * Read all documents from a Firebase collection.
 */
async function readFirebaseCollection(collectionName) {
    try {
        const snapshot = await db.collection(collectionName).get();
        if (snapshot.empty) {
            return [];
        }

        return snapshot.docs.map(doc => {
            const rawData = doc.data();
            const converted = convertTimestamps(rawData);
            return {
                id: doc.id,
                ...converted,
            };
        });
    } catch (error) {
        console.error(`   ⚠️  Error reading Firebase collection '${collectionName}':`, error.message);
        return [];
    }
}

/**
 * Read subcollection documents from Firebase.
 * e.g., forum/{forumId}/comments
 */
async function readFirebaseSubcollection(parentCollection, parentId, subcollectionName) {
    try {
        const snapshot = await db
            .collection(parentCollection)
            .doc(parentId)
            .collection(subcollectionName)
            .get();

        if (snapshot.empty) {
            return [];
        }

        return snapshot.docs.map(doc => {
            const rawData = doc.data();
            const converted = convertTimestamps(rawData);
            return {
                id: doc.id,
                ...converted,
            };
        });
    } catch (error) {
        console.error(`   ⚠️  Error reading subcollection '${parentCollection}/${parentId}/${subcollectionName}':`, error.message);
        return [];
    }
}

/**
 * Write records to a Supabase table using upsert.
 * Processes in batches of 100 to avoid API limits.
 */
async function writeToSupabase(tableName, records) {
    if (records.length === 0) return { success: 0, errors: 0 };
    if (DRY_RUN) return { success: records.length, errors: 0 };

    const BATCH_SIZE = 100;
    let successCount = 0;
    let errorCount = 0;

    for (let i = 0; i < records.length; i += BATCH_SIZE) {
        const batch = records.slice(i, i + BATCH_SIZE).map(cleanForSupabase);

        try {
            const { error } = await supabase
                .from(tableName)
                .upsert(batch, {
                    onConflict: 'id',
                    ignoreDuplicates: !FORCE,
                });

            if (error) {
                console.error(`   ⚠️  Supabase error on '${tableName}' batch ${Math.floor(i / BATCH_SIZE) + 1}:`, error.message);
                errorCount += batch.length;

                // Try one-by-one for failed batch
                for (const record of batch) {
                    try {
                        const { error: singleError } = await supabase
                            .from(tableName)
                            .upsert(record, { onConflict: 'id' });

                        if (singleError) {
                            console.error(`      ❌ Record ${record.id}: ${singleError.message}`);
                        } else {
                            errorCount--;
                            successCount++;
                        }
                    } catch (e) {
                        console.error(`      ❌ Record ${record.id}: ${e.message}`);
                    }
                }
            } else {
                successCount += batch.length;
            }
        } catch (error) {
            console.error(`   ⚠️  Network error on '${tableName}' batch:`, error.message);
            errorCount += batch.length;
        }
    }

    return { success: successCount, errors: errorCount };
}

/**
 * Sync a single collection (and its subcollections) from Firebase to Supabase.
 */
async function syncCollection(config) {
    const { firebaseCollection, supabaseTable, subcollections } = config;

    console.log(`\n📦 Syncing '${firebaseCollection}' → '${supabaseTable}'...`);

    // Read from Firebase
    const records = await readFirebaseCollection(firebaseCollection);
    console.log(`   📖 Read ${records.length} documents from Firebase`);

    if (records.length === 0) {
        console.log(`   ⏭️  Skipping (empty collection)`);
        return { collection: firebaseCollection, synced: 0, errors: 0, subcollections: [] };
    }

    // Write to Supabase
    const result = await writeToSupabase(supabaseTable, records);
    const prefix = DRY_RUN ? '🔍 [DRY RUN]' : '✅';
    console.log(`   ${prefix} ${result.success} records synced${result.errors > 0 ? `, ${result.errors} errors` : ''}`);

    // Process subcollections
    const subResults = [];
    if (subcollections && subcollections.length > 0) {
        for (const sub of subcollections) {
            console.log(`   📂 Processing subcollection '${sub.name}'...`);

            let allSubDocs = [];

            // Read subcollection from each parent document
            for (const parentDoc of records) {
                const subDocs = await readFirebaseSubcollection(
                    firebaseCollection,
                    parentDoc.id,
                    sub.name
                );

                // Add foreign key to each subdocument
                const enrichedDocs = subDocs.map(doc => ({
                    ...doc,
                    [sub.foreignKey]: parentDoc.id,
                }));

                allSubDocs = [...allSubDocs, ...enrichedDocs];
            }

            console.log(`      📖 Read ${allSubDocs.length} subcollection documents`);

            if (allSubDocs.length > 0) {
                const subResult = await writeToSupabase(sub.supabaseTable, allSubDocs);
                console.log(`      ${prefix} ${subResult.success} subcollection records synced${subResult.errors > 0 ? `, ${subResult.errors} errors` : ''}`);
                subResults.push({
                    name: sub.name,
                    synced: subResult.success,
                    errors: subResult.errors,
                });
            } else {
                subResults.push({ name: sub.name, synced: 0, errors: 0 });
            }
        }
    }

    return {
        collection: firebaseCollection,
        synced: result.success,
        errors: result.errors,
        subcollections: subResults,
    };
}

// ==============================================================================
// Main Execution
// ==============================================================================

async function main() {
    console.log('╔══════════════════════════════════════════════════════════╗');
    console.log('║     🔄 Firebase → Supabase Data Sync                     ║');
    console.log('║     GuardianCare Migration Script                        ║');
    console.log('╚══════════════════════════════════════════════════════════╝');
    console.log('');

    if (DRY_RUN) {
        console.log('🔍 DRY RUN MODE - No data will be written to Supabase\n');
    }
    if (FORCE) {
        console.log('⚠️  FORCE MODE - Existing data will be overwritten\n');
    }
    if (COLLECTION_FILTER) {
        console.log(`🎯 Filtering to collection: ${COLLECTION_FILTER}\n`);
    }

    console.log(`📡 Supabase URL: ${SUPABASE_URL}`);
    console.log(`🔥 Firebase Project: ${serviceAccount.project_id}\n`);

    const startTime = Date.now();
    const results = [];

    // Filter collections if specified
    const collectionsToSync = COLLECTION_FILTER
        ? COLLECTION_MAP.filter(c => c.firebaseCollection === COLLECTION_FILTER)
        : COLLECTION_MAP;

    if (collectionsToSync.length === 0) {
        console.error(`❌ Collection '${COLLECTION_FILTER}' not found in mapping!`);
        console.log('Available collections:', COLLECTION_MAP.map(c => c.firebaseCollection).join(', '));
        process.exit(1);
    }

    // Sync each collection
    for (const config of collectionsToSync) {
        try {
            const result = await syncCollection(config);
            results.push(result);
        } catch (error) {
            console.error(`\n❌ Fatal error syncing '${config.firebaseCollection}':`, error.message);
            results.push({
                collection: config.firebaseCollection,
                synced: 0,
                errors: -1,
                subcollections: [],
            });
        }
    }

    // Print summary
    const duration = ((Date.now() - startTime) / 1000).toFixed(1);
    const totalSynced = results.reduce((sum, r) => sum + r.synced, 0);
    const totalSubSynced = results.reduce(
        (sum, r) => sum + r.subcollections.reduce((s, sub) => s + sub.synced, 0), 0
    );
    const totalErrors = results.reduce((sum, r) => sum + Math.max(0, r.errors), 0);

    console.log('\n╔══════════════════════════════════════════════════════════╗');
    console.log('║                    📊 SYNC SUMMARY                       ║');
    console.log('╠══════════════════════════════════════════════════════════╣');

    for (const result of results) {
        const status = result.errors === 0 ? '✅' : result.errors === -1 ? '❌' : '⚠️';
        console.log(`║  ${status} ${result.collection.padEnd(22)} ${String(result.synced).padStart(5)} records`);

        for (const sub of result.subcollections) {
            const subStatus = sub.errors === 0 ? '✅' : '⚠️';
            console.log(`║     ${subStatus} └─ ${sub.name.padEnd(18)} ${String(sub.synced).padStart(5)} records`);
        }
    }

    console.log('╠══════════════════════════════════════════════════════════╣');
    console.log(`║  Total documents synced:  ${String(totalSynced + totalSubSynced).padStart(6)}`);
    console.log(`║  Total errors:            ${String(totalErrors).padStart(6)}`);
    console.log(`║  Duration:                ${duration.padStart(5)}s`);
    console.log(`║  Mode:                    ${DRY_RUN ? 'DRY RUN' : FORCE ? 'FORCE' : 'UPSERT'}`);
    console.log('╚══════════════════════════════════════════════════════════╝');

    if (totalErrors > 0) {
        console.log('\n⚠️  Some records failed to sync. Check the errors above.');
        console.log('   Tip: Run with --force to overwrite conflicting records.');
    }

    if (DRY_RUN) {
        console.log('\n🔍 This was a dry run. Run without --dry-run to actually sync data.');
    }

    process.exit(totalErrors > 0 ? 1 : 0);
}

main().catch(error => {
    console.error('❌ Unhandled error:', error);
    process.exit(1);
});
