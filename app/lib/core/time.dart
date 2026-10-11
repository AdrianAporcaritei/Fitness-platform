import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Source of the current time; code must use this instead of `DateTime.now()`.
final nowProvider = Provider<DateTime Function()>((_) => DateTime.now);
