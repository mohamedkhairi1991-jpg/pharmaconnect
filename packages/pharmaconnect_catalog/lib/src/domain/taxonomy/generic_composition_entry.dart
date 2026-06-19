import 'active_ingredient.dart';

final class GenericCompositionEntry {
  const GenericCompositionEntry({
    required this.ingredient,
    required this.sortOrder,
  });

  final ActiveIngredient ingredient;
  final int sortOrder;
}
