import 'package:flutter/material.dart';

import '../color/pharmaconnect_colors.dart';

enum PharmaConnectSemanticStatus {
  neutral,
  warning,
  success,
  error,
  unresolved,
}

@immutable
final class PharmaConnectStatusPresentation {
  const PharmaConnectStatusPresentation({
    required this.status,
    required this.foreground,
    required this.container,
    required this.border,
    required this.semanticCategory,
    this.requiresAction = false,
  });

  final PharmaConnectSemanticStatus status;
  final Color foreground;
  final Color container;
  final Color border;
  final String semanticCategory;
  final bool requiresAction;
}

abstract final class PharmaConnectSemanticStatusMapper {
  static const PharmaConnectStatusPresentation neutral =
      PharmaConnectStatusPresentation(
        status: PharmaConnectSemanticStatus.neutral,
        foreground: PharmaConnectColors.secondaryText,
        container: PharmaConnectColors.elevatedSurface,
        border: PharmaConnectColors.strongBorder,
        semanticCategory: 'Neutral',
      );

  static const PharmaConnectStatusPresentation warning =
      PharmaConnectStatusPresentation(
        status: PharmaConnectSemanticStatus.warning,
        foreground: PharmaConnectColors.warning,
        container: PharmaConnectColors.warningContainer,
        border: PharmaConnectColors.warningBorder,
        semanticCategory: 'Pending review',
      );

  static const PharmaConnectStatusPresentation actionRequired =
      PharmaConnectStatusPresentation(
        status: PharmaConnectSemanticStatus.warning,
        foreground: PharmaConnectColors.warning,
        container: PharmaConnectColors.warningContainer,
        border: PharmaConnectColors.warningBorder,
        semanticCategory: 'Action required',
        requiresAction: true,
      );

  static const PharmaConnectStatusPresentation success =
      PharmaConnectStatusPresentation(
        status: PharmaConnectSemanticStatus.success,
        foreground: PharmaConnectColors.success,
        container: PharmaConnectColors.successContainer,
        border: PharmaConnectColors.successBorder,
        semanticCategory: 'Success',
      );

  static const PharmaConnectStatusPresentation error =
      PharmaConnectStatusPresentation(
        status: PharmaConnectSemanticStatus.error,
        foreground: PharmaConnectColors.error,
        container: PharmaConnectColors.errorContainer,
        border: PharmaConnectColors.errorBorder,
        semanticCategory: 'Error',
      );

  static const PharmaConnectStatusPresentation unresolved =
      PharmaConnectStatusPresentation(
        status: PharmaConnectSemanticStatus.unresolved,
        foreground: PharmaConnectColors.linkFocus,
        container: PharmaConnectColors.unresolvedContainer,
        border: PharmaConnectColors.unresolvedBorder,
        semanticCategory: 'Unresolved',
      );

  static PharmaConnectStatusPresentation fromLifecycleValue(String value) {
    final String normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    return switch (normalized) {
      'draft' || 'archived' => neutral,
      'submitted' || 'pending' => warning,
      'changes_requested' => actionRequired,
      'published' || 'approved' || 'verified' => success,
      'hidden' || 'rejected' || 'error' || 'blocked' || 'suspended' => error,
      'unresolved' || 'loading' => unresolved,
      _ => unresolved,
    };
  }
}
