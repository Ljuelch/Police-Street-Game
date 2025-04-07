import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BubbleOverlay extends StatelessWidget {
  final Map<String, dynamic>? address;

  const BubbleOverlay({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('bubbleView'),
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 10,
            child: SvgPicture.asset(
              'assets/walkietalkie.svg',
              width: 190,
              height: 190,
            ),
          ),
          Positioned(
            bottom: 140,
            left: 75,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/speechbubble.png',
                  width: 240,
                ),
                SizedBox(
                  width: 180,
                  child: Text(
                    address != null
                        ? '${address!['street']} ${address!['houseNumber']}'
                        : 'Adresse wird geladen...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
