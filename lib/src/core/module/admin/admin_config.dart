const adminEmails = <String>{
  // Đổi thành email Supabase account 
  'sanghoadmin@gmail.com',
  // có thể thêm nhiều email admin khác
  // 'another_admin@example.com',
};

bool isAdminEmail(String? email) {
  if (email == null) return false;
  return adminEmails.contains(email.toLowerCase());
}
