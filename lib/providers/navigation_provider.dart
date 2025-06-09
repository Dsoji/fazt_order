// lib/providers/navigation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to manage the selected tab index
final navigationProvider = StateProvider<int>((ref) => 0);
