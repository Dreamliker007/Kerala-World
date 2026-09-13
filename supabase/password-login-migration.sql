-- Run once in Supabase SQL Editor for email/password accounts and points.
alter table public.profiles add column if not exists points integer not null default 0;
alter table public.profiles drop constraint if exists profiles_points_check;
alter table public.profiles add constraint profiles_points_check check(points>=0);

create or replace function public.create_player_profile()
returns trigger
language plpgsql
security definer set search_path=public
as $$
begin
  insert into public.profiles(id,username,name,home_state,home_district,gender)
  values(
    new.id,
    lower(new.raw_user_meta_data->>'username'),
    new.raw_user_meta_data->>'name',
    new.raw_user_meta_data->>'home_state',
    new.raw_user_meta_data->>'home_district',
    coalesce(new.raw_user_meta_data->>'gender','other')
  );
  return new;
end;
$$;

drop trigger if exists create_player_after_signup on auth.users;
create trigger create_player_after_signup
after insert on auth.users
for each row execute procedure public.create_player_profile();
