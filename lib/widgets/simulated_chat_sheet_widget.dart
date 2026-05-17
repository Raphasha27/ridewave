import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import './custom_icon_widget.dart';

class SimulatedChatSheetWidget extends StatefulWidget {
  final String contactName;
  final String contactAvatarUrl;
  final String contactRole;

  const SimulatedChatSheetWidget({
    super.key,
    required this.contactName,
    required this.contactAvatarUrl,
    required this.contactRole,
  });

  @override
  State<SimulatedChatSheetWidget> createState() => _SimulatedChatSheetWidgetState();
}

class _SimulatedChatSheetWidgetState extends State<SimulatedChatSheetWidget> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickTemplates = [
    'I am outside now.',
    'Almost there, 1 min!',
    'Understood, thank you!',
    'I am wearing a black jacket.',
  ];

  final List<String> _driverReplies = [
    'Great, see you soon!',
    'Perfect, I will pull over near the main gate.',
    'Understood! Turning into your street now.',
    'Perfect, thank you for letting me know!',
  ];

  int _replyCounter = 0;

  @override
  void initState() {
    super.initState();
    // Default initial greeting message
    _messages.add({
      'sender': 'other',
      'text': 'Hi Marcus, I am driving towards your pickup address now.',
      'time': 'Just now',
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'self',
        'text': text.trim(),
        'time': 'Just now',
      });
      _composerController.clear();
    });

    _scrollToBottom();

    // Trigger simulated reply after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          String replyText = _driverReplies[_replyCounter % _driverReplies.length];
          _replyCounter++;
          _messages.add({
            'sender': 'other',
            'text': replyText,
            'time': 'Just now',
          });
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(bottom: keyboardPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // 1. Sliding Header Panel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.outlineLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(widget.contactAvatarUrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.contactName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            'Active Ride Chat • ${widget.contactRole}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.accentDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Chat Message List View
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isSelf = msg['sender'] == 'self';

                return Align(
                  alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isSelf ? AppTheme.primary : AppTheme.backgroundLight,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isSelf ? const Radius.circular(20) : Radius.zero,
                        bottomRight: isSelf ? Radius.zero : const Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: isSelf ? Colors.white : AppTheme.primary,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            color: isSelf ? Colors.white60 : AppTheme.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. Quick-Template composing pill section
          Container(
            height: 40,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickTemplates.length,
              itemBuilder: (context, index) {
                final template = _quickTemplates[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _sendMessage(template),
                    child: Chip(
                      backgroundColor: AppTheme.backgroundLight,
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      label: Text(template),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // 4. Text Composer Row
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _composerController,
                    onSubmitted: (val) => _sendMessage(val),
                    decoration: InputDecoration(
                      hintText: 'Type a message to driver...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppTheme.onSurfaceMuted,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: AppTheme.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _sendMessage(_composerController.text),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CustomIconWidget(
                        iconName: 'send',
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
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
