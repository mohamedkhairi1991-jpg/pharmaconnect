import 'package:flutter/material.dart';

class MobileOfficialCatalogEntryPage extends StatelessWidget {
  const MobileOfficialCatalogEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Official catalog entry')));
  }
}

class MobileCompanyCatalogEntryPage extends StatelessWidget {
  const MobileCompanyCatalogEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Company catalog workflow entry')),
    );
  }
}
