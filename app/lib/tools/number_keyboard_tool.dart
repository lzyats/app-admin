import 'package:flutter/material.dart';

class NumberKeyboardTool {
  NumberKeyboardTool._();

  static Future<String?> show(
    BuildContext context, {
    String title = '请输入数字',
    String initialValue = '',
    int maxLength = 6,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        String value = initialValue;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void append(String text) {
              if (value.length >= maxLength) return;
              setState(() => value = '$value$text');
            }

            void backspace() {
              if (value.isEmpty) return;
              setState(() => value = value.substring(0, value.length - 1));
            }

            return SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF111736),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(context, value),
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      height: 44,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2148),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        value.isEmpty ? '请输入' : '•' * value.length,
                        style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2),
                      ),
                    ),
                    _NumberKeyboardGrid(
                      onTapNumber: append,
                      onBackspace: backspace,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _NumberKeyboardGrid extends StatelessWidget {
  const _NumberKeyboardGrid({
    required this.onTapNumber,
    required this.onBackspace,
  });

  final ValueChanged<String> onTapNumber;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final List<String> keys = <String>[
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '', '0', '⌫',
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.15,
      ),
      itemBuilder: (BuildContext context, int index) {
        final String key = keys[index];
        if (key.isEmpty) {
          return const SizedBox.shrink();
        }
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (key == '⌫') {
              onBackspace();
            } else {
              onTapNumber(key);
            }
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2A58),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              key,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }
}
