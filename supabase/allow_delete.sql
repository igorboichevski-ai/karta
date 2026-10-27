-- Право удалять точки для отдельных сотрудников (не делая их админами).
-- Вставьте целиком в Supabase → SQL Editor → Run.
alter table public.profiles add column if not exists can_delete_places boolean not null default false;

create or replace function public.can_delete_places() returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.profiles where id = auth.uid() and (role = 'admin' or can_delete_places))
$$;

-- роль и право удаления меняет только админ
create or replace function public.protect_role() returns trigger language plpgsql security definer set search_path = public as $$
begin
  if (new.role is distinct from old.role or new.can_delete_places is distinct from old.can_delete_places)
     and auth.uid() is not null and not public.is_admin() then
    raise exception 'Менять роль и права может только администратор';
  end if;
  return new;
end $$;
drop trigger if exists profiles_protect_role on public.profiles;
create trigger profiles_protect_role before update on public.profiles for each row execute function public.protect_role();

drop policy if exists "admin deletes places" on public.places;
create policy "admin deletes places" on public.places for delete to authenticated using (public.can_delete_places());

-- выдать право сотруднику (подставьте его e-mail):
-- update public.profiles set can_delete_places = true
-- where id = (select id from auth.users where email = 'почта@сотрудника');
