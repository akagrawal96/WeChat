import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/api/apis_database.dart';
import 'package:we_chat/widgets/message_card_db.dart';

import '../main.dart';
import '../models/chat_user.dart';
import '../models/message_db.dart';
import 'view_profile_screen.dart';

class ChatScreenRealtime extends StatefulWidget {
  final ChatUser user;

  const ChatScreenRealtime({super.key, required this.user});

  @override
  State<ChatScreenRealtime> createState() => _ChatScreenRealtimeState();
}

class _ChatScreenRealtimeState extends State<ChatScreenRealtime> {
  //for storing all messages
  List<MessageDb> _list = [];

  late Stream<List<MessageDb>> _chatStream;

  var personName = "";
  var imageUrl = "";

  //for handling message text changes
  final _textController = TextEditingController();

  //showEmoji -- for storing value of showing or hiding emoji
  //isUploading -- for checking if image is uploading or not?
  bool _showEmoji = false, _isUploading = false;

  @override
  void initState() {
    super.initState();

    fetchUserDetails(widget.user.id);

    _chatStream = _getChatStream();
  }


  Stream<List<MessageDb>> _getChatStream() {
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("Chats");
    Stream<DatabaseEvent> eventStream = reference.onValue;

    return eventStream.map((event) {
      List<MessageDb> mChat = [];
      DataSnapshot dataSnapshot = event.snapshot;

      Map<dynamic, dynamic>? chatData = dataSnapshot.value as Map<dynamic, dynamic>?;


      print("Data fetched from database: $chatData");

      chatData?.forEach((key, value) {
        print("value received: $value");
        MessageDb message = MessageDb.fromMap(value);
        print("Message Received: $message");
        print("APIsDatabase.user.uid: ${APIsDatabase.user.uid}");
        print("widget.user.id: ${widget.user.id}");

        if ((message.receiver == APIsDatabase.user.uid &&
            message.sender == widget.user.id) ||
            (message.receiver == widget.user.id &&
                message.sender == APIsDatabase.user.uid)) {
          if (message.message != "Session Ended by Listener") {
            debugPrint("Message Added");
            mChat.add(message);
          } else {
            // Handle the case of "Session Ended by Listener" message if needed
            // chatEndByUser();
          }
        }
      });

      print("Length of mChat list: ${mChat.length}");
      mChat.forEach((message) {
        print("Message: ${message.message}");
      });

      return mChat;
    });
  }


  /*Stream<List<MessageDb>> _getChatStream() {
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("Chats");
    Stream<DatabaseEvent> eventStream = reference.onValue;

    return eventStream.map((event) {
      List<MessageDb> mChat = [];
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value == null) {
        print("No data available in the snapshot.");
        return mChat;
      }

      Map<dynamic, dynamic>? chatData = dataSnapshot.value as Map<dynamic, dynamic>?;

      print("Data fetched from database: $chatData");

      if (chatData == null) {
        print("Invalid data structure. Expected a Map<dynamic, dynamic>.");
        return mChat;
      }

      chatData.forEach((key, value) {
        MessageDb message = MessageDb.fromMap(value);
        print("Message Added: $message");
        if ((message.receiver == APIsDatabase.user.uid && message.sender == widget.user.id) ||
            (message.receiver == widget.user.id && message.sender == APIsDatabase.user.uid)) {
          if (message.message != "Session Ended by Listener") {
            debugPrint("Message Added");
            mChat.add(message);
          } else {
            // Handle the case of "Session Ended by Listener" message if needed
            // chatEndByUser();
          }
        }
      });

      print("Length of mChat list: ${mChat.length}");
      mChat.forEach((message) {
        print("Message: ${message.message}");
      });

      return mChat;
    });
  }*/






  /* Stream<List<MessageDb>> _getChatStream() {
    List<Map<String, dynamic>> mockData = [
      {
        "sender": "user1",
        "receiver": "user2",
        "message": "Hello User2, how are you?",
        "timestamp": (DateTime.now().millisecondsSinceEpoch).toString(),
      },
      {
        "sender": "user2",
        "receiver": "user1",
        "message": "Hi User1, I'm doing great!",
        "timestamp": (DateTime.now().millisecondsSinceEpoch).toString(),
      },
      {
        "sender": "user1",
        "receiver": "user2",
        "message": "That's good to hear!",
        "timestamp": (DateTime.now().millisecondsSinceEpoch).toString(),
      },
      // Add more mock messages here
    ];

    List<MessageDb> mChat = mockData.map((data) => MessageDb.fromMap(data)).toList();
    print("Length of mChat list: ${mChat.length}");
    mChat.forEach((message) {
      print("Sender: ${message.sender}, Receiver: ${message.receiver}, Message: ${message.message}");
    });

    return Stream.value(mChat);
  }*/


  /*Stream<List<MessageDb>> _getChatStream() {
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("Chats");
    Stream<DatabaseEvent> eventStream = reference.onValue;

    return eventStream.map((event) {
      List<MessageDb> mChat = [];
      DataSnapshot dataSnapshot = event.snapshot;

      Map<dynamic, dynamic>? chatData = dataSnapshot.value as Map<dynamic, dynamic>?;
      chatData?.forEach((key, value) {
        MessageDb message = MessageDb.fromMap(value);
        if ((message.receiver == APIsDatabase.user.uid && message.sender == widget.user.id) ||
            (message.receiver == widget.user.id && message.sender == APIsDatabase.user.uid)) {
          if (message.message != "Session Ended by Listener") {
            mChat.add(message);
          } else {
            // Handle the case of "Session Ended by Listener" message if needed
            // chatEndByUser();
          }
        }
      });

      print("Length of mChat list: ${mChat.length}");
      mChat.forEach((message) {
        print("Message: ${message.message}");
      });

      return mChat;
    });
  }
*/

  /*Stream<List<MessageDb>> _getChatStream() {
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("Chats");
    Stream<DatabaseEvent> eventStream = reference.onValue;

    return eventStream.map((event) {
      List<MessageDb> mChat = [];
      DataSnapshot dataSnapshot = event.snapshot;

      Map<dynamic, dynamic>? chatData = dataSnapshot.value as Map<dynamic, dynamic>?;
      print("Data fetched from database: $chatData");
      if (chatData != null) {
        chatData.forEach((key, value) {
          MessageDb message = MessageDb.fromMap(value);
          if ((message.receiver == APIsDatabase.user.uid && message.sender == widget.user.id) ||
              (message.receiver == widget.user.id && message.sender == APIsDatabase.user.uid)) {
            if (message.message != "Session Ended by Listener") {
              mChat.add(message);
            } else {
              // Handle the case of "Session Ended by Listener" message if needed
              // chatEndByUser();
            }
          }
        });
      }
      print("Length of mChat list: ${mChat.length}");
      mChat.forEach((message) {
        print("Message: ${message.message}");
      });
      return mChat;
    });
  }*/


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if emojis are shown & back button is pressed then hide emojis
          //or else simple close current screen on back button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() => _showEmoji = !_showEmoji);
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            //app bar
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),

            backgroundColor: const Color.fromARGB(255, 234, 248, 255),

            //body
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<MessageDb>>(
                    //stream: APIsDatabase.getConversation(APIsDatabase.user.uid, widget.user.id),
                    stream: _chatStream,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                      //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                      //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data ?? [];
                          _list = data;

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCardDb(message: _list[index]);
                              },
                            );
                          } else {
                            return const Center(
                              child: Text('Say Hii! 👋', style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  ),
                  /*child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                itemCount: _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(message: _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('Say Hii! 👋',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  ),*/
                ),

                //progress indicator for showing uploading
                if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(strokeWidth: 2))),

                //chat input filed
                _chatInput(),

                //show emojis on keyboard emoji button click & vice versa
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // app bar widget
  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: Row(
        children: [
          //back button
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.black54)),

          //user profile picture
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .03),
            child: CachedNetworkImage(
              width: mq.height * .05,
              height: mq.height * .05,
              imageUrl: imageUrl,
              errorWidget: (context, url, error) =>
                  const CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),

          //for adding some space
          const SizedBox(width: 10),

          //user name & last seen time
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //user name
              Text(personName,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500)),

              //for adding some space
              const SizedBox(height: 2),

              //last seen time of user
              /* Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: list[0].lastActive)
                              : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user.lastActive),
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54)),*/
            ],
          )
        ],
      ),
    );
  }

  // bottom chat input field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          //input field & buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: const Icon(Icons.emoji_emotions,
                          color: Colors.blueAccent, size: 25)),

                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                    },
                    decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none),
                  )),

                  //pick image from gallery button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Picking multiple images
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        // uploading & sending image one by one
                        for (var i in images) {
                          log('Image Path: ${i.path}');
                          setState(() => _isUploading = true);
                          // await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.image,
                          color: Colors.blueAccent, size: 26)),

                  //take image from camera button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() => _isUploading = true);

                          // await APIs.sendChatImage(
                          //     widget.user, File(image.path));
                          // setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Colors.blueAccent, size: 26)),

                  //adding some space
                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),

          //send message button
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIsDatabase().sendMessage(widget.user.id,
                    APIsDatabase.user.uid, _textController.text, true);
                /*if (_list.isEmpty) {
                  //on first message (add user to my_user collection of chat user)
                  APIs.sendFirstMessage(
                      widget.user, _textController.text, Type.text);
                } else {
                  //simply send message
                  APIsDatabase().sendMessage(
                      widget.user, _textController.text, Type.text);
                }*/
                _textController.text = '';
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }

  void fetchUserDetails(String id) async {
    DatabaseReference userRef =
    FirebaseDatabase.instance.ref().child("users").child(id);

    userRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        // Convert event.snapshot.value to Map<String, dynamic>
        Map<String, dynamic> userDataMap = {};
        if (event.snapshot.value is Map) {
          (event.snapshot.value as Map).forEach((key, value) {
            userDataMap[key.toString()] = value;
          });
        }

        // Create a ChatUser instance by parsing the userData
        ChatUser user = ChatUser.fromJson(userDataMap);

        // Now you can access individual properties of the user
        print("User ID: ${user.id}");
        print("User Name: ${user.name}");
        print("User Email: ${user.email}");
        // ... and so on for other properties

        personName = user.name;
        imageUrl = user.image;
        setState(() {});
      } else {
        print("User data not found!");
      }
    }, onError: (error) {
      print("Error fetching data: $error");
    });
  }

}
