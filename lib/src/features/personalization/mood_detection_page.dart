import 'package:flutter/material.dart';

class MoodDetectionPage extends StatelessWidget{
  const MoodDetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CardStackAnimation();
  }
}


class CardItemData {
  final String title;
  final String subtitle;
  final Widget expandedContent;
  final Color color;
  bool isCompleted;

  CardItemData({
    required this.title,
    required this.subtitle,
    required this.expandedContent,
    required this.color,
    this.isCompleted = false,
  });
}

class MoodSetupScreen extends StatefulWidget {
  const MoodSetupScreen({super.key});

  @override
  State<MoodSetupScreen> createState() => _MoodSetupScreenState();
}

class _MoodSetupScreenState extends State<MoodSetupScreen> {
  int _currentlyExpandedIndex = 0; // Initially first card is expanded
  final double _cardHeaderHeight = 80.0;
  final double _cardOverlap = 40.0;

  late List<CardItemData> _cardItems;

  @override
  void initState() {
    super.initState();
    _cardItems = [
      CardItemData(
        title: 'Camera',
        subtitle: "Let's capture your vibe! 😎",
        expandedContent: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'Camera Goes Here',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
           /* ElevatedButton(
              onPressed: () => _markAsDone(0),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(200, 50)),
              child: const Text('Done >'),
            ),*/
          ],
        ),
        color: const Color(0xFFD0BCFF), // Light Purple
      ),
      CardItemData(
        title: 'Your Voice',
        subtitle: 'Speak your mood and let Funli understand! 💎',
        expandedContent: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2)
              ),
              child: const Icon(Icons.mic, size: 50, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            const Text('Tap & Hold the button\nto speak your feelings', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _markAsDone(1),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(200, 50)),
              child: const Text('Done >'),
            ),
          ],
        ),
        color: const Color(0xFFF000B8), // Magenta
      ),
      CardItemData(
        title: 'Your Texts',
        subtitle: "Type how you're feeling today.",
        expandedContent: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Type your feelings here...', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'My feelings are...',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _markAsDone(2),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(200, 50)),
              child: const Text('✓ Done'),
            ),
          ],
        ),
        color: const Color(0xFF00BCD4), // Cyan
      ),
    ];
  }

  void _markAsDone(int index) {
    setState(() {
      _cardItems[index].isCompleted = true;
      // Expansion is now handled by _toggleCardExpansion on tap.
      // We no longer automatically expand the next card here.

      // Check if all items are completed to collapse all cards.
      bool allCompleted = _cardItems.every((item) => item.isCompleted);
      if (allCompleted) {
        _currentlyExpandedIndex = -1; // Collapse all cards
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All steps completed!')),
        );
      }
    });
  }

  void _toggleCardExpansion(int index) {
    setState(() {
      if (_cardItems[index].isCompleted && _currentlyExpandedIndex == index) {
        // If a completed card is tapped and it's already expanded, collapse it.
        // Or, if we want completed cards to stay expanded once tapped, remove this specific collapse.
        // However, the original image implies completed sections are not re-expandable in the same way.
        // For now, let's allow collapsing a completed card if it's the one expanded.
        // _currentlyExpandedIndex = -1;
        // return;
      }
      // If a card is completed, don't allow it to become the _currentlyExpandedIndex unless it's to collapse it.
      // The original logic was: if (_cardItems[index].isCompleted) return;
      // This prevented any interaction with completed cards. Let's refine this.
      // A user might want to tap a completed card to collapse it if it's expanded.

      // Only allow expansion if it's the current step or a previous uncompleted one (original logic)
      // OR if the card is already the one expanded (to allow collapsing it)
      // OR if all previous cards are completed.
      bool canInteract = true;
      if (!_cardItems[index].isCompleted) { // If the card is not yet completed
        for(int i=0; i<index; i++){
          if(!_cardItems[i].isCompleted){
            canInteract = false; // Previous step not done
            break;
          }
        }
      }

      if(canInteract){
        _currentlyExpandedIndex = (_currentlyExpandedIndex == index) ? -1 : index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Mood Detection Setup', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // Handle back navigation
          },
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Nice Job! Let's personalize Funli for you",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: List.generate(_cardItems.length, (index) {
                final item = _cardItems[index];
                final isExpanded = _currentlyExpandedIndex == index;
                final topPosition = index * (_cardHeaderHeight - _cardOverlap);
                final cardHeight = isExpanded
                    ? screenHeight - topPadding - kToolbarHeight - (index * (_cardHeaderHeight - _cardOverlap)) - 100 // Adjust 100 for bottom padding/elements
                    : _cardHeaderHeight;

                double offsetDueToExpandedAbove = 0;
                for (int i = 0; i < index; i++) {
                  if (_currentlyExpandedIndex == i) {
                    double expandedHeightAbove = screenHeight - topPadding - kToolbarHeight - (i * (_cardHeaderHeight - _cardOverlap)) -100;
                    offsetDueToExpandedAbove += (expandedHeightAbove - _cardHeaderHeight);
                  }
                }

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: topPosition + offsetDueToExpandedAbove,
                  left: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => _toggleCardExpansion(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: cardHeight,
                      width: MediaQuery.of(context).size.width - 40,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,5))]
                      ),
                      child: SingleChildScrollView(
                        physics: isExpanded ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                    if (!isExpanded)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(item.subtitle, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                                      ),
                                  ],
                                ),
                                if (item.isCompleted)
                                  const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 12,
                                    child: Icon(Icons.check, size: 16, color: Colors.green),
                                  )
                                else if (isExpanded && !item.isCompleted)
                                  Container()
                                else if (!item.isCompleted && _currentlyExpandedIndex != -1 && index <= _currentlyExpandedIndex && _cardItems.take(index).every((e) => e.isCompleted))
                                    const CircleAvatar(
                                      backgroundColor: Colors.white24,
                                      radius: 12,
                                      child: Icon(Icons.circle_outlined, size: 16, color: Colors.white70),
                                    )
                              ],
                            ),
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: SizedBox(
                                    height: cardHeight - _cardHeaderHeight - 40, // Account for padding
                                    child: item.expandedContent
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).reversed.toList(),
            ),
          ),
        ],
      ),
    );
  }
}



class CardStackAnimation extends StatefulWidget {
  const CardStackAnimation({super.key});

  @override
  State<StatefulWidget> createState() => _CardStackAnimation();
}

double topOffset = 100;
double expandedCardTop = topOffset;
double expandedHeight = 360;
double card1Top = expandedCardTop;
double card2Top = expandedCardTop + 60;
double card3Top = expandedCardTop + expandedHeight;
bool animateHeight = false;
int selectedCard = 1;

class _CardStackAnimation extends State<CardStackAnimation> {

  final double sideMargin = 16;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0XFFf6f5ff),
        alignment: Alignment.topCenter,
        child: Stack(
          children: [
            /**
             *  Summary card 1
             *  */
            Positioned(
                top: expandedCardTop.forFirstStackCard,
                left: sideMargin,
                right: sideMargin,
                child: SummaryCard(
                  leadingIcon: Icons.food_bank,
                  title: 'Savings PRO',
                  subTitle: 'Tap to see more',
                  onClick: () {
                    _update(1, topOffset);
                  },
                )
            ),
            /**
             *  Summary card 3
             *  */
            Positioned(
                top: 460,
                left: sideMargin,
                right: sideMargin,
                child: SummaryCard(
                  alignment: Alignment.bottomCenter,
                  leadingIcon: Icons.attach_money,
                  title: 'Loans',
                  subTitle: 'Get up to 5 Lakhs',
                  onClick: () {
                    _update(3, 220);
                  },
                )
            ),
            /**
             *  Summary card 2
             *  */
            Positioned(
                top: expandedCardTop.forSecondStackCard,
                left: sideMargin,
                right: sideMargin,
                child: SummaryCard(
                  alignment: expandedCardTop == 220 ? Alignment.topCenter : Alignment.bottomCenter,
                  leadingIcon: Icons.credit_card,
                  title: 'Credit Card',
                  subTitle: 'Limit upto 3 Lakhs',
                  onClick: () {
                    _update(2, 160);
                  },
                )
            ),
            /**
             *  Expanded card
             *  */
            AnimatedPositioned(
              duration: Duration(milliseconds: animateHeight ? 10 : 250),
              onEnd: () {
                setState(() {
                  animateHeight = false;
                });
              },
              curve: Curves.fastEaseInToSlowEaseOut,
              height: 360,
              left: sideMargin,
              right: sideMargin,
              top: animateHeight ? (expandedCardTop + 20) : expandedCardTop,
              child: ExpandedCard(
                title: _majorCardTitle,
                icon: _majorCardIcon,
              ),
            ),
          ],
        )
    );
  }

  String get _majorCardTitle {
    return selectedCard == 1
        ? 'Savings PRO'
        : (selectedCard == 2 ? 'Credit Card' : 'Loans');
  }

  IconData get _majorCardIcon {
    return selectedCard == 1
        ? Icons.food_bank
        : (selectedCard == 2 ? Icons.credit_card : Icons.attach_money);
  }

  _update(int cardIdx, double cardTop) {
    setState(() {
      selectedCard = cardIdx;
      expandedCardTop = cardTop;
      animateHeight = true;
    });
  }
}

extension CardTopExt on double {

  double get forFirstStackCard => this == topOffset ? 280 : topOffset;
  double get forSecondStackCard => this == 220 ? 160 : 400;
}

class ExpandedCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const ExpandedCard({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    offset: const Offset(2, -2),
                    spreadRadius: 4,
                    blurRadius: 10,
                    color: Colors.black45.withAlpha(50)),
                BoxShadow(
                    offset: const Offset(2, 2),
                    spreadRadius: 4,
                    blurRadius: 10,
                    color: Colors.black45.withAlpha(50))
              ]),
          width: 300,
          height: 360,
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                  height: 16
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    title,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  icon,
                  color: Colors.red,
                  size: 50,
                ),
              )
            ],
          )
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final VoidCallback onClick;
  final IconData leadingIcon;
  final String title;
  final String subTitle;
  final Alignment alignment;

  const SummaryCard(
      {super.key,
        required this.onClick,
        required this.leadingIcon,
        required this.title,
        this.alignment = Alignment.topCenter,
        required this.subTitle});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 14, color: Colors.black45);
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onClick,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    offset: const Offset(2, -2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    color: Colors.black45.withAlpha(50)),
                BoxShadow(
                    offset: const Offset(2, 2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    color: Colors.black45.withAlpha(50))
              ]),
          height: 120,
          alignment: alignment,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                ),
                Icon(
                  leadingIcon,
                  color: Colors.red,
                ),
                const SizedBox(
                  width: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textStyle,
                    ),
                    Text(
                      subTitle,
                      style: textStyle,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}