import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../providers/locale_provider.dart';

class LanguageSelector extends ConsumerWidget {
  final bool showAsDialog;
  final bool showAsDropdown;
  final bool showAsListTile;

  const LanguageSelector({
    super.key,
    this.showAsDialog = false,
    this.showAsDropdown = false,
    this.showAsListTile = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocaleAsync = ref.watch(localeProvider);
    final currentLocale = currentLocaleAsync.value ?? const Locale('en');
    final currentLocaleInfo = getLocaleInfo(currentLocale);

    if (showAsDialog) {
      return IconButton(
        icon: const Icon(Icons.language),
        onPressed: () => _showLanguageDialog(context, ref),
        tooltip: 'change_language'.tr(),
      );
    }

    if (showAsDropdown) {
      return DropdownButton<Locale>(
        value: currentLocale,
        items: availableLocales.map((localeInfo) {
          return DropdownMenuItem<Locale>(
            value: localeInfo.locale,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(localeInfo.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(localeInfo.nativeName),
              ],
            ),
          );
        }).toList(),
        onChanged: (locale) {
          if (locale != null) {
            _changeLanguage(context, ref, locale);
          }
        },
      );
    }

    if (showAsListTile) {
      return ListTile(
        leading: const Icon(Icons.language),
        title: Text('language'.tr()),
        subtitle: Text(currentLocaleInfo.nativeName),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showLanguageDialog(context, ref),
      );
    }

    // Default: Show as button
    return ElevatedButton.icon(
      onPressed: () => _showLanguageDialog(context, ref),
      icon: const Icon(Icons.language),
      label: Text(currentLocaleInfo.nativeName),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('change_language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableLocales.map((localeInfo) {
            final isSelected = ref.watch(localeProvider) == localeInfo.locale;
            return ListTile(
              leading: Text(
                localeInfo.flag,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(localeInfo.nativeName),
              subtitle: Text(localeInfo.name),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                _changeLanguage(context, ref, localeInfo.locale);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
        ],
      ),
    );
  }

  void _changeLanguage(BuildContext context, WidgetRef ref, Locale locale) {
    // Update the locale provider
    ref.read(localeProvider.notifier).changeLocale(locale);

    // Update EasyLocalization context
    context.setLocale(locale);
  }
}

// Compact language selector for app bars
class CompactLanguageSelector extends ConsumerWidget {
  const CompactLanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocaleAsync = ref.watch(localeProvider);
    final currentLocale = currentLocaleAsync.value ?? const Locale('en');
    final currentLocaleInfo = getLocaleInfo(currentLocale);

    return PopupMenuButton<Locale>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(currentLocaleInfo.flag, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
      onSelected: (locale) {
        ref.read(localeProvider.notifier).changeLocale(locale);
        context.setLocale(locale);
      },
      itemBuilder: (context) => availableLocales.map((localeInfo) {
        final isSelected = ref.watch(localeProvider) == localeInfo.locale;
        return PopupMenuItem<Locale>(
          value: localeInfo.locale,
          child: Row(
            children: [
              Text(localeInfo.flag, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(localeInfo.nativeName),
              if (isSelected) ...[
                const Spacer(),
                const Icon(Icons.check, size: 16, color: Colors.blue),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Language selector for bottom sheets
class LanguageSelectorBottomSheet extends ConsumerWidget {
  const LanguageSelectorBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'change_language'.tr(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...availableLocales.map((localeInfo) {
            final isSelected = ref.watch(localeProvider) == localeInfo.locale;
            return ListTile(
              leading: Text(
                localeInfo.flag,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(localeInfo.nativeName),
              subtitle: Text(localeInfo.name),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                ref
                    .read(localeProvider.notifier)
                    .changeLocale(localeInfo.locale);
                context.setLocale(localeInfo.locale);
                Navigator.of(context).pop();
              },
            );
          }),
        ],
      ),
    );
  }
}
