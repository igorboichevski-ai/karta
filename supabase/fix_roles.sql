-- Запрещает обычным сотрудникам самим назначать себе роль администратора.
-- Выполнить один раз: Supabase → SQL Editor → Run. Роль по-прежнему можно менять из SQL Editor и под админом.
create or replace function public.protect_role() returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.role is distinct from old.role and auth.uid() is not null and not public.is_admin() then
    raise exception 'Менять роль может только администратор';
  end if;
  return new;
end $$;
drop trigger if exists profiles_protect_role on public.profiles;
create trigger profiles_protect_role before update on public.profiles for each row execute function public.protect_role();
