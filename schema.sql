-- ==========================================================
-- ระบบสแกน QR บันทึกการส่งชิ้นงาน — Supabase schema
-- วิธีใช้: ไปที่ Supabase Dashboard > SQL Editor > New query
-- แล้ววาง SQL นี้ทั้งหมด กด Run
-- ==========================================================

-- 1) ตารางนักเรียน
create table students (
  id uuid primary key default gen_random_uuid(),
  student_code text unique not null,   -- รหัสที่เข้ารหัสอยู่ใน QR
  full_name text not null,
  classroom text,                       -- เช่น "ม.2/1"
  created_at timestamptz default now()
);

-- 2) ตารางวิชา (ครูคนไหนก็สร้างได้ ทุกคนเห็นร่วมกัน)
create table subjects (
  id uuid primary key default gen_random_uuid(),
  name text not null,                   -- เช่น "วิทยาศาสตร์ ม.2"
  created_by uuid references auth.users(id),
  created_at timestamptz default now()
);

-- 3) ตารางชิ้นงาน/ใบงาน ในแต่ละวิชา
create table assignments (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid references subjects(id) on delete cascade,
  name text not null,                   -- เช่น "ใบงานที่ 3: ระบบสุริยะ"
  term text,                            -- เช่น "เทอม 1/2569"
  created_at timestamptz default now()
);

-- 4) ตารางบันทึกการสแกน (แต่ละแถว = นักเรียน 1 คน ส่งชิ้นงาน 1 ชิ้น)
create table submissions (
  id uuid primary key default gen_random_uuid(),
  student_id uuid references students(id) on delete cascade,
  assignment_id uuid references assignments(id) on delete cascade,
  scanned_by uuid references auth.users(id),
  scanned_at timestamptz default now(),
  unique (student_id, assignment_id)    -- กันสแกนซ้ำชิ้นงานเดิม
);

-- ==========================================================
-- Row Level Security: ครูทุกคนที่ล็อกอินแล้ว อ่าน/เขียนได้หมด
-- (ระบบนี้ออกแบบให้ครูใช้งานร่วมกันทั้งโรงเรียน)
-- ==========================================================
alter table students enable row level security;
alter table subjects enable row level security;
alter table assignments enable row level security;
alter table submissions enable row level security;

create policy "teachers can do everything - students"
  on students for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "teachers can do everything - subjects"
  on subjects for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "teachers can do everything - assignments"
  on assignments for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "teachers can do everything - submissions"
  on submissions for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');
