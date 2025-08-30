// lib/widgets/custom_widgets.dart
import 'package:flutter/material.dart';

import '../config/ui_config.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const StatusCard({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UIConfig.mediumSpacing),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConfig.mediumRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: UIConfig.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Color color;

  const ProgressCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UIConfig.mediumSpacing),
      decoration: UIConfig.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: UIConfig.subheadingStyle),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: UIConfig.smallSpacing),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          SizedBox(height: UIConfig.smallSpacing),
          Text(subtitle, style: UIConfig.captionStyle),
        ],
      ),
    );
  }
}

class SecurityFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const SecurityFeatureCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UIConfig.mediumSpacing),
      decoration: UIConfig.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: UIConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(UIConfig.smallRadius),
            ),
            child: Icon(
              icon,
              color: UIConfig.primaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: UIConfig.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: UIConfig.captionStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final ButtonStyle? style;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonStyle = style ?? UIConfig.primaryButtonStyle;
    
    if (backgroundColor != null || textColor != null) {
      final customStyle = ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? UIConfig.primaryColor,
        foregroundColor: textColor ?? Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConfig.mediumRadius),
        ),
        elevation: 4,
      );
      
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : onPressed,
          style: customStyle,
          icon: isLoading 
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? Colors.white
                    ),
                  ),
                )
              : (icon != null ? Icon(icon) : SizedBox.shrink()),
          label: Text(text),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        icon: isLoading 
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : (icon != null ? Icon(icon) : SizedBox.shrink()),
        label: Text(text),
      ),
    );
  }
}

class CameraOverlay extends StatelessWidget {
  final bool isActive;
  final String message;

  const CameraOverlay({
    Key? key,
    required this.isActive,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? UIConfig.primaryColor : Colors.white,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(UIConfig.circularRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UIConfig.circularRadius - 3),
        child: Stack(
          children: [
            // Face guide overlay
            Center(
              child: Container(
                width: 200,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isActive ? UIConfig.primaryColor : Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(UIConfig.circularRadius),
                ),
              ),
            ),
            // Status message overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(UIConfig.mediumSpacing),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(UIConfig.mediumRadius),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
