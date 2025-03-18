import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get stripeSecretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? 'DEFAULT_STRIPE_SECRET_KEY';
}
