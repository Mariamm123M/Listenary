
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;
  final String title;
  final bool isDarkMode;
  final bool isSearching;
  final double screenWidth;
  final double screenHeight;
  VoidCallback zoomIn;
  VoidCallback zoomOut;
  VoidCallback changeMode;
  VoidCallback summarize;
  VoidCallback formatText;
  VoidCallback translateText;
  VoidCallback searchText;

  MyAppBar({
    Key? key,
    required this.title,
    required this.isSearching,
    required this.screenWidth,
    required this.screenHeight,
    required this.zoomIn,
    required this.zoomOut,
    required this.changeMode,
    required this.summarize,
    required this.formatText,
    required this.translateText,
    required this.searchText,
    this.height = kToolbarHeight,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.isDarkMode ? Color(0xFF212E54) : Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false, // Disable automatic leading
      titleSpacing: 0,
      title: Row(
        children: [
          // Back button - only show when actions are not expanded
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: !_showActions ? 48 : 0,
            child: !_showActions
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                      size: widget.screenWidth * 0.05,
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  )
                : SizedBox.shrink(),
          ),
          // Title - flexible to accommodate actions
          Expanded(
            child: Text(
              widget.title.isEmpty ? "Unknown Document" : widget.title,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                fontSize: widget.screenWidth * 0.038,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      actions: [
        // Actions that slide in from the right
        if (_showActions) ...[
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.zoom_in, color: Color(0xff949494)),
                    tooltip: 'zoom in',
                    onPressed: () {
                      widget.zoomIn();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.zoom_out, color: Color(0xff949494)),
                    tooltip: 'zoom out',
                    onPressed: () {
                      widget.zoomOut(); // Fixed: was calling zoomIn()
                    },
                  ),
                  IconButton(
                    icon: SvgPicture.asset('assets/Icons/summarize.svg',
                        width: widget.screenWidth * 0.035,
                        height: widget.screenHeight * 0.035),
                    tooltip: 'summarize',
                    onPressed: () {
                      widget.summarize();
                    },
                  ),
                  IconButton(
                      icon: SvgPicture.asset('assets/Icons/format.svg',
                          color: Color(0xff949494),
                          width: widget.screenWidth * 0.035,
                          height: widget.screenHeight * 0.035),
                      tooltip: 'text format',
                      onPressed: () {
                        widget.formatText();
                      }),
                  IconButton(
                      icon: SvgPicture.asset('assets/Icons/translate.svg',
                          width: widget.screenWidth * 0.035,
                          height: widget.screenHeight * 0.035),
                      tooltip: 'translate',
                      onPressed: () {
                        widget.translateText();
                      }),
                  IconButton(
                    icon: Icon(Icons.search,
                        size: widget.screenWidth * 0.06, // Reduced size
                        color: widget.isSearching
                            ? Color(0xffFEC838)
                            : Color(0xff949494)),
                    onPressed: () {
                      widget.searchText();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
        // Dark mode toggle - always visible
        IconButton(
          icon: SvgPicture.asset("assets/Icons/night.svg",
              color: widget.isDarkMode ? Color(0xff949494) : Color(0xffFEC838),
              width: widget.screenWidth * 0.03,
              height: widget.screenHeight * 0.03),
          tooltip: widget.isDarkMode ? 'light mode' : "dark mode",
          onPressed: () {
            widget.changeMode();
          },
        ),
        // More/Close button - always visible
        IconButton(
          icon: Icon(
            _showActions ? Icons.close : Icons.more_vert,
            color: Color(0xff949494),
          ),
          onPressed: () {
            setState(() {
              _showActions = !_showActions;
            });
          },
        ),
      ],
    );
  }
}