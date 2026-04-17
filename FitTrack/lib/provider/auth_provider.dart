import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  User? _user;
  bool _isLoading = false;

  /// ================= GETTERS =================

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  String get userId => _user?.id ?? "";
  String get userEmail => _user?.email ?? "";

  String get userName {
    final metadata = _user?.userMetadata;
    return metadata?['name'] ?? "User";
  }

  String get profileImage {
    final metadata = _user?.userMetadata;
    return metadata?['image'] ?? "";
  }

  /// ================= INIT =================

  AuthProvider() {
    _user = _client.auth.currentUser;

    _client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  /// ================= REGISTER =================

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'image': "",
        },
      );

      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Register failed";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ================= LOGIN =================

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _user = res.user;

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Login failed";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ================= LOGOUT =================

  Future<void> logout() async {
    await _client.auth.signOut();
    _user = null;
    notifyListeners();
  }

  /// ================= UPDATE PROFILE =================

  Future<void> updateName(String name) async {
    await _client.auth.updateUser(
      UserAttributes(data: {'name': name}),
    );
    _user = _client.auth.currentUser;
    notifyListeners();
  }

  Future<void> updateProfileImage(String imageUrl) async {
    await _client.auth.updateUser(
      UserAttributes(data: {'image': imageUrl}),
    );
    _user = _client.auth.currentUser;
    notifyListeners();
  }
}