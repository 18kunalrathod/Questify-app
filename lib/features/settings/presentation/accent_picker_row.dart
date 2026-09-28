import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart' show accentColorProvider;

const accentPrefsKey = 'accent_color';

class AccentPickerRow extends ConsumerWidget {
  const AccentPickerRow({super.key});

  Future<void> _select(WidgetRef ref, AccentColor accent) async {
    ref.read(accentColorProvider.notifier).state = accent;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(accentPrefsKey, accent.name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(accentColorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final ringColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Accent color', style: TextStyle(fontSize: 13)),
              Text(selected.label, style: TextStyle(fontSize: 12, color: mutedColor)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: AccentColor.values.map((accent) {
              final color = isDark ? accent.darkValue : accent.lightValue;
              final isSelected = accent == selected;
              return Semantics(
                label: accent.label,
                button: true,
                selected: isSelected,
                child: GestureDetector(
                  onTap: () => _select(ref, accent),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? ringColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}