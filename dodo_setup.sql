-- dodo(하고 싶은 것 일기) 테이블
-- 일기(dodo_entry, 하루 한 줄) · 하고 싶은 것(dodo_wish) · 일기↔하고 싶은 것 연결(dodo_entry_wish, 행 id 없음)

create table if not exists public.dodo_entry (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid(),
  day date not null,                       -- 일기 날짜(한국 시간)
  body text not null default '',           -- 본문
  started_at timestamptz,                  -- 쓰기 시작한 시각 (day는 이 시각에서 오전 7시 기준으로 나눔, 2026-11-27 추가)
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, day)
);

create table if not exists public.dodo_wish (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid(),
  text text not null,                      -- 하고 싶은 것
  done_on date,                            -- 이룬 날(도장), 비어 있으면 아직
  done_memo text not null default '',      -- 이룬 날 한 줄
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, text)
);

create table if not exists public.dodo_entry_wish (
  entry_id uuid not null references public.dodo_entry(id) on delete cascade,
  wish_id  uuid not null references public.dodo_wish(id)  on delete cascade,
  user_id  uuid not null default auth.uid(),
  pos integer not null default 0,          -- 그날 일기 안에서의 순서
  created_at timestamptz not null default now(),
  primary key (entry_id, wish_id)
);

create index if not exists dodo_entry_user_day on public.dodo_entry(user_id, day);
create index if not exists dodo_wish_user on public.dodo_wish(user_id);
create index if not exists dodo_entry_wish_wish on public.dodo_entry_wish(wish_id);
create index if not exists dodo_entry_wish_user on public.dodo_entry_wish(user_id);

alter table public.dodo_entry enable row level security;
alter table public.dodo_wish enable row level security;
alter table public.dodo_entry_wish enable row level security;

create policy "own rows" on public.dodo_entry for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "own rows" on public.dodo_wish for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "own rows" on public.dodo_entry_wish for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
