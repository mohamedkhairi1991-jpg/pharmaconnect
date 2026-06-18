import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_admin/app/router/admin_router.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appName,
      routerConfig: ref.watch(adminRouterProvider),
      theme: PharmaConnectTheme.light(),
    );
  }
}
