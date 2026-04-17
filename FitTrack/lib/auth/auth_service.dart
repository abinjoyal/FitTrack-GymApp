import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  /// SIGN UP
  Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      final user = response.user;

      if (user != null) {
        /// Insert into profiles
        await _client.from('profiles').insert({
          'id': user.id,
          'name': name,
          'email': email,
          //'image': "",
        });
      }

      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }

  /// LOGIN
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Login failed");
    }
  }

  /// LOGOUT
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}