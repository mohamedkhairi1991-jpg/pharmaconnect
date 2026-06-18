import 'package:flutter/material.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';
import 'package:pharmaconnect_mobile/app/router/mobile_router.dart';

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appName,
      routerConfig: mobileRouter,
      theme: PharmaConnectTheme.light(),
    );
  }
}
