import 'package:flutter/material.dart';

/// A ListView that [group] it's children based on a grouping function
class GroupedListView<I, G> extends StatefulWidget {
  /// `group` maps an item to it's corresponding group
  final G Function(I) group;

  /// The `groupHeaderBuilder` callback will be called only when a group header
  /// is ready to be visible on screen
  /// {@tool sample}
  ///
  /// e.g
  ///
  /// ```dart
  /// GroupedListView<String, int>(
  ///   groupHeaderBuilder: (BuildContext context, int group) {
  ///     return ListTile(
  ///       title: Text('$group'),
  ///     );
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  final Widget Function(BuildContext, G) groupHeaderBuilder;

  /// The `itemBuilder` callback will be called only when an item is ready to be
  /// visible on screen

  /// {@tool sample}
  ///
  /// e.g
  ///
  /// ```dart
  /// GroupedListView<String, int>(
  ///   itemBuilder: (BuildContext context, String item, int group) {
  ///     return ListTile(
  ///       title: Text('item'),
  ///     );
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  final Widget Function(BuildContext, I, G) itemBuilder;
  final List<I> items;

  /// A search term which used to filter `items`.
  /// If `search` is set so should `searchableTerm`.
  final String search;

  /// Set the search term that you want to filter your items with.
  /// The `searchTerm` can't be null if a `search` query is specified.
  final String Function(I) searchableTerm;

  /// Scrolls to a specific group
  final G scrollToSection;

  GroupedListView(
      {Key key,
      @required this.group,
      @required this.groupHeaderBuilder,
      @required this.itemBuilder,
      @required this.items,
      this.search,
      this.searchableTerm,
      this.scrollToSection})
      : assert(items != null && items.isNotEmpty),
        assert(itemBuilder != null),
        assert(groupHeaderBuilder != null),
        assert(group != null),
        assert(search == null || (search != null && searchableTerm != null)),
        super(key: key) {
    if (items.first is Comparable)
      items.sort();
    else
      items.sort(
          (item1, item2) => ('${group(item1)}').compareTo('${group(item2)}'));
  }

  @override
  _GroupedListViewState<I, G> createState() => _GroupedListViewState();
}

class _GroupedListViewState<I, G> extends State<GroupedListView> {
  // Actual size items + groups
  int listViewSize;
  List<I> dynamicItems;
  GlobalKey itemKey = GlobalKey();
  GlobalKey groupKey = GlobalKey();

  // To save the height of every section in a map
  Map<G, Stats> heights = {};
  ScrollController _controller = ScrollController();
  double itemSize = 0;
  double groupSize = 0;
  Key masterKey = GlobalKey();

  @override
  void initState() {
    dynamicItems = widget.items;
    _groupsCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scrollToSection != null) {
      _goToSection();
      masterKey = GlobalKey();
    }
    if (itemSize == 0) calculateItemHeight();
    Map groups = {};
    int numberOfHeaders = 0;
    if (widget.search != null) _filterItems();
    return ListView.builder(
      key: masterKey,
      controller: _controller,
      itemBuilder: (context, index) {
        final item = dynamicItems[index - numberOfHeaders];
        final currentGroupHeader = widget.group(item);
        if (!groups.containsKey(currentGroupHeader)) {
          ++numberOfHeaders;
          groups[currentGroupHeader] = null;
          return Container(
            key: groupKey.currentContext == null
                ? groupKey
                : Key(currentGroupHeader),
            child: widget.groupHeaderBuilder(context, currentGroupHeader),
          );
        }
        return Container(
          key: itemKey.currentContext == null
              ? itemKey
              : Key(dynamicItems[index - numberOfHeaders].toString()),
          child: widget.itemBuilder(
              context,
              dynamicItems[index - numberOfHeaders],
              widget.group(dynamicItems[index - numberOfHeaders])),
        );
      },
      itemCount: listViewSize,
    );
  }

  _groupsCount() {
    int numberOfGroups = 0;
    int numberOfItems = 0;
    heights.clear();
    listViewSize = dynamicItems.length;
    for (int i = 0; i < dynamicItems.length; i++) {
      final currentGroupHeader = widget.group(dynamicItems[i]);
      final previousGroupHeader =
          i == 0 ? null : widget.group(dynamicItems[i - 1]);
      if (currentGroupHeader != previousGroupHeader) {
        ++listViewSize;
        ++numberOfGroups;
        heights[currentGroupHeader] = Stats(numberOfGroups, numberOfItems);
      } else {
        ++numberOfItems;
      }
    }
  }

  _filterItems() {
    final searchTerm = widget.search;
    setState(() {
      dynamicItems = widget.items;
      if (widget.search.isEmpty) return;
      dynamicItems = dynamicItems.where((item) {
        final searchableTerm = widget.searchableTerm(item);
        return searchableTerm.toLowerCase().contains(searchTerm.toLowerCase());
      }).toList();
    });
    _groupsCount();
  }

  _goToSection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final group = widget.scrollToSection;

      if (heights[group] != null) {
        final scrollSize = (itemSize * heights[group].numberOfItems) +
            (groupSize * heights[group].numberOfGroups);

        _controller.jumpTo(scrollSize);
      }
    });
  }

  calculateItemHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox itemBox = itemKey.currentContext.findRenderObject();
      itemSize = itemBox.size.height;
      final RenderBox groupBox = groupKey.currentContext.findRenderObject();
      groupSize = groupBox.size.height;
    });
  }
}

class Stats {
  final int numberOfGroups;
  final int numberOfItems;

  Stats(this.numberOfGroups, this.numberOfItems);
}
