import 'package:flutter/material.dart';

class WritingTipsPage extends StatelessWidget {
  const WritingTipsPage({Key? key}) : super(key: key);

  final List<String> tips = const [
    'Know your audience: Tailor your writing style to your target audience.',
    'Keep it simple: Avoid overly complicated words or phrases.',
    'Stay concise: Get to the point without unnecessary details.',
    'Use active voice: Make your writing more engaging by using active verbs.',
    'Proofread: Always re-read your work to catch errors and improve clarity.',
    'Use strong verbs: Replace weak or vague verbs with stronger ones.',
    'Vary sentence structure: Avoid monotony by mixing short and long sentences.',
    'Stay consistent: Maintain a consistent tone and style throughout your writing.'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Writing Tips',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigoAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tips.length,
                itemBuilder: (context, index) {
                  return _buildTipCard(index + 1, tips[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds each writing tip as a card
  Widget _buildTipCard(int tipNumber, String tip) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.indigoAccent,
              child: Text(
                '$tipNumber',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                tip,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
