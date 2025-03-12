import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProfileImage extends StatelessWidget {
  final double screenWidth;
  final double radius; // Radius for the avatar
  final VoidCallback? onTap; // Callback when avatar is tapped (to select image)
  final Widget? child; // Optional child widget (like an edit icon)
  final Color? color; // Color for the default SVG icon
  final String? imageFile; // File path of the selected image (nullable)

  ProfileImage({
    super.key,
    required this.screenWidth,
    required this.onTap, // Callback is required for image selection
    required this.radius, // Default radius
    this.child,
    this.color = Colors.white, // Default color for SVG
    this.imageFile, // Nullable, will determine which image to show
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Trigger the file picker or another action
      child: Stack(
        children: [
          // Display selected image if available, otherwise show SVG
          if (imageFile != null && imageFile!.isNotEmpty)
            CircleAvatar(
              radius: radius * screenWidth,
              backgroundImage: FileImage(File(imageFile!)),
            )
          else
            SvgPicture.asset(
              "assets/Icons/username.svg",
              height: radius * screenWidth, // Adjust based on radius for consistency
              width: radius * screenWidth,
              color: color, // Color for the SVG icon
            ),
          
          // Add the child widget (like an edit button) if provided
          if (child != null)
            Positioned(
              bottom: 15,
              right: 5,
              child: child!,
            ),
        ],
      ),
    );
  }
}
