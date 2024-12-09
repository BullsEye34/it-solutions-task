import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

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
                duration: const Duration(milliseconds: 200),
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
                feedback: Material(
                  color: Colors.transparent,
                  child: widget.builder(_items[index], true),
                ),
                childWhenDragging: const SizedBox.shrink(),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: widget.builder(_items[index], _hoveredIndex == index),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
