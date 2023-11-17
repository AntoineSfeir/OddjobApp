import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:odd_job_app/chat/chat_service.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:odd_job_app/chat/message_bubble.dart";
import "package:odd_job_app/pages/other_profile_page.dart";

class ChatPage extends StatefulWidget {
  final String recieverEmail;
  final String recieverUser;
  const ChatPage(
      {super.key, required this.recieverEmail, required this.recieverUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  ChatService chat = ChatService();

  String? recieverDocId;

  Future<void> getRecieverDocId() async {
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach((document) {
            if (document["email"] == widget.recieverEmail) {
              setState(() {
                recieverDocId = document.reference.id;
              });
            }
          }),
        );
  }

  @override
  void initState() {
    super.initState();
    getRecieverDocId(); // Call the method in initState
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.recieverEmail, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Text(widget.recieverUser),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OtherProfilePage(recieverDocId: recieverDocId ?? ""),
                  ),
                );
              },
            ),
            // Add more IconButton widgets if needed
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: buildMessageList(),
            ),
            buildMessageInput(),
          ],
        ));
  }

  Widget buildMessageList() {
    return StreamBuilder(
      stream:
          chat.getMessages(auth.currentUser?.email ?? '', widget.recieverEmail),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        return ListView(
          children: snapshot.data!.docs
              .map((document) => buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    var alignment = (data['recieverUser'] != auth.currentUser!.email)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ChatBubble(
              message: data['message'],
              isSender: (data['recieverUser'] != auth.currentUser!.email))),
    );
  }

  Widget buildMessageInput() {
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: _messageController,
          decoration: const InputDecoration(
            hintText: 'Enter Message',
          ),
        )),
        IconButton(onPressed: sendMessage, icon: const Icon(Icons.arrow_upward))
      ],
    );
  }
}
