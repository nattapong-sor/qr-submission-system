// ==========================================================
// ตั้งค่าการเชื่อมต่อ Supabase
// หา 2 ค่านี้ได้จาก Supabase Dashboard > Project Settings > API
// ==========================================================
const SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";   // <-- แก้ตรงนี้
const SUPABASE_ANON_KEY = "YOUR-ANON-PUBLIC-KEY";           // <-- แก้ตรงนี้

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// เช็คว่าล็อกอินอยู่ไหม ถ้าไม่ได้ล็อกอินและไม่ได้อยู่หน้า index ให้เด้งกลับไปหน้า login
async function requireLogin() {
  const { data: { session } } = await supabaseClient.auth.getSession();
  if (!session) {
    window.location.href = "index.html";
    return null;
  }
  return session;
}

async function logout() {
  await supabaseClient.auth.signOut();
  window.location.href = "index.html";
}
