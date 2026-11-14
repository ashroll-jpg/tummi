-- Tummi shared crews. Paste this whole file into Supabase → SQL Editor → Run.
-- Safe to run again; it only creates what's missing and replaces the functions.

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.tummi_crews (
  code       text primary key,
  pass_hash  text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.tummi_docs (
  code       text not null references public.tummi_crews(code) on delete cascade,
  id         text not null,
  data       jsonb,                       -- null means deleted
  updated_at timestamptz not null default clock_timestamp(),
  primary key (code, id)
);
create index if not exists tummi_docs_updated on public.tummi_docs (code, updated_at);

-- Row level security on with no policies: nobody can read or write the tables directly.
-- All access goes through the functions below, which check the passcode.
alter table public.tummi_crews enable row level security;
alter table public.tummi_docs  enable row level security;
revoke all on public.tummi_crews, public.tummi_docs from anon, authenticated;

create or replace function public.tummi_check(p_code text, p_pass text)
returns void language plpgsql security definer set search_path = public, extensions as $$
declare h text;
begin
  select pass_hash into h from tummi_crews where code = lower(trim(p_code));
  if h is null or h <> crypt(p_pass, h) then
    perform pg_sleep(0.5);
    raise exception 'wrong crew name or passcode' using errcode = '28P01';
  end if;
end $$;

-- Create a crew (p_create = true) or check that it exists and the passcode is right.
create or replace function public.tummi_join(p_code text, p_pass text, p_create boolean)
returns text language plpgsql security definer set search_path = public, extensions as $$
declare c text := lower(trim(p_code));
begin
  if length(c) < 3 or length(c) > 40 then raise exception 'crew name must be 3–40 characters' using errcode = '22023'; end if;
  if p_create then
    if length(p_pass) < 6 then raise exception 'passcode must be at least 6 characters' using errcode = '22023'; end if;
    insert into tummi_crews(code, pass_hash) values (c, crypt(p_pass, gen_salt('bf')))
      on conflict (code) do nothing;
    if not found then raise exception 'that crew name is taken' using errcode = '23505'; end if;
    return 'created';
  end if;
  perform tummi_check(c, p_pass);
  return 'joined';
end $$;

-- Everything changed after p_since (all docs when p_since is null), plus the server time to use next.
create or replace function public.tummi_pull(p_code text, p_pass text, p_since timestamptz)
returns jsonb language plpgsql security definer set search_path = public, extensions as $$
declare c text := lower(trim(p_code)); now_ts timestamptz := clock_timestamp();
begin
  perform tummi_check(c, p_pass);
  return jsonb_build_object(
    'now', now_ts,
    'docs', coalesce((select jsonb_agg(jsonb_build_object('id', id, 'data', data))
                      from tummi_docs
                      where code = c and (p_since is null or updated_at > p_since)
                        and (p_since is not null or data is not null)), '[]'::jsonb));
end $$;

-- Save docs: [{"id": "...", "data": {...} or null to delete}, ...]
create or replace function public.tummi_push(p_code text, p_pass text, p_docs jsonb)
returns void language plpgsql security definer set search_path = public, extensions as $$
declare c text := lower(trim(p_code));
begin
  perform tummi_check(c, p_pass);
  insert into tummi_docs(code, id, data, updated_at)
    select c, d->>'id', case when jsonb_typeof(d->'data') = 'null' then null else d->'data' end, clock_timestamp()
    from jsonb_array_elements(p_docs) d
    where coalesce(d->>'id', '') <> ''
  on conflict (code, id) do update set data = excluded.data, updated_at = excluded.updated_at;
end $$;

revoke all on function public.tummi_check(text, text) from public, anon, authenticated;
grant execute on function public.tummi_join(text, text, boolean)      to anon, authenticated;
grant execute on function public.tummi_pull(text, text, timestamptz)  to anon, authenticated;
grant execute on function public.tummi_push(text, text, jsonb)        to anon, authenticated;
