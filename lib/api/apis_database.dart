import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:we_chat/models/message_db.dart';

import '../models/chat_user.dart';

class APIsDatabase {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  // static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing realtime database
  static FirebaseDatabase database = FirebaseDatabase.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  static DatabaseReference usersRef =
      FirebaseDatabase.instance.ref().child('users');

  // for storing self information
  static ChatUser me = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');

  // to return current user
  static User get user => auth.currentUser!;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });

    // for handling foreground messages
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      // ChatUser chatUser, String msg, String msg2) async {
      String chatUser,
      String msg,
      String msg2,
      String s) async {
    try {
      final body = {
        //"to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAQ0Bf7ZA:APA91bGd5IN5v43yedFDo86WiSuyTERjmlr4tyekbw_YW6JrdLFblZcbHdgjDmogWLJ7VD65KGgVbETS0Px7LnKk8NdAz4Z-AsHRp9WoVfArA5cNpfMKcjh_MQI-z96XQk5oIDUwx8D1'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // for checking if user exists or not?
  /*static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }*/

  static Future<bool> userExists() async {
    DatabaseReference usersRef = database.ref().child('users');
    DatabaseEvent snapshot = await usersRef.child(user.uid).once();
    if (snapshot != null) {
      return true;
    } else {
      return false;
    }
    // Check if the event has data and the data (snapshot) is not null
    //return snapshot != null;
  }

  // for adding an chat user for our conversation
  // static Future<bool> addChatUser(String email) async {
  //   final data = await firestore
  //       .collection('users')
  //       .where('email', isEqualTo: email)
  //       .get();
  //
  //   log('data: ${data.docs}');
  //
  //   if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
  //     //user exists
  //
  //     log('user exists: ${data.docs.first.data()}');
  //
  //     firestore
  //         .collection('users')
  //         .doc(user.uid)
  //         .collection('my_users')
  //         .doc(data.docs.first.id)
  //         .set({});
  //
  //     return true;
  //   } else {
  //     //user doesn't exists
  //
  //     return false;
  //   }
  // }
  //
  // // for getting current user info
  // static Future<void> getSelfInfo() async {
  //   await firestore.collection('users').doc(user.uid).get().then((user) async {
  //     if (user.exists) {
  //       me = ChatUser.fromJson(user.data()!);
  //       await getFirebaseMessagingToken();
  //
  //       //for setting user status to active
  //       APIs.updateActiveStatus(true);
  //       log('My Data: ${user.data()}');
  //     } else {
  //       await createUser().then((value) => getSelfInfo());
  //     }
  //   });
  // }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using We Chat!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');

    //await  usersRef.child(user.uid).set(chatUser);
    await FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid)
        .set(chatUser.toJson());

    /*  return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());*/
  }

  // for getting all users from firestore database
  // static Stream<Event> getAllUsers() {
  //   DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('users');
  //
  //   User user = FirebaseAuth.instance.currentUser;
  //   String currentUserId = user.uid;
  //
  //   // This part filters the users based on 'id' field not being equal to the current user's ID
  //   Query query = usersRef.orderByChild('id').equalTo(currentUserId);
  //
  //   Stream<Event> stream = query.onChildAdded.map((event) => event.snapshot);
  //
  //   return stream;
  // }

  static Stream<List<ChatUser>> getAllUsers() {
    DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('users');

    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return _userRef.onValue.map((event) {
      List<ChatUser> userList = [];
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic> usersData =
            dataSnapshot.value as Map<dynamic, dynamic>;

        usersData.forEach((userId, userData) {
          if (userId != currentUserId) {
            ChatUser user = ChatUser(
              id: userId,
              name: userData['name'].toString(),
              email: userData['email'].toString(),
              about: userData['about'].toString(),
              image: userData['image'].toString(),
              createdAt: userData['created_at'].toString(),
              isOnline: userData['is_online'],
              lastActive: userData['last_active'].toString(),
              pushToken: userData['push_token'].toString(),
            );
            userList.add(user);
          }
        });
      }

      return userList;
    });
  }

  Future<void> sendMessage(
      String sender, String receiver, String message, bool notify) async {
    debugPrint("dataSend: $sender $receiver $message $bool");
    DatabaseReference reference = FirebaseDatabase.instance.ref();

    Map<String, dynamic> hashMap = {
      "sender": sender,
      "receiver": receiver,
      "message": message,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    await reference.child("Chats").push().set(hashMap);

    final String msg = message;

    reference = FirebaseDatabase.instance.ref().child("users").child(user.uid);

    try {
      // Use `onValue` instead of `once` to listen to the event
      reference.onValue.listen((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> userData =
              event.snapshot.value as Map<dynamic, dynamic>;
          String userName = userData[
              "name"]; // Replace "userName" with the actual key for the username in your data structure
          debugPrint("user nam found is $userName");
          // Assuming you have a method to send notifications here
          if (notify) {
            print("Notification sent");
            sendPushNotification(receiver, userName, msg, "0");
          }
          notify = false;
        } else {
          // Handle the case when the snapshot value is null
          print("Snapshot value is null");
        }
      });
    } catch (error) {
      // Handle any errors
      print("Error: $error");
    }

    /*try {
      DataSnapshot dataSnapshot = await reference.once();
      Map<dynamic, dynamic> userData = dataSnapshot.value;
      String userName = userData["userName"]; // Replace "userName" with the actual key for the username in your data structure

      // Assuming you have a method to send notifications here
      if (notify) {
        print("Notification sent");
        sendPushNotification(receiver, userName, msg, "0");
      }
      notify = false;
    } catch (error) {
      // Handle any errors
      print("Error: $error");
    }*/
  }

  static Stream<List<MessageDb>> getConversation(String sender, String receiver) {
    DatabaseReference reference = FirebaseDatabase.instance.ref().child("Chats");

    // Use `orderByChild` to filter messages based on sender and receiver
    Query query = reference.orderByChild('timestamp');

    // Use `equalTo` to get messages sent by the sender to the receiver
    query = query.equalTo(sender + "_" + receiver);

    // Listen for data changes in the messages node
    return query.onValue.map((event) {
      List<MessageDb> conversation = [];
      if (event.snapshot.value != null) {
        // Perform an explicit cast to Map<dynamic, dynamic>
        Map<dynamic, dynamic> messageData = event.snapshot.value as Map<dynamic, dynamic>;
        messageData.forEach((key, value) {
          // Create a Message instance from the message data
          MessageDb message = MessageDb.fromMap(value);
          conversation.add(message);
        });
      } else {
        print("No messages found!");
      }
      return conversation;
    });
  }




// Function to fetch user data from Firebase Realtime Database

/*static Stream<Event> getUserInfo(ChatUser chatUser) {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users');

    return userRef
        .orderByChild('id')
        .equalTo(chatUser.id)
        .onValue;
  }*/

/*static Stream<List<ChatUser>> getAllUsers() {
    DatabaseReference _userRef =
    FirebaseDatabase.instance.ref().child('users');

    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return _userRef.onValue.map((event) {
      List<ChatUser> userList = [];
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic> usersData =
        dataSnapshot.value as Map<dynamic, dynamic>; // Explicit casting

        usersData.forEach((userId, userData) {
          if (userId != currentUserId) {
            ChatUser user = ChatUser(
              id: userId,
              name: userData['name'].toString(),
              email: userData['email'].toString(),
              about: userData['about'].toString(),
              image: userData['image'].toString(),
              createdAt: userData['createdAt'].toString(),
              isOnline: userData['isOnline'],
              lastActive: userData['lastActive'].toString(),
              pushToken: userData['pushToken'].toString(),
            );
            userList.add(user);
          }
        });
      }

      return userList;
    });
  }*/

// for getting id's of known users from firestore database
// static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
//   return firestore
//       .collection('users')
//       .doc(user.uid)
//       .collection('my_users')
//       .snapshots();
// }

// for getting all users from firestore database
// static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
//     List<String> userIds) {
//   log('\nUserIds: $userIds');
//
//   return firestore
//       .collection('users')
//       .where('id',
//       whereIn: userIds.isEmpty
//           ? ['']
//           : userIds) //because empty list throws an error
//   // .where('id', isNotEqualTo: user.uid)
//       .snapshots();
// }

// for adding an user to my user when first message is send
// static Future<void> sendFirstMessage(
//     ChatUser chatUser, String msg, Type type) async {
//   await firestore
//       .collection('users')
//       .doc(chatUser.id)
//       .collection('my_users')
//       .doc(user.uid)
//       .set({}).then((value) => sendMessage(chatUser, msg, type));
// }

// for updating user information
// static Future<void> updateUserInfo() async {
//   await firestore.collection('users').doc(user.uid).update({
//     'name': me.name,
//     'about': me.about,
//   });
// }

// update profile picture of user
// static Future<void> updateProfilePicture(File file) async {
//   //getting image file extension
//   final ext = file.path.split('.').last;
//   log('Extension: $ext');
//
//   //storage file ref with path
//   final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
//
//   //uploading image
//   await ref
//       .putFile(file, SettableMetadata(contentType: 'image/$ext'))
//       .then((p0) {
//     log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
//   });
//
//   //updating image in firestore database
//   me.image = await ref.getDownloadURL();
//   await firestore
//       .collection('users')
//       .doc(user.uid)
//       .update({'image': me.image});
// }

// for getting specific user info
// static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
//     ChatUser chatUser) {
//   return firestore
//       .collection('users')
//       .where('id', isEqualTo: chatUser.id)
//       .snapshots();
// }

// update online or last active status of user
// static Future<void> updateActiveStatus(bool isOnline) async {
//   firestore.collection('users').doc(user.uid).update({
//     'is_online': isOnline,
//     'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
//     'push_token': me.pushToken,
//   });
// }

  ///************** Chat Screen Related APIs **************

// chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

// useful for getting conversation id
// static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
//     ? '${user.uid}_$id'
//     : '${id}_${user.uid}';
//
// // for getting all messages of a specific conversation from firestore database
// static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
//     ChatUser user) {
//   return firestore
//       .collection('chats/${getConversationID(user.id)}/messages/')
//       .orderBy('sent', descending: true)
//       .snapshots();
// }

// for sending message
// static Future<void> sendMessage(
//     ChatUser chatUser, String msg, Type type) async {
//   //message sending time (also used as id)
//   final time = DateTime.now().millisecondsSinceEpoch.toString();
//
//   //message to send
//   final Message message = Message(
//       toId: chatUser.id,
//       msg: msg,
//       read: '',
//       type: type,
//       fromId: user.uid,
//       sent: time);
//
//   final ref = firestore
//       .collection('chats/${getConversationID(chatUser.id)}/messages/');
//   await ref.doc(time).set(message.toJson()).then((value) =>
//       sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
// }

//update read status of message
// static Future<void> updateMessageReadStatus(Message message) async {
//   firestore
//       .collection('chats/${getConversationID(message.fromId)}/messages/')
//       .doc(message.sent)
//       .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
// }
//
// //get only last message of a specific chat
// static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
//     ChatUser user) {
//   return firestore
//       .collection('chats/${getConversationID(user.id)}/messages/')
//       .orderBy('sent', descending: true)
//       .limit(1)
//       .snapshots();
// }
//
// //send chat image
// static Future<void> sendChatImage(ChatUser chatUser, File file) async {
//   //getting image file extension
//   final ext = file.path.split('.').last;
//
//   //storage file ref with path
//   final ref = storage.ref().child(
//       'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
//
//   //uploading image
//   await ref
//       .putFile(file, SettableMetadata(contentType: 'image/$ext'))
//       .then((p0) {
//     log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
//   });
//
//   //updating image in firestore database
//   final imageUrl = await ref.getDownloadURL();
//   await sendMessage(chatUser, imageUrl, Type.image);
// }
//
// //delete message
// static Future<void> deleteMessage(Message message) async {
//   await firestore
//       .collection('chats/${getConversationID(message.toId)}/messages/')
//       .doc(message.sent)
//       .delete();
//
//   if (message.type == Type.image) {
//     await storage.refFromURL(message.msg).delete();
//   }
// }
//
// //update message
// static Future<void> updateMessage(Message message, String updatedMsg) async {
//   await firestore
//       .collection('chats/${getConversationID(message.toId)}/messages/')
//       .doc(message.sent)
//       .update({'msg': updatedMsg});
// }
}
