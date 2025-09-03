import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BottomNavigationItem { feed, search, chat, resume, setting }

final bottomNavigationProvider =
    StateProvider((ref) => BottomNavigationItem.feed);
