import 'package:equatable/equatable.dart';

abstract class BundlesRevisedEvent extends Equatable {
  const BundlesRevisedEvent();
  @override
  List<Object?> get props => [];
}

/// Initialize: Load categories and subcategories for the first category
class BundlesRevisedInit extends BundlesRevisedEvent {
  final int categoryIndex; // Optional: which category to select initially (default: 0)

  const BundlesRevisedInit({this.categoryIndex = 0});

  @override
  List<Object?> get props => [categoryIndex];
}

/// Switch to a different category tab
class BundlesRevisedSelectCategory extends BundlesRevisedEvent {
  final int categoryIndex;

  const BundlesRevisedSelectCategory({required this.categoryIndex});

  @override
  List<Object?> get props => [categoryIndex];
}

/// Load more subcategories (show 5 more from cache)
class BundlesRevisedLoadMore extends BundlesRevisedEvent {
  const BundlesRevisedLoadMore();
}

/// DEPRECATED: Use BundlesRevisedLoadMore instead
class BundlesRevisedShowAll extends BundlesRevisedEvent {
  const BundlesRevisedShowAll();
}
