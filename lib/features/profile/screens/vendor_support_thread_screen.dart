import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/vendor_support_chat_screen.dart';

/// An administration conversation opened from the inbox. It uses the same live
/// chat as technical support: bubbles, instant sending and automatic updates.
/// Opening the conversation marks its messages as read on the server.
class VendorSupportThreadScreen extends StatelessWidget {
  final int id;
  const VendorSupportThreadScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) => VendorSupportChatScreen(threadId: id);
}
