-- Run once in Supabase SQL Editor, then enable Anonymous Sign-Ins in Auth settings.
alter table public.profiles add column if not exists username text;
alter table public.profiles add column if not exists home_state text;
update public.profiles set username='player_' || left(replace(id::text,'-',''),12) where username is null;
update public.profiles set home_state='Kerala' where home_state is null;
alter table public.profiles alter column username set not null;
alter table public.profiles alter column home_state set not null;
alter table public.profiles drop constraint if exists profiles_home_district_check;
alter table public.profiles drop constraint if exists profiles_gender_check;
alter table public.profiles drop constraint if exists profiles_username_format;
alter table public.profiles add constraint profiles_username_format check(username ~ '^[a-z0-9_]{3,20}$');
alter table public.profiles add constraint profiles_gender_check check(gender in('male','female','other'));
create unique index if not exists profiles_username_unique on public.profiles(lower(username));
alter table public.district_messages drop constraint if exists district_messages_room_check;
