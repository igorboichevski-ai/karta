-- Скрытие точек с карты: менеджер отмечает точку как отработанную, и она пропадает с карты
-- (видна только с галочкой «Показать скрытые»). Можно запускать повторно.
alter table public.places add column if not exists hidden boolean not null default false;
alter table public.places add column if not exists hidden_by uuid references public.profiles(id);
alter table public.places add column if not exists hidden_at timestamptz;
create index if not exists places_hidden_idx on public.places(hidden);
