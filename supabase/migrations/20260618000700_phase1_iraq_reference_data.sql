insert into public.countries (
  id,
  name,
  iso_code,
  is_active
)
values (
  '00000000-0000-4000-8000-000000000368',
  'Iraq',
  'IQ',
  true
)
on conflict (iso_code) do update
set
  name = excluded.name,
  is_active = excluded.is_active,
  updated_at = now();
