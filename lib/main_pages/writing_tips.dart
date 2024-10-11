import 'package:flutter/material.dart';

class WritingTipsPage extends StatelessWidget {
  const WritingTipsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Tips'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              'Writing Tips',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '1. Know your audience: Tailor your writing style to your target audience.'
              '\n\n2. Keep it simple: Avoid overly complicated words or phrases.'
              '\n\n3. Stay concise: Get to the point without unnecessary details.'
              '\n\n4. Use active voice: Make your writing more engaging by using active verbs.'
              '\n\n5. Proofread: Always re-read your work to catch errors and improve clarity.'
              '\n\n6. Use strong verbs: Replace weak or vague verbs with stronger ones.'
              '\n\n7. Vary sentence structure: Avoid monotony by mixing short and long sentences.'
              '\n\n8. Stay consistent: Maintain a consistent tone and style throughout your writing.',
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
