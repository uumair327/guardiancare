/**
 * Firebase Complete Seed Data Script for GuardianCare
 * 
 * This script seeds ALL Firebase collections with properly structured data
 * matching the exact field names expected by the Dart models.
 * 
 * Run with: node seed_firebase_complete.js
 * 
 * Prerequisites:
 * 1. npm install firebase-admin
 * 2. serviceAccountKey.json must be in the project root
 */

const admin = require('firebase-admin');
const crypto = require('crypto');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'guardiancare-prod',
});

const db = admin.firestore();

// SHA-256 hash function matching Dart's crypto package
function hashKey(str) {
    return crypto.createHash('sha256').update(str).digest('hex');
}

async function seedDatabase() {
    console.log('🌱 GuardianCare Complete Database Seeding');
    console.log('=========================================\n');

    try {
        // ==================== 1. USERS ====================
        // Collection: users
        // Fields expected by UserDetailsModel: displayName, photoURL, email, role
        // Additional fields: uid, emailVerified, createdAt
        console.log('👥 1. Creating users collection...');
        const users = [
            {
                uid: 'demo_parent_001',
                email: 'parent1@example.com',
                displayName: 'Sarah Johnson',
                role: 'parent',
                photoURL: null,
                emailVerified: true,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            {
                uid: 'demo_parent_002',
                email: 'parent2@example.com',
                displayName: 'Michael Chen',
                role: 'parent',
                photoURL: null,
                emailVerified: true,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            {
                uid: 'demo_child_001',
                email: 'child1@example.com',
                displayName: 'Emma Johnson',
                role: 'child',
                photoURL: null,
                emailVerified: true,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            {
                uid: 'demo_admin_001',
                email: 'admin@guardiancare.app',
                displayName: 'Admin User',
                role: 'admin',
                photoURL: null,
                emailVerified: true,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            },
        ];

        for (const user of users) {
            await db.collection('users').doc(user.uid).set(user);
        }
        console.log('   ✅ Created 4 users\n');

        // ==================== 2. CONSENTS ====================
        // Collection: consents
        // Fields expected by ConsentModel (consent_model.dart):
        // - parentName, parentEmail, childName, isChildAbove12
        // - parentalKey (NOT parentalKeyHash), securityQuestion, securityAnswer (NOT securityAnswerHash)
        // - timestamp (Firestore Timestamp), consentCheckboxes (Map)
        console.log('📋 2. Creating consents collection...');
        const consents = [
            {
                parentName: 'Sarah Johnson',
                parentEmail: 'parent1@example.com',
                childName: 'Emma Johnson',
                isChildAbove12: false,
                parentalKey: hashKey('parent123'),
                securityQuestion: 'What is your pet\'s name?',
                securityAnswer: hashKey('fluffy'),
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                consentCheckboxes: {
                    parentConsentGiven: true,
                    termsAccepted: true,
                    privacyPolicyAccepted: true,
                    dataCollectionConsent: true,
                    ageVerified: true,
                },
            },
            {
                parentName: 'Michael Chen',
                parentEmail: 'parent2@example.com',
                childName: 'Lily Chen',
                isChildAbove12: true,
                parentalKey: hashKey('securekey456'),
                securityQuestion: 'What city were you born in?',
                securityAnswer: hashKey('beijing'),
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                consentCheckboxes: {
                    parentConsentGiven: true,
                    termsAccepted: true,
                    privacyPolicyAccepted: true,
                    dataCollectionConsent: true,
                    ageVerified: true,
                },
            },
        ];

        await db.collection('consents').doc('demo_parent_001').set(consents[0]);
        await db.collection('consents').doc('demo_parent_002').set(consents[1]);
        console.log('   ✅ Created 2 consents\n');

        // ==================== 3. FORUM ====================
        // Collection: forum
        // Fields expected by ForumModel (forum_model.dart):
        // - id, userId, title, description, category ('parent'|'children')
        // - createdAt: ISO8601 STRING (NOT Timestamp!)
        console.log('💬 3. Creating forum collection...');
        const now = new Date();
        const forumPosts = [
            {
                id: 'forum_parent_001',
                userId: 'demo_parent_001',
                title: 'Tips for teaching internet safety to young kids',
                description: 'I\'ve been looking for age-appropriate ways to explain online safety to my 8-year-old. Has anyone found good resources or strategies that work?',
                category: 'parent',
                createdAt: new Date(now.getTime() - 86400000).toISOString(),
            },
            {
                id: 'forum_parent_002',
                userId: 'demo_parent_002',
                title: 'Screen time management strategies',
                description: 'We\'ve been struggling with managing screen time at home. What approaches have worked for your families?',
                category: 'parent',
                createdAt: new Date(now.getTime() - 172800000).toISOString(),
            },
            {
                id: 'forum_parent_003',
                userId: 'demo_parent_001',
                title: 'Recommended parental control apps?',
                description: 'Looking for recommendations on parental control apps that are effective but not too invasive.',
                category: 'parent',
                createdAt: new Date(now.getTime() - 259200000).toISOString(),
            },
            {
                id: 'forum_child_001',
                userId: 'demo_child_001',
                title: 'What to do if a stranger messages you online?',
                description: 'Someone I don\'t know sent me a message asking personal questions. I didn\'t reply but I\'m not sure what to do next.',
                category: 'children',
                createdAt: new Date(now.getTime() - 43200000).toISOString(),
            },
            {
                id: 'forum_child_002',
                userId: 'demo_child_001',
                title: 'Cool safety tips I learned',
                description: 'Never share your password, don\'t click weird links, tell a grown-up if something feels wrong. What other tips do you know?',
                category: 'children',
                createdAt: new Date(now.getTime() - 129600000).toISOString(),
            },
        ];

        for (const post of forumPosts) {
            await db.collection('forum').doc(post.id).set(post);
        }
        console.log('   ✅ Created 5 forum posts\n');

        // ==================== 4. FORUM COMMENTS ====================
        // Collection: forum/{forumId}/comments
        // Fields expected by CommentModel:
        // - id, forumId, userId, text
        // - createdAt: ISO8601 STRING (NOT Timestamp!)
        console.log('💭 4. Creating forum comments...');
        const comments = [
            {
                id: 'comment_001',
                forumId: 'forum_parent_001',
                userId: 'demo_parent_002',
                text: 'We use the "traffic light" system - green for safe, yellow for "ask first", red for never!',
                createdAt: new Date(now.getTime() - 82800000).toISOString(),
            },
            {
                id: 'comment_002',
                forumId: 'forum_parent_001',
                userId: 'demo_admin_001',
                text: 'Check out our Learn section for age-appropriate videos on internet safety.',
                createdAt: new Date(now.getTime() - 79200000).toISOString(),
            },
            {
                id: 'comment_003',
                forumId: 'forum_parent_002',
                userId: 'demo_parent_001',
                text: 'We use a timer and have "device-free" zones like the dinner table.',
                createdAt: new Date(now.getTime() - 158400000).toISOString(),
            },
            {
                id: 'comment_004',
                forumId: 'forum_child_001',
                userId: 'demo_admin_001',
                text: 'You did the right thing by not replying! Always tell a trusted adult.',
                createdAt: new Date(now.getTime() - 36000000).toISOString(),
            },
            {
                id: 'comment_005',
                forumId: 'forum_child_002',
                userId: 'demo_parent_001',
                text: 'Great tips! Also: Never share your location or school name online.',
                createdAt: new Date(now.getTime() - 115200000).toISOString(),
            },
        ];

        for (const comment of comments) {
            await db.collection('forum').doc(comment.forumId)
                .collection('comments').doc(comment.id).set(comment);
        }
        console.log('   ✅ Created 5 forum comments\n');

        // ==================== 5. CAROUSEL ITEMS ====================
        // Collection: carousel_items
        // Fields expected by CarouselItemModel:
        // - type, imageUrl, link (REQUIRED - filter checks these)
        // - thumbnailUrl, content (Map), order, isActive
        console.log('📸 5. Creating carousel_items collection...');
        const carouselItems = [
            {
                type: 'image',
                imageUrl: 'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=800',
                link: '/learn',
                thumbnailUrl: 'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=200',
                content: {
                    title: 'Welcome to GuardianCare',
                    description: 'Your trusted companion for child safety education',
                },
                order: 1,
                isActive: true,
            },
            {
                type: 'image',
                imageUrl: 'https://images.unsplash.com/photo-1544776193-352d25ca82cd?w=800',
                link: '/learn',
                thumbnailUrl: 'https://images.unsplash.com/photo-1544776193-352d25ca82cd?w=200',
                content: {
                    title: 'Learn & Protect',
                    description: 'Educational resources for parents and guardians',
                },
                order: 2,
                isActive: true,
            },
            {
                type: 'image',
                imageUrl: 'https://images.unsplash.com/photo-1491013516836-7db643ee125a?w=800',
                link: '/quiz',
                thumbnailUrl: 'https://images.unsplash.com/photo-1491013516836-7db643ee125a?w=200',
                content: {
                    title: 'Take the Safety Quiz',
                    description: 'Test your knowledge about child safety',
                },
                order: 3,
                isActive: true,
            },
        ];

        let carouselIdx = 1;
        for (const item of carouselItems) {
            await db.collection('carousel_items').doc(`carousel_${carouselIdx}`).set(item);
            carouselIdx++;
        }
        console.log('   ✅ Created 3 carousel items\n');

        // ==================== 6. LEARN (Categories) ====================
        // Collection: learn
        // Fields expected by CategoryModel:
        // - name, thumbnail
        console.log('🎓 6. Creating learn (categories) collection...');
        const categories = [
            {
                name: 'Internet Safety',
                thumbnail: 'https://images.unsplash.com/photo-1488998527040-85054a85150e?w=400',
            },
            {
                name: 'Home Safety',
                thumbnail: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
            },
            {
                name: 'Stranger Danger',
                thumbnail: 'https://images.unsplash.com/photo-1491013516836-7db643ee125a?w=400',
            },
            {
                name: 'Emergency Response',
                thumbnail: 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=400',
            },
        ];

        let catIdx = 1;
        for (const cat of categories) {
            await db.collection('learn').doc(`category_${catIdx}`).set(cat);
            catIdx++;
        }
        console.log('   ✅ Created 4 learning categories\n');

        // ==================== 7. VIDEOS ====================
        // Collection: videos
        // Fields expected by VideoModel:
        // - title, videoUrl, thumbnailUrl, category, description (optional)
        console.log('🎬 7. Creating videos collection...');
        const videos = [
            {
                title: 'Introduction to Internet Safety',
                videoUrl: 'https://www.youtube.com/watch?v=yrln8nyVBLU',
                thumbnailUrl: 'https://img.youtube.com/vi/yrln8nyVBLU/maxresdefault.jpg',
                category: 'Internet Safety',
                description: 'Learn the basics of staying safe online.',
            },
            {
                title: 'Password Protection for Kids',
                videoUrl: 'https://www.youtube.com/watch?v=aEmF3Iylvr4',
                thumbnailUrl: 'https://img.youtube.com/vi/aEmF3Iylvr4/maxresdefault.jpg',
                category: 'Internet Safety',
                description: 'How to create and protect your passwords.',
            },
            {
                title: 'Home Safety Basics',
                videoUrl: 'https://www.youtube.com/watch?v=S6IgKZwUMss',
                thumbnailUrl: 'https://img.youtube.com/vi/S6IgKZwUMss/maxresdefault.jpg',
                category: 'Home Safety',
                description: 'Essential tips for staying safe at home.',
            },
            {
                title: 'Fire Safety for Kids',
                videoUrl: 'https://www.youtube.com/watch?v=fd0m8akl-EQ',
                thumbnailUrl: 'https://img.youtube.com/vi/fd0m8akl-EQ/maxresdefault.jpg',
                category: 'Home Safety',
                description: 'What to do in case of a fire emergency.',
            },
            {
                title: 'Stranger Danger Awareness',
                videoUrl: 'https://www.youtube.com/watch?v=F3TftvlKqGE',
                thumbnailUrl: 'https://img.youtube.com/vi/F3TftvlKqGE/maxresdefault.jpg',
                category: 'Stranger Danger',
                description: 'How to recognize and handle stranger situations.',
            },
            {
                title: 'Emergency 911 - When to Call',
                videoUrl: 'https://www.youtube.com/watch?v=gJCYcWVz1_4',
                thumbnailUrl: 'https://img.youtube.com/vi/gJCYcWVz1_4/maxresdefault.jpg',
                category: 'Emergency Response',
                description: 'Learn when and how to call emergency services.',
            },
        ];

        let vidIdx = 1;
        for (const video of videos) {
            await db.collection('videos').doc(`video_${vidIdx}`).set(video);
            vidIdx++;
        }
        console.log('   ✅ Created 6 videos\n');

        // ==================== 8. RESOURCES ====================
        // Collection: resources
        // Fields expected by ResourceModel:
        // - title (required), description, url, type, category, timestamp (Firestore Timestamp)
        console.log('📚 8. Creating resources collection...');
        const resources = [
            {
                title: 'Understanding Child Safety Online',
                description: 'A comprehensive guide for parents on keeping children safe online.',
                url: 'https://www.commonsensemedia.org/online-safety',
                type: 'article',
                category: 'education',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            },
            {
                title: 'Emergency Contacts Guide',
                description: 'Important numbers and contacts every parent should have.',
                url: 'https://guardiancare.app/emergency-guide',
                type: 'guide',
                category: 'emergency',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            },
            {
                title: 'NCMEC - National Center for Missing & Exploited Children',
                description: 'Official resource for child safety and missing children.',
                url: 'https://www.missingkids.org/',
                type: 'website',
                category: 'organization',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            },
            {
                title: 'Family Online Safety Institute',
                description: 'Resources for families about online safety.',
                url: 'https://www.fosi.org/',
                type: 'website',
                category: 'education',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            },
        ];

        let resIdx = 1;
        for (const resource of resources) {
            await db.collection('resources').doc(`resource_${resIdx}`).set(resource);
            resIdx++;
        }
        console.log('   ✅ Created 4 resources\n');

        // ==================== 9. RECOMMENDATIONS ====================
        // Collection: recommendations
        // Fields expected by RecommendationModel:
        // - UID (userId), title, thumbnail, video (videoUrl), timestamp (Firestore Timestamp)
        console.log('⭐ 9. Creating recommendations collection...');
        const recommendations = [
            {
                UID: 'demo_parent_001',
                title: 'Recommended: Internet Safety Basics',
                thumbnail: 'https://img.youtube.com/vi/yrln8nyVBLU/maxresdefault.jpg',
                video: 'https://www.youtube.com/watch?v=yrln8nyVBLU',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            },
            {
                UID: 'demo_parent_001',
                title: 'Recommended: Home Safety for Families',
                thumbnail: 'https://img.youtube.com/vi/S6IgKZwUMss/maxresdefault.jpg',
                video: 'https://www.youtube.com/watch?v=S6IgKZwUMss',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            },
            {
                UID: 'demo_child_001',
                title: 'Watch: What is Stranger Danger?',
                thumbnail: 'https://img.youtube.com/vi/F3TftvlKqGE/maxresdefault.jpg',
                video: 'https://www.youtube.com/watch?v=F3TftvlKqGE',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            },
        ];

        let recIdx = 1;
        for (const rec of recommendations) {
            await db.collection('recommendations').doc(`rec_${recIdx}`).set(rec);
            recIdx++;
        }
        console.log('   ✅ Created 3 recommendations\n');

        // ==================== 10. NOTIFICATIONS ====================
        console.log('🔔 10. Creating notifications collection...');
        const notifications = [
            {
                userId: 'demo_parent_001',
                title: 'Welcome to GuardianCare!',
                message: 'Thank you for joining. Explore our resources to learn about child safety.',
                type: 'welcome',
                read: false,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            {
                userId: 'demo_parent_001',
                title: 'New comment on your post',
                message: 'Someone replied to your forum post about internet safety tips.',
                type: 'forum',
                read: false,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            },
        ];

        let notifIdx = 1;
        for (const notif of notifications) {
            await db.collection('notifications').doc(`notif_${notifIdx}`).set(notif);
            notifIdx++;
        }
        console.log('   ✅ Created 2 notifications\n');

        // ==================== 11. APP SETTINGS ====================
        console.log('⚙️  11. Creating settings collection...');
        const settings = {
            appName: 'GuardianCare',
            appVersion: '1.0.0',
            maintenanceMode: false,
            contactEmail: 'support@guardiancare.app',
            privacyPolicyUrl: 'https://guardiancare.app/privacy',
            termsOfServiceUrl: 'https://guardiancare.app/terms',
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        await db.collection('settings').doc('app_config').set(settings);
        console.log('   ✅ Created app settings\n');

        // ==================== SUMMARY ====================
        console.log('=========================================');
        console.log('🎉 DATABASE SEEDING COMPLETED SUCCESSFULLY!');
        console.log('=========================================\n');
        console.log('Collections created:');
        console.log('  ├── users              (4 documents)');
        console.log('  ├── consents           (2 documents)');
        console.log('  ├── forum              (5 documents)');
        console.log('  │   └── comments       (5 documents total)');
        console.log('  ├── carousel_items     (3 documents)');
        console.log('  ├── learn              (4 documents)');
        console.log('  ├── videos             (6 documents)');
        console.log('  ├── resources          (4 documents)');
        console.log('  ├── recommendations    (3 documents)');
        console.log('  ├── notifications      (2 documents)');
        console.log('  └── settings           (1 document)');
        console.log('\n⚠️  Demo parental keys for testing:');
        console.log('  • demo_parent_001: parent123');
        console.log('  • demo_parent_002: securekey456');

    } catch (error) {
        console.error('❌ Error seeding database:', error);
        process.exit(1);
    }

    process.exit(0);
}

seedDatabase();
