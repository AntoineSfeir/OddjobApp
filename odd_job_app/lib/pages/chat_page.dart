import "package:flutter/material.dart";
import "package:odd_job_app/jobs/user.dart";
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
  late user receivingUser;
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

    DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
        .instance
        .collection('users/')
        .doc(recieverDocId)
        .get();

    receivingUser = user.fromSnapshot(userDoc);
    receivingUser.ID = userDoc.id;
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
          backgroundColor:
                Colors.black,
          title: Text(widget.recieverUser),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtherProfilePage(
                      recieverUser: receivingUser,
                    ),
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
  return Container(
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 20.0, right: 8.0),
            child: Stack(
              children: [
                TextField(
                  controller: _messageController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Enter Message',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton(
                    onPressed: () {
                      sendMessage();
                      _messageController.clear(); // Clear the text after sending
                    },
                    icon: const Icon(Icons.arrow_upward),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

}