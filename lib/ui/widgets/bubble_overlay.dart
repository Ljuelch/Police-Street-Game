import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BubbleOverlay extends StatelessWidget {
  final Map<String, dynamic>? address;

  const BubbleOverlay({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    final street = address?['street'] ?? '';
    final houseNumber = address?['houseNumber'] ?? '';
    final displayText = '$street $houseNumber';

    final callPhrases = [
      "Streifenwagen zur Kontrolle bitte fahren nach",
      "Anfahrt erforderlich, Zielort",
      "Bitte übernehmen Sie den Einsatz bei",
      "Dringender Einsatz in der Nähe von",
      "Streifenwagen bitte melden bei",
      "Einsatzauftrag: Anfahrt zu",
      "Polizeipräsenz benötigt in",
      "Bitte überprüfen Sie folgenden Ort"
    ];

    final intro = (address != null)
        ? (callPhrases..shuffle()).first
        : 'Adresse wird geladen...';

    return Container(
      key: const ValueKey('bubbleView'),
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          // Walkie-talkie
          Positioned(
            bottom: 0,
            left: 10,
            child: SvgPicture.asset(
              'assets/walkietalkie.svg',
              width: 190,
              height: 190,
            ),
          ),

          // Speech bubble with text
          Positioned(
            bottom: 140,
            left: 75,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/speechbubble.png',
                  width: 200,
                ),
                SizedBox(
                  width: 160,
                  height: 150,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: address != null
                          ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$intro:',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            displayText,
                            textAlign: TextAlign.center,
                            softWrap: true, // ✅ enables natural line break
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      )
                          : const Text(
                        'Adresse wird geladen...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
