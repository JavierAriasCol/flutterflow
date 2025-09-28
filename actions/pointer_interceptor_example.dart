import 'package:pointer_interceptor/pointer_interceptor.dart';

class CustomDropdownOverlay extends StatefulWidget {
  const CustomDropdownOverlay({Key? key, this.width, this.height})
    : super(key: key);

  final double? width;
  final double? height;

  @override
  _CustomDropdownOverlayState createState() => _CustomDropdownOverlayState();
}

class _CustomDropdownOverlayState extends State<CustomDropdownOverlay> {
  String selectedValue = 'Option 1';
  bool isDropdownOpened = false;
  OverlayEntry? overlayEntry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (isDropdownOpened) {
                overlayEntry?.remove();
              } else {
                overlayEntry = _createOverlayEntry();
                Overlay.of(context)?.insert(overlayEntry!);
              }
              isDropdownOpened = !isDropdownOpened;
            });
          },
          child: Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black),
            ),
            child: Center(child: Text(selectedValue)),
          ),
        ),
      ],
    );
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 5.0,
        width: size.width,
        child: PointerInterceptor(
          child: Material(
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(10, (index) {
                return MouseRegion(
                  onEnter: (event) => _onHoverItem(index, true),
                  onExit: (event) => _onHoverItem(index, false),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedValue = 'Option ${index + 1}';
                        overlayEntry?.remove();
                        isDropdownOpened = false;
                      });
                    },
                    child: Container(
                      color: _hoveredIndex == index
                          ? Colors.grey[300]
                          : Colors.transparent,
                      height: 40,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      alignment: Alignment.centerLeft,
                      child: Text('Option ${index + 1}'),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  int? _hoveredIndex;

  void _onHoverItem(int index, bool isHovered) {
    setState(() {
      _hoveredIndex = isHovered ? index : null;
    });
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    super.dispose();
  }
}
