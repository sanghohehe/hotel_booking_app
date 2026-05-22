import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static late final SupabaseClient client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://vangrwbliciqgrkwgmou.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZhbmdyd2JsaWNpcWdya3dnbW91Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4MDIzODcsImV4cCI6MjA4MDM3ODM4N30.UGrKf9-I3cqo_IxW74gISlAki0xpJGrFPQndNeVEDYk',
    );
    client = Supabase.instance.client;
  }
}
