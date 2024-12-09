import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

Duration _animationDuration = const Duration(milliseconds: 200);

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon, isHovered) {
              return AnimatedContainer(
                duration: _animationDuration,
                constraints: const BoxConstraints(minWidth: 48),
                height: isHovered ? 64 : 48,
                width: isHovered ? 64 : 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[icon.hashCode % Colors.primaries.length],
                  boxShadow: isHovered
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Center(child: Icon(icon, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [IconData] items to put in this [Dock].
  final List<IconData> items;

  /// Builder building the provided [IconData] item with a hover effect.
  final Widget Function(IconData, bool isHovered) builder;

  @override
  State<Dock> createState() => _DockState();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState extends State<Dock> {
  /// [IconData] items being manipulated.
  late final List<IconData> _items = widget.items.toList();

  /// Currently hovered index.
  int? _hoveredIndex;

  /// Item currently being dragged.
  IconData? _draggedItem;

  /// Index of item being dragged
  int? _draggedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black12,
      ),

      /// Specify height for a smooth transition when hovering
      /// 64 is the max height of Icon when hovered
      /// So, 64 plus padding where equals to 96
      height: 96.0,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          return DragTarget<IconData>(
            onWillAcceptWithDetails: (data) => data.data != _items[index],
            onAcceptWithDetails: (data) {
              setState(() {
                final oldIndex = _items.indexOf(data.data);
                final newIndex = index;
                _items.removeAt(oldIndex);
                _items.insert(newIndex, data.data);
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Draggable<IconData>(
                data: _items[index],
                onDragStarted: () => setState(() {
                  _draggedItem = _items[index];
                  _draggedIndex = index;
                }),
                onDragEnd: (_) => setState(() {
                  _draggedItem = null;
                  _draggedIndex = null;
                }),
                feedback: Material(
                  color: Colors.transparent,
                  child: widget.builder(_items[index], true),
                ),
                childWhenDragging: MouseRegion(
                  onEnter: (_) => setState(() {
                    _hoveredIndex = index;
                  }),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: _hoveredIndex == _draggedIndex
                      ? // spacing
                      const SizedBox(
                          width: 85.0,
                          height: 85.0,
                        )
                      : SizedBox(
                          width: ((_hoveredIndex ?? 0) + 1 == _draggedIndex || (_hoveredIndex ?? 0) - 1 == _draggedIndex) ? 84.0 : 0.0,
                          height: 85.0,
                        ),
                ),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: AnimatedSwitcher(
                    duration: _animationDuration,
                    child: AnimatedContainer(
                      key: ValueKey(_items[index]),
                      duration: _animationDuration,
                      padding: (_hoveredIndex == index && _draggedItem != null) ? const EdgeInsets.symmetric(horizontal: 24.0) : const EdgeInsets.all(0.0),
                      child: widget.builder(_items[index], _hoveredIndex == index),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
