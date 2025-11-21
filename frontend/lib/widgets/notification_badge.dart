import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final Color? badgeColor;

  const NotificationBadge({
    Key? key,
    required this.count,
    required this.child,
    this.badgeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: badgeColor ?? Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
