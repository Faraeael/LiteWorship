import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/service_model.dart';
import '../providers/service_provider.dart';

class SchedulePanel extends ConsumerWidget {
  const SchedulePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(serviceScheduleProvider);
    final selectedIndex = ref.watch(selectedServiceItemIndexProvider);

    return Column(
      children: [
        Container(
          height: 48,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: LWSpacing.md),
          color: LWColors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("SERVICE SCHEDULE", style: TextStyle(fontWeight: FontWeight.bold, color: LWColors.textSecondary)),
              IconButton(onPressed: () => ref.read(serviceScheduleProvider.notifier).clear(), icon: const Icon(Icons.delete_sweep, size: 20))
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: schedule.isEmpty ? 
             const Center(child: Text("Schedule Empty", style: TextStyle(color: LWColors.textMuted))) :
             ReorderableListView.builder(
              itemCount: schedule.length,
              onReorder: (oldIndex, newIndex) {
                ref.read(serviceScheduleProvider.notifier).reorder(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = schedule[index];
                final isSelected = index == selectedIndex;
                
                return Container(
                  key: ValueKey(item.id),
                  color: isSelected ? LWColors.primaryDim.withOpacity(0.2) : null,
                  child: ListTile(
                    title: Text(item.title, style: TextStyle(
                      color: isSelected ? LWColors.primary : LWColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                    )),
                    subtitle: item.subtitle != null ? Text(item.subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                    leading: Icon(_getIconForType(item.type), color: isSelected ? LWColors.primary : LWColors.textMuted),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => ref.read(serviceScheduleProvider.notifier).removeItem(item.id),
                    ),
                    onTap: () {
                      ref.read(selectedServiceItemIndexProvider.notifier).state = index;
                    },
                  ),
                );
              },
            ),
        ),
      ],
    );
  }

  IconData _getIconForType(ServiceItemType type) {
    switch (type) {
      case ServiceItemType.song: return Icons.music_note;
      case ServiceItemType.scripture: return Icons.book;
      case ServiceItemType.media: return Icons.image;
      case ServiceItemType.text: return Icons.text_fields;
    }
  }
}
