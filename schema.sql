-- ตารางเก็บงานของ Todo List
-- วิธีใช้: เปิด Supabase → SQL Editor → วางทั้งไฟล์นี้ → กด Run

create table if not exists public.todos (
  id bigint generated always as identity primary key,
  -- เจ้าของงาน: ใส่ให้อัตโนมัติจากคนที่ล็อกอินอยู่
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null check (char_length(title) between 1 and 200),
  category text not null default 'other'
    check (category in ('learn', 'health', 'family', 'work', 'shop', 'other')),
  done boolean not null default false,
  done_at date,          -- วันที่ติ๊กเสร็จ ใช้นับสตรีค
  created_at timestamptz not null default now()
);

create index if not exists todos_user_id_idx on public.todos (user_id);

-- เปิด Row Level Security: ทุกคนเห็นและแก้ได้เฉพาะงานของตัวเอง
alter table public.todos enable row level security;

drop policy if exists "อ่านงานของตัวเอง" on public.todos;
create policy "อ่านงานของตัวเอง" on public.todos
  for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists "เพิ่มงานของตัวเอง" on public.todos;
create policy "เพิ่มงานของตัวเอง" on public.todos
  for insert to authenticated with check ((select auth.uid()) = user_id);

drop policy if exists "แก้งานของตัวเอง" on public.todos;
create policy "แก้งานของตัวเอง" on public.todos
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "ลบงานของตัวเอง" on public.todos;
create policy "ลบงานของตัวเอง" on public.todos
  for delete to authenticated using ((select auth.uid()) = user_id);
