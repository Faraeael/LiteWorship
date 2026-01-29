import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_model.dart';

class ServiceScheduleNotifier extends StateNotifier<List<ServiceItem>> {
  ServiceScheduleNotifier() : super([]);

  void addItem(ServiceItem item) {
    state = [...state, item];
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final items = [...state];
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    state = items;
  }
  
  void clear() {
    state = [];
  }
}

final serviceScheduleProvider =
    StateNotifierProvider<ServiceScheduleNotifier, List<ServiceItem>>((ref) {
  return ServiceScheduleNotifier();
});

// Selection state for the Service Schedule
// Selection state for the Service Schedule
final selectedServiceItemIndexProvider = StateProvider<int>((ref) => -1);

// JUKEBOX MODE: The currently active item (Direct Play)
final activeServiceItemProvider = StateProvider<ServiceItem?>((ref) => null);
