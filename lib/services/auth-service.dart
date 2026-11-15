
import '../main.dart';

class AuthService {
  // Create a new Supabase Auth user.
  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': name.trim()},
    );
  }

  // Sign in an existing user.
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Sign out the current user.
  static Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
