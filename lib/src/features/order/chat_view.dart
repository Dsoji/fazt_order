import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../common/widgets/text_styles.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Sample chat messages (replace with actual data source in production)
  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          'HI! I made new UI-Kit for project, check it later\nhttps://dribbble.com/shots/17742253-ui-kit-designjam\nSee you at office tomorrow!',
      'isSent': false,
      'timestamp': DateTime(2025, 4, 18, 15, 42), // Yesterday
      'isRead': true,
    },
    {
      'text': 'Thank you for work, see you!',
      'isSent': true,
      'timestamp': DateTime(2025, 4, 18, 15, 42), // Yesterday
      'isRead': true,
    },
    {
      'text': 'Hello! Have you seen my backpack anywhere in office?',
      'isSent': false,
      'timestamp': DateTime(2025, 4, 19, 15, 42), // Today
      'isRead': true,
    },
    {
      'text': 'Hi, yes, David have found it, ask our concierge •••',
      'isSent': true,
      'timestamp': DateTime(2025, 4, 19, 15, 42), // Today
      'isRead': true,
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isSent': true,
        'timestamp': DateTime.now(),
        'isRead': false,
      });
      _messageController.clear();
    });

    // Scroll to the bottom after sending a message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcPrimaryNeutral950,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Chat",
          style: ktBodySemiBoldSize20.copyWith(
            fontSize: 20,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: kcPrimaryNeutral950,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _groupMessagesByDate().length,
              itemBuilder: (context, index) {
                final group = _groupMessagesByDate()[index];
                return Column(
                  children: [
                    // Date Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        group['date'],
                        style: ktBodyRegularSize12.copyWith(
                          color: kcPrimaryNeutral500,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    // Messages for this date
                    ...group['messages'].map<Widget>((message) {
                      return _buildMessageBubble(message);
                    }).toList(),
                  ],
                );
              },
            ),
          ),
          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupMessagesByDate() {
    final groupedMessages = <Map<String, dynamic>>[];
    String? lastDate;

    for (var message in _messages) {
      final date = DateFormat('yyyy-MM-dd').format(message['timestamp']);
      final isToday =
          DateTime.now().difference(message['timestamp']).inDays == 0;
      final isYesterday =
          DateTime.now().difference(message['timestamp']).inDays == 1;
      final dateLabel = isToday
          ? 'Today'
          : isYesterday
              ? 'Yesterday'
              : DateFormat('MMM d, yyyy').format(message['timestamp']);

      if (lastDate != date) {
        groupedMessages.add({
          'date': dateLabel,
          'messages': [message],
        });
        lastDate = date;
      } else {
        groupedMessages.last['messages'].add(message);
      }
    }

    return groupedMessages;
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isSent = message['isSent'] as bool;
    final timestamp =
        DateFormat('HH:mm').format(message['timestamp'] as DateTime);
    final isRead = message['isRead'] as bool;

    // Split message text to identify URLs
    final RegExp urlRegExp = RegExp(r'(https?://[^\s]+)');
    final parts = message['text'].toString().split(urlRegExp);
    final matches = urlRegExp.allMatches(message['text'].toString()).toList();

    List<TextSpan> textSpans = [];
    for (int i = 0; i < parts.length; i++) {
      textSpans.add(TextSpan(text: parts[i]));
      if (i < matches.length) {
        final url = matches[i].group(0)!;
        textSpans.add(
          TextSpan(
            text: url,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment:
            isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSent) ...[
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('asset/images/support_agent.png'),
              backgroundColor: Colors.grey,
            ),
            horizontalSpaceSmall,
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSent ? kcPrimaryNeutral800 : kcPrimaryNeutral900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      children: textSpans,
                      style: ktBodyRegularSize12.copyWith(
                        color: Colors.black,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  verticalSpaceTiny,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timestamp,
                        style: ktBodyRegularSize12.copyWith(
                          color: kcPrimaryNeutral500,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      if (isSent && isRead) ...[
                        horizontalSpaceTiny,
                        const Icon(
                          Icons.done_all,
                          color: Colors.green,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: kcPrimaryNeutral800,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: kcWhite,
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              icon: const Icon(
                Iconsax.paperclip,
                color: kcPrimaryNeutral500,
                size: 24,
              ),
              onPressed: () {
                // TODO: Implement attachment functionality
              },
            ),
          ),
          horizontalSpaceSmall,
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                letterSpacing: 1,
              ),
              decoration: InputDecoration(
                hintText: "Type your message here...",
                hintStyle: const TextStyle(
                  color: kcPrimary400,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: kcPrimaryNeutral900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          horizontalSpaceSmall,
          Container(
            decoration: BoxDecoration(
              color: kcPrimary400,
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              icon: const Icon(
                Iconsax.send_1,
                color: kcWhite,
                size: 24,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
