import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:hngx_openai/repository/openai_repository.dart';
import 'package:travel_planner/app/presentation/chat/widgets/chat_bubble.dart';
import 'package:travel_planner/app/presentation/settings/screen/payment_screen.dart';
import 'package:travel_planner/app/router/base_navigator.dart';
import 'package:travel_planner/component/constants.dart';
import 'package:travel_planner/component/overlays/dialogs.dart';
import 'package:travel_planner/data/model/auth/user.dart';
import 'package:travel_planner/data/model/base_response.dart';
import 'package:travel_planner/data/model/conversation.dart';
import 'package:travel_planner/data/repositories/open_api/open_api_repo.dart';
import 'package:travel_planner/data/sqflite/conversation_model.dart';
import 'package:travel_planner/data/sqflite/message.dart';
import 'package:travel_planner/services/local_storage/shared_prefs.dart';
import 'package:travel_planner/services/local_storage/sqflite/sqflite_service.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = "chat";
  const ChatScreen({
    super.key,
    this.conversation,
    this.conversationModel,
  });
  final ObjConversation? conversation;
  final ConversationModel? conversationModel;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SqfLiteService sqlDb = SqfLiteService.instance;
  late ConversationModel conversationModel;
  ScrollController scrollController = ScrollController();
  final openAi = OpenApiRepo.instance;
  OpenAIRepository openAI = OpenAIRepository();
  final storage = AppStorage.instance;

  User? user;

  ValueNotifier<bool> sendLoading = ValueNotifier(false);

  final uid = const Uuid();

  final currentUser = ChatUser(
    id: "user",
    name: "user",
  );
  ChatController? _chatController;
  List<Message> messages = [];

  dbCheck() async {
    if (widget.conversationModel == null) {
      final id = uid.v1();
      ConversationModel conversation = ConversationModel(
        id: id,
        gptId: "testing-$id",
        title: "New Conversation",
        updatedAt: DateTime.now(),
      );
      sqlDb.addConversation(conversation);
      conversationModel = conversation;
      final dBmessages = await sqlDb.findMessages(conversationModel.gptId!);
      if (dBmessages.isNotEmpty) {
        messages = dBmessages
            .map(
              (element) => Message(
                id: element.id.toString(),
                message: element.message!,
                createdAt: element.createdAt!,
                sendBy: element.sentBy!,
              ),
            )
            .toList();
        setState(() {});
      } else {
        final id = uid.v1();
        final uiMessage = Message(
          id: id,
          message: "Hello Traveller! 👋 \n\nHow can I assist you today with your travel plans?",
          createdAt: DateTime.now(),
          sendBy: "AI",
        );
        final localMessage = Message(
          id: id,
          message: prompt,
          createdAt: DateTime.now(),
          sendBy: "AI",
        );
        messages.add(uiMessage);
        addMessageTolocalDB(localMessage);
        setState(() {});
      }
    } else {
      final s = await sqlDb.getConversation(widget.conversationModel!.gptId!);
      if (s != null) {
        conversationModel = s;
        final dBmessages = await sqlDb.findMessages(conversationModel.gptId!);
        if (dBmessages.isNotEmpty) {
          messages = dBmessages.map((element) {
            if (element.message == prompt) {
              return Message(
                id: element.id.toString(),
                message: "Hello Traveller! 👋 \n\nHow can I assist you today with your travel plans?",
                createdAt: element.createdAt!,
                sendBy: element.sentBy!,
              );
            }
            return Message(
              id: element.id.toString(),
              message: element.message!,
              createdAt: element.createdAt!,
              sendBy: element.sentBy!,
            );
          }).toList();
          setState(() {});
        } else {
          final id = uid.v1();
          final uiMessage = Message(
            id: id,
            message: "Hello Traveller! 👋 \n\nHow can I assist you today with your travel plans?",
            createdAt: DateTime.now(),
            sendBy: "AI",
          );
          final localMessage = Message(
            id: id,
            message: prompt,
            createdAt: DateTime.now(),
            sendBy: "AI",
          );
          addMessageTolocalDB(localMessage);
          messages.add(uiMessage);
        }
      }
    }
  }

  initChatController() {
    _chatController = ChatController(
      initialMessageList: messages,
      scrollController: scrollController,
      chatUsers: [
        ChatUser(
          id: "AI",
          name: "Travel Bot",
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    sqlDb.initMessageStream();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await dbCheck();
      initChatController();
      user = storage.getUserData();
    });
  }

  void addMessageTolocalDB(Message message) async {
    final localMessage = LocalMessage(
      id: message.id,
      conversationId: conversationModel.gptId,
      message: message.message,
      sentBy: message.sendBy,
      createdAt: message.createdAt,
      imageUrl: message.messageType == MessageType.image ? message.message : null,
    );
    sqlDb.addMessage(localMessage);
  }

  void _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) async {
    if (sendLoading.value) {
      return;
    }
    if (message.trim().isEmpty) {
      return;
    }

    sendLoading.value = true;
    final id = uid.v1();
    String sendingMessage;
    String sender;

    try {
      final newMessage = Message(
        id: id,
        createdAt: DateTime.now(),
        message: message,
        sendBy: currentUser.id,
        replyMessage: replyMessage,
        messageType: messageType,
      );
      List<String> messageLogs = [];
      for (var element in messages) {
        sendingMessage = element.message;
        sender = element.sendBy;
        if (sendingMessage == "Hello Traveller! 👋 \n\nHow can I assist you today with your travel plans?") {
          sendingMessage = prompt;
          sender = "user";
        }
        messageLogs.add(
          "$sender: $sendingMessage",
        );
      }

      messageLogs.insert(
        1,
        "AI: Of course! I'm here to help you with your travel planning needs. Please feel free to ask any questions related to travel, and I'll be happy to assist you in a friendly manner. If you have any non-travel related questions or statements, I'll kindly let you know that I focus on travel planning and can't provide assistance for other topics. How can I assist you with your travel plans today? 😊",
      );

      addMessageTolocalDB(newMessage);
      _chatController?.addMessage(newMessage);

      // final result = await openAi.interactWithLogs(
      //   messageLogs,
      //   newMessage.message,
      // );

      final response = await openAI.getChatCompletions(
        messageLogs,
        newMessage.message,
        storage.getToken(),
      );

      final result = BaseResponse.fromJson(response);
      if (result.error == null) {
        final aId = uid.v1();
        final reply = Message(
          id: aId,
          createdAt: DateTime.now(),
          message: result.message!,
          sendBy: "AI",
          replyMessage: replyMessage,
          messageType: messageType,
        );
        addMessageTolocalDB(reply);
        _chatController?.addMessage(reply);
        sendLoading.value = false;
        Future.delayed(const Duration(milliseconds: 300), () {
          _chatController?.initialMessageList.last.setStatus = MessageStatus.undelivered;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          _chatController?.initialMessageList.last.setStatus = MessageStatus.read;
        });
      } else {
        sendLoading.value = false;
        sqlDb.deleteMessage(id);
        messages.removeWhere((element) => element.id == id);
        setState(() {});
        if (
            // result.item1 != null
            result.error.toString().toLowerCase().contains("subscription required")) {
          if (mounted) {
            final s = await AppOverlays.chatPaymentDialog(context);
            if (!mounted) return;
            if (s == true) {
              BaseNavigator.pop();
              BaseNavigator.pushNamed(
                PaymentScreen.routeName,
                args: user?.id ?? "",
              );
            }
          }
        } else {
          if (mounted) {
            AppOverlays.chatErrorDialog(
              context: context,
              message: result.error,
            );
          }
        }
      }
    } catch (e) {
      sendLoading.value = false;
      sqlDb.deleteMessage(id);
      messages.removeWhere((element) => element.id == id);
      setState(() {});
      if (mounted) {
        AppOverlays.chatErrorDialog(
          context: context,
        );
      }
    }
  }

  @override
  void dispose() {
    _chatController?.dispose();
    sqlDb.closeMessageStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _chatController != null
            ? ValueListenableBuilder(
                valueListenable: sendLoading,
                builder: (context, loading, _) {
                  return ChatView(
                    appBar: AppBar(
                      title: Text(conversationModel.title ?? "TRAVEL PLANNER"),
                      backgroundColor: Colors.transparent,
                      scrolledUnderElevation: 0,
                    ),
                    chatBackgroundConfig: const ChatBackgroundConfiguration(
                      backgroundColor: Colors.transparent,
                    ),
                    showTypingIndicator: loading,
                    typeIndicatorConfig:
                        TypeIndicatorConfiguration(indicatorSize: 5, flashingCircleBrightColor: Colors.white, flashingCircleDarkColor: Colors.grey.shade200),
                    sendMessageConfig: SendMessageConfiguration(
                      textFieldBackgroundColor: Colors.blue[50],
                      defaultSendButtonColor: Colors.blue[400],
                      textFieldConfig: const TextFieldConfiguration(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        textStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      sendButtonIcon: ValueListenableBuilder(
                        valueListenable: sendLoading,
                        builder: (context, value, _) {
                          if (value) {
                            return const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            );
                          }
                          return const Icon(
                            Icons.send,
                          );
                        },
                      ),
                      enableCameraImagePicker: false,
                      enableGalleryImagePicker: false,
                      allowRecordingVoice: false,
                    ),
                    chatController: _chatController!,
                    onSendTap: _onSendTap,
                    currentUser: currentUser,
                    chatViewState: messages.isNotEmpty ? ChatViewState.hasMessages : ChatViewState.noData,
                    chatBubbleConfig: ChatBubbleConfiguration(
                      maxWidth: MediaQuery.of(context).size.width * .7,
                      inComingChatBubbleConfig: chatBubble(
                        sentByUser: false,
                        color: Colors.blue[400],
                        textColor: Colors.white,
                      ),
                      outgoingChatBubbleConfig: chatBubble(
                        sentByUser: true,
                        color: Colors.blue[200],
                        textColor: Colors.black,
                      ),
                    ),
                    chatViewStateConfig: const ChatViewStateConfiguration(noMessageWidgetConfig: ChatViewStateWidgetConfiguration(widget: SizedBox())),
                  );
                })
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator.adaptive(),
                  ],
                ),
              ),
      ),
    );
  }
}
