class Chat {
  final String chatId;
  final String lastMessage;
  final String timestamp;
  final List<String> users;

  Chat({
    required this.chatId,
    required this.lastMessage,
    required this.timestamp,
    required this.users,
  });

  // Local storage: List to store chat instances
  static List<Chat> chatList = [];

  // Method to add a chat locally
  static void addChat(Chat chat) {
    chatList.add(chat);
  }

  // Method to get all chats
  static List<Chat> getChats() {
    return chatList;
  }
}
