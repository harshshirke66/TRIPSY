-- Profiles table linked to Supabase Auth
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique,
  full_name text,
  avatar_url text,
  images text[] default '{}',
  bio text,
  gender text,
  travel_interests text[] default '{}',
  destination_preferences text[] default '{}',
  budget_style text, -- 'backpacker', 'budget', 'moderate', 'luxury'
  languages text[] default '{}',
  personality_tags text[] default '{}',
  is_verified boolean default false,
  latitude double precision,
  longitude double precision,
  social_links jsonb default '{}'::jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Swipes table
create table if not exists public.swipes (
  id uuid default gen_random_uuid() primary key,
  swiper_id uuid references public.profiles(id) on delete cascade not null,
  swiped_id uuid references public.profiles(id) on delete cascade not null,
  direction text check (direction in ('like', 'pass', 'super')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (swiper_id, swiped_id)
);

-- Matches table
create table if not exists public.matches (
  id uuid default gen_random_uuid() primary key,
  user1_id uuid references public.profiles(id) on delete cascade not null,
  user2_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (user1_id, user2_id)
);

-- Chat Channels (1-to-1 or group)
create table if not exists public.chats (
  id uuid default gen_random_uuid() primary key,
  name text, -- populated if group chat
  is_group boolean default false,
  cover_image text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Chat Members
create table if not exists public.chat_members (
  chat_id uuid references public.chats(id) on delete cascade not null,
  profile_id uuid references public.profiles(id) on delete cascade not null,
  joined_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (chat_id, profile_id)
);

-- Messages
create table if not exists public.messages (
  id uuid default gen_random_uuid() primary key,
  chat_id uuid references public.chats(id) on delete cascade not null,
  sender_id uuid references public.profiles(id) on delete cascade not null,
  content text,
  image_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Trip Rooms (Group travel planning)
create table if not exists public.trip_rooms (
  id uuid default gen_random_uuid() primary key,
  creator_id uuid references public.profiles(id) on delete cascade not null,
  title text not null,
  description text,
  destination text not null,
  start_date date,
  end_date date,
  budget numeric,
  cover_image text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Trip Members
create table if not exists public.trip_members (
  trip_id uuid references public.trip_rooms(id) on delete cascade not null,
  profile_id uuid references public.profiles(id) on delete cascade not null,
  role text default 'member' check (role in ('admin', 'member')),
  joined_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (trip_id, profile_id)
);

-- Trip Expenses (Splitwise-style)
create table if not exists public.trip_expenses (
  id uuid default gen_random_uuid() primary key,
  trip_id uuid references public.trip_rooms(id) on delete cascade not null,
  paid_by uuid references public.profiles(id) on delete cascade not null,
  amount numeric not null,
  description text not null,
  split_type text default 'equal', -- 'equal', 'custom'
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Trip Itinerary (Timeline)
create table if not exists public.trip_itinerary (
  id uuid default gen_random_uuid() primary key,
  trip_id uuid references public.trip_rooms(id) on delete cascade not null,
  day_number integer not null,
  time_of_day text,
  title text not null,
  description text,
  location_name text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Stories (Visual reels / posts)
create table if not exists public.stories (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references public.profiles(id) on delete cascade not null,
  media_url text not null,
  caption text,
  location_name text,
  likes_count integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Notifications
create table if not exists public.notifications (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references public.profiles(id) on delete cascade not null,
  title text not null,
  body text not null,
  type text check (type in ('match', 'message', 'trip', 'system')),
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for Security
alter table public.profiles enable row level security;
alter table public.swipes enable row level security;
alter table public.matches enable row level security;
alter table public.chats enable row level security;
alter table public.chat_members enable row level security;
alter table public.messages enable row level security;
alter table public.trip_rooms enable row level security;
alter table public.trip_members enable row level security;
alter table public.trip_expenses enable row level security;
alter table public.trip_itinerary enable row level security;
alter table public.stories enable row level security;
alter table public.notifications enable row level security;

-- Setup basic public policies
drop policy if exists "Public profiles are viewable by everyone" on public.profiles;
create policy "Public profiles are viewable by everyone" on public.profiles for select using (true);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile" on public.profiles for update using (auth.uid() = id);

drop policy if exists "Users can insert their own profile" on public.profiles;
create policy "Users can insert their own profile" on public.profiles for insert with check (auth.uid() = id);

drop policy if exists "Users can view their own swipes" on public.swipes;
create policy "Users can view their own swipes" on public.swipes for select using (auth.uid() = swiper_id);

drop policy if exists "Users can insert their own swipes" on public.swipes;
create policy "Users can insert their own swipes" on public.swipes for insert with check (auth.uid() = swiper_id);

drop policy if exists "Users can view matches they are part of" on public.matches;
create policy "Users can view matches they are part of" on public.matches for select using (auth.uid() = user1_id or auth.uid() = user2_id);

drop policy if exists "Users can insert matches they are part of" on public.matches;
create policy "Users can insert matches they are part of" on public.matches for insert with check (auth.uid() = user1_id or auth.uid() = user2_id);

drop policy if exists "Users can view chats they are members of" on public.chats;
create policy "Users can view chats they are members of" on public.chats for select using (
  exists (select 1 from public.chat_members where chat_id = id and profile_id = auth.uid())
);

drop policy if exists "Anyone authenticated can create chats" on public.chats;
create policy "Anyone authenticated can create chats" on public.chats for insert with check (true);

drop policy if exists "Users can insert chat membership details" on public.chat_members;
create policy "Users can insert chat membership details" on public.chat_members for insert with check (auth.uid() = profile_id);

drop policy if exists "Users can view messages for their active chats" on public.messages;
create policy "Users can view messages for their active chats" on public.messages for select using (
  exists (select 1 from public.chat_members where chat_id = messages.chat_id and profile_id = auth.uid())
);

drop policy if exists "Users can insert messages into their chats" on public.messages;
create policy "Users can insert messages into their chats" on public.messages for insert with check (
  auth.uid() = sender_id and
  exists (select 1 from public.chat_members where chat_id = messages.chat_id and profile_id = auth.uid())
);

drop policy if exists "Users can view trip rooms they belong to" on public.trip_rooms;
create policy "Users can view trip rooms they belong to" on public.trip_rooms for select using (
  exists (select 1 from public.trip_members where trip_id = id and profile_id = auth.uid()) or creator_id = auth.uid()
);

drop policy if exists "Users can create trip rooms" on public.trip_rooms;
create policy "Users can create trip rooms" on public.trip_rooms for insert with check (auth.uid() = creator_id);

drop policy if exists "Members can view trip details" on public.trip_members;
create policy "Members can view trip details" on public.trip_members for select using (
  exists (select 1 from public.trip_members as m where m.trip_id = trip_id and m.profile_id = auth.uid()) or
  exists (select 1 from public.trip_rooms as r where r.id = trip_id and r.creator_id = auth.uid())
);

drop policy if exists "Members can join trip rooms" on public.trip_members;
create policy "Members can join trip rooms" on public.trip_members for insert with check (auth.uid() = profile_id);

drop policy if exists "Members can view expenses in trip" on public.trip_expenses;
create policy "Members can view expenses in trip" on public.trip_expenses for select using (
  exists (select 1 from public.trip_members where trip_id = trip_expenses.trip_id and profile_id = auth.uid())
);

drop policy if exists "Members can add expenses to trip" on public.trip_expenses;
create policy "Members can add expenses to trip" on public.trip_expenses for insert with check (
  auth.uid() = paid_by and
  exists (select 1 from public.trip_members where trip_id = trip_expenses.trip_id and profile_id = auth.uid())
);

drop policy if exists "Members can view itinerary" on public.trip_itinerary;
create policy "Members can view itinerary" on public.trip_itinerary for select using (
  exists (select 1 from public.trip_members where trip_id = trip_itinerary.trip_id and profile_id = auth.uid())
);

drop policy if exists "Members can add itinerary items" on public.trip_itinerary;
create policy "Members can add itinerary items" on public.trip_itinerary for insert with check (
  exists (select 1 from public.trip_members where trip_id = trip_itinerary.trip_id and profile_id = auth.uid())
);

drop policy if exists "Stories are viewable by everyone" on public.stories;
create policy "Stories are viewable by everyone" on public.stories for select using (true);

drop policy if exists "Users can publish stories" on public.stories;
create policy "Users can publish stories" on public.stories for insert with check (auth.uid() = profile_id);

drop policy if exists "Users can view their notifications" on public.notifications;
create policy "Users can view their notifications" on public.notifications for select using (auth.uid() = profile_id);

drop policy if exists "Users can update their notifications" on public.notifications;
create policy "Users can update their notifications" on public.notifications for update using (auth.uid() = profile_id);

-- Trigger function to automatically copy new users to the profiles table
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (
    id,
    username,
    full_name,
    avatar_url,
    bio,
    gender,
    travel_interests,
    destination_preferences,
    budget_style,
    languages,
    personality_tags,
    is_verified,
    latitude,
    longitude,
    social_links
  )
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'username',
      split_part(new.email, '@', 1) || '_' || substr(md5(random()::text), 1, 6)
    ),
    coalesce(
      new.raw_user_meta_data->>'full_name',
      split_part(new.email, '@', 1)
    ),
    coalesce(
      new.raw_user_meta_data->>'avatar_url',
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150'
    ),
    'Hello! I am new to Tripsy.',
    coalesce(
      new.raw_user_meta_data->>'gender',
      'Not specified'
    ),
    array[]::text[],
    array[]::text[],
    'moderate',
    array['English']::text[],
    array[]::text[],
    false,
    0.0,
    0.0,
    '{}'::jsonb
  );
  return new;
end;
$$ language plpgsql security definer;

-- Recreate trigger to invoke handle_new_user on auth.users inserts
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
