import 'package:flutter/material.dart';
import '../widgets/map_widget.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background for the whole menu
          Container(
            color: Colors.blue.shade50,
            child: Center(
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  'assets/Berliner_Polizei.png',
                  fit: BoxFit.contain,
                  width: 400,
                ),
              ),
            ),
          ),

          // 🔹 Foreground: App bar + grid
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.blue.shade100,
                elevation: 2,
                centerTitle: true,
                title: const Text(
                  'Rhekes Hood',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    itemCount: 50,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final level = index + 1;
                      final isUnlocked = level == 1;

                      return GestureDetector(
                        onTap: isUnlocked
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MapWidget(),
                            ),
                          );
                        }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? Colors.blue.shade100
                                : Colors.grey.shade300,
                            border: Border.all(color: Colors.black87, width: 1.2),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              if (isUnlocked)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (!isUnlocked)
                              // 🔒 Zoomed-in, slightly transparent police officer image
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Opacity(
                                      opacity: 0.3,
                                      child: Image.asset(
                                        'assets/officermainmenu.jpg',
                                        fit: BoxFit.cover,
                                        alignment: const Alignment(0.9, -1.2),
                                      ),
                                    ),
                                  ),
                                ),

                              if (isUnlocked)
                              // Background image for unlocked tile
                                Opacity(
                                  opacity: 0.1,
                                  child: Image.asset(
                                    'assets/Berliner_Polizei.png',
                                    fit: BoxFit.contain,
                                    width: 120,
                                  ),
                                ),

                              // 🔒 Lock or level label
                              Center(
                                child: isUnlocked
                                    ? Text(
                                  'Level $level',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                )
                                    : const Icon(
                                  Icons.lock,
                                  color: Colors.black,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
