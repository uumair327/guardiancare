-- ==========================================
-- GuardianCare Supabase Schema
-- ==========================================
-- Run this SQL in your Supabase Dashboard -> SQL Editor
-- After running, execute: node seed_supabase.js

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ==========================================
-- 1. USERS (Public Profiles)
-- ==========================================
create table if not exists public.users (
  "id" text primary key,
  "uid" text,
  "email" text,
  "displayName" text,
  "role" text,
  "photoURL" text,
  "emailVerified" boolean,
  "createdAt" text,
  "updatedAt" text
);
alter table public.users enable row level security;
create policy "Users read" on public.users for select using (true);
create policy "Users write" on public.users for insert with check (true);
create policy "Users update" on public.users for update using (true);

-- ==========================================
-- 2. CONSENTS
-- ==========================================
create table if not exists public.consents (
  "id" text primary key,
  "parentName" text,
  "parentEmail" text,
  "childName" text,
  "isChildAbove12" boolean,
  "parentalKey" text,
  "securityQuestion" text,
  "securityAnswer" text,
  "consentCheckboxes" jsonb,
  "timestamp" text,
  "createdAt" text,
  "updatedAt" text
);
alter table public.consents enable row level security;
create policy "Consents read" on public.consents for select using (true);
create policy "Consents write" on public.consents for insert with check (true);
create policy "Consents update" on public.consents for update using (true);

-- ==========================================
-- 3. FORUM
-- ==========================================
create table if not exists public.forum (
  "id" text primary key,
  "userId" text,
  "title" text,
  "description" text,
  "category" text,
  "createdAt" text,
  "updatedAt" text
);
alter table public.forum enable row level security;
create policy "Forum read" on public.forum for select using (true);
create policy "Forum write" on public.forum for insert with check (true);
create policy "Forum update" on public.forum for update using (true);

-- ==========================================
-- 4. FORUM COMMENTS (Subcollection)
-- ==========================================
create table if not exists public.forum_comments (
  "id" text primary key,
  "forumId" text,
  "userId" text,
  "text" text,
  "createdAt" text,
  "updatedAt" text
);
alter table public.forum_comments enable row level security;
create policy "Comments read" on public.forum_comments for select using (true);
create policy "Comments write" on public.forum_comments for insert with check (true);
create policy "Comments update" on public.forum_comments for update using (true);

-- ==========================================
-- 5. CAROUSEL ITEMS
-- ==========================================
create table if not exists public.carousel_items (
  "id" text primary key,
  "type" text,
  "imageUrl" text,
  "link" text,
  "thumbnailUrl" text,
  "content" jsonb,
  "order" integer,
  "isActive" boolean,
  "createdAt" text,
  "updatedAt" text
);
alter table public.carousel_items enable row level security;
create policy "Carousel read" on public.carousel_items for select using (true);
create policy "Carousel write" on public.carousel_items for insert with check (true);

-- ==========================================
-- 6. LEARN (Categories)
-- ==========================================
create table if not exists public.learn (
  "id" text primary key,
  "name" text,
  "thumbnail" text,
  "createdAt" text,
  "updatedAt" text
);
alter table public.learn enable row level security;
create policy "Learn read" on public.learn for select using (true);
create policy "Learn write" on public.learn for insert with check (true);

-- ==========================================
-- 7. VIDEOS
-- ==========================================
create table if not exists public.videos (
  "id" text primary key,
  "title" text,
  "videoUrl" text,
  "thumbnailUrl" text,
  "category" text,
  "description" text,
  "createdAt" text,
  "updatedAt" text
);
alter table public.videos enable row level security;
create policy "Videos read" on public.videos for select using (true);
create policy "Videos write" on public.videos for insert with check (true);

-- ==========================================
-- 8. RESOURCES
-- ==========================================
create table if not exists public.resources (
  "id" text primary key,
  "title" text,
  "description" text,
  "url" text,
  "type" text,
  "category" text,
  "timestamp" text,
  "createdAt" text,
  "updatedAt" text
);
alter table public.resources enable row level security;
create policy "Resources read" on public.resources for select using (true);
create policy "Resources write" on public.resources for insert with check (true);

-- ==========================================
-- 9. RECOMMENDATIONS
-- ==========================================
create table if not exists public.recommendations (
  "id" text primary key,
  "UID" text,
  "title" text,
  "thumbnail" text,
  "video" text,
  "timestamp" text,
  "createdAt" text,
  "updatedAt" text
);
alter table public.recommendations enable row level security;
create policy "Recommendations read" on public.recommendations for select using (true);
create policy "Recommendations write" on public.recommendations for insert with check (true);

-- ==========================================
-- 10. NOTIFICATIONS
-- ==========================================
create table if not exists public.notifications (
  "id" text primary key,
  "userId" text,
  "title" text,
  "message" text,
  "type" text,
  "read" boolean,
  "createdAt" text,
  "updatedAt" text
);
alter table public.notifications enable row level security;
create policy "Notifications read" on public.notifications for select using (true);
create policy "Notifications write" on public.notifications for insert with check (true);
create policy "Notifications update" on public.notifications for update using (true);

-- ==========================================
-- 11. SETTINGS
-- ==========================================
create table if not exists public.settings (
  "id" text primary key,
  "appName" text,
  "appVersion" text,
  "maintenanceMode" boolean,
  "contactEmail" text,
  "privacyPolicyUrl" text,
  "termsOfServiceUrl" text,
  "updatedAt" text,
  "createdAt" text
);
alter table public.settings enable row level security;
create policy "Settings read" on public.settings for select using (true);
create policy "Settings write" on public.settings for insert with check (true);

-- ==========================================
-- 12. QUIZZES
-- ==========================================
create table if not exists public.quizzes (
  "id" text primary key,
  "title" text,
  "description" text,
  "category" text,
  "difficulty" text,
  "questionCount" integer,
  "imageUrl" text,
  "createdAt" text,
  "updatedAt" text
);
alter table public.quizzes enable row level security;
create policy "Quizzes read" on public.quizzes for select using (true);
create policy "Quizzes write" on public.quizzes for insert with check (true);

-- ==========================================
-- 13. QUIZ QUESTIONS
-- ==========================================
create table if not exists public.quiz_questions (
  "id" text primary key,
  "quizId" text,
  "question" text,
  "options" jsonb,
  "correctAnswer" integer,
  "explanation" text,
  "createdAt" text,
  "updatedAt" text
);
alter table public.quiz_questions enable row level security;
create policy "Quiz questions read" on public.quiz_questions for select using (true);
create policy "Quiz questions write" on public.quiz_questions for insert with check (true);
