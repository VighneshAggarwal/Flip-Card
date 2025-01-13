class Game{
  final String hiddenCardpath = 'assets/images/Question_Mark.png';
  List<String>? gameImg;

  final List<String> card_list = [
    "assets/images/Jacket.jpeg",
    "assets/images/Perfume.jpeg",
    "assets/images/Shirt.jpeg",
    "assets/images/Jacket.jpeg",
    "assets/images/Perfume.jpeg",
    "assets/images/Shirt.jpeg",
  ];

  List<Map<int, String>> matchCheck = [];

  final int cardCount = 6;

  void initGame() {
    card_list.shuffle(); // Randomize the card order
    gameImg = List.generate(cardCount, (index) => hiddenCardpath);
  }
}
