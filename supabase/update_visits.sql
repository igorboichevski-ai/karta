-- Визиты менеджеров к точкам и отчёт по ним. Выполнить один раз: Supabase → SQL Editor → Run.
create table if not exists public.visits (
  id bigserial primary key,
  place_id bigint not null references public.places(id) on delete cascade,
  author uuid not null default auth.uid() references public.profiles(id),
  visited_at timestamptz not null default now(),
  result text not null,
  contact_name text, contact_phone text,
  products text, volume text,
  next_step text, next_date date,
  notes text,
  lat double precision, lon double precision,
  created_at timestamptz default now()
);
create index if not exists visits_place_idx on public.visits(place_id);
create index if not exists visits_date_idx on public.visits(visited_at);
alter table public.visits enable row level security;
drop policy if exists "team reads visits" on public.visits;
create policy "team reads visits" on public.visits for select to authenticated using (true);
drop policy if exists "own visits insert" on public.visits;
create policy "own visits insert" on public.visits for insert to authenticated with check (author = auth.uid());
drop policy if exists "author or admin edits visits" on public.visits;
create policy "author or admin edits visits" on public.visits for update to authenticated using (author = auth.uid() or public.is_admin());
drop policy if exists "author or admin deletes visits" on public.visits;
create policy "author or admin deletes visits" on public.visits for delete to authenticated using (author = auth.uid() or public.is_admin());
