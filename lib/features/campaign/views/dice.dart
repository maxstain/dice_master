import 'dart:math';

import 'package:flutter/material.dart';

class DiceRollerView extends StatefulWidget {
  const DiceRollerView({super.key});

  @override
  State<DiceRollerView> createState() => _DiceRollerViewState();
}

class _DiceRollerViewState extends State<DiceRollerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final d6Values = List.generate(6, (index) => index + 1);
  final d4Values = List.generate(4, (index) => index + 1);
  final d20Values = List.generate(20, (index) => index + 1);
  final d10Values = List.generate(10, (index) => index + 1);
  final d12Values = List.generate(12, (index) => index + 1);
  final d8Values = List.generate(8, (index) => index + 1);
  final d100Values = List.generate(100, (index) => index + 1);
  int dValue = 0;
  final history = [];
  var selectedDie = 4;
  final selectedColor = Colors.purple;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Roll the dice of fate!!",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 10 * (1 - _controller.value)),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.black26,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "$dValue",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedDie = d4Values.length;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedDie == d4Values.length
                          ? selectedColor
                          : Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("D4"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedDie = d6Values.length;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedDie == d6Values.length
                          ? selectedColor
                          : Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("D6"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedDie = d8Values.length;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedDie == d8Values.length
                          ? selectedColor
                          : Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("D8"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedDie = d10Values.length;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedDie == d10Values.length
                          ? selectedColor
                          : Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("D10"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedDie = d12Values.length;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedDie == d12Values.length
                          ? selectedColor
                          : Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("D12"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedDie = d20Values.length;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedDie == d20Values.length
                          ? selectedColor
                          : Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("D20"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedDie = d100Values.length;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedDie == d100Values.length
                          ? selectedColor
                          : Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("D100"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  dValue = Random().nextInt(selectedDie) + 1;
                  _controller.forward(from: 0);
                  history.add(dValue);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.4,
                  vertical: 16,
                ),
              ),
              child: const Text(
                "Roll",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Roll History",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            history.isEmpty
                ? Text(
                    "No Rolls yet",
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.titleSmall?.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text("Roll ${index + 1}: D$selectedDie"),
                          subtitle: Text("Value: ${history[index]}"),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
