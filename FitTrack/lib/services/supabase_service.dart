import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  /// 🔥 INIT FUNCTION
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://urtfilqjfrqxiimuvohv.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVydGZpbHFqZnJxeGlpbXV2b2h2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE4NTAwMTcsImV4cCI6MjA4NzQyNjAxN30.NQosB628nDcOB1ZsYkk7Xts8zzIsgqBeMx2WFmdruMY',
    );
  }
}