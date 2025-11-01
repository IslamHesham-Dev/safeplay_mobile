import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Widget to extract and display all questions from Firebase questionTemplates collection
class QuestionExtractorWidget extends StatefulWidget {
  const QuestionExtractorWidget({super.key});

  @override
  State<QuestionExtractorWidget> createState() =>
      _QuestionExtractorWidgetState();
}

class _QuestionExtractorWidgetState extends State<QuestionExtractorWidget> {
  List<Map<String, dynamic>> questions = [];
  bool loading = false;
  String? error;
  Map<String, int> statistics = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // Load all question templates
      final snapshot = await firestore
          .collection('questionTemplates')
          .orderBy('createdAt', descending: true)
          .get();

      final questionsList = <Map<String, dynamic>>[];
      final stats = <String, int>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        questionsList.add({
          'id': doc.id,
          ...data,
        });

        // Collect statistics
        final type = data['type']?.toString() ?? 'Unknown';
        stats['Total Questions'] = (stats['Total Questions'] ?? 0) + 1;
        stats[type] = (stats[type] ?? 0) + 1;

        if (data['ageGroups'] != null && data['ageGroups'] is List) {
          for (final ageGroup in data['ageGroups'] as List) {
            stats['Age: ${ageGroup.toString()}'] =
                (stats['Age: ${ageGroup.toString()}'] ?? 0) + 1;
          }
        }

        if (data['subjects'] != null && data['subjects'] is List) {
          for (final subject in data['subjects'] as List) {
            stats['Subject: ${subject.toString()}'] =
                (stats['Subject: ${subject.toString()}'] ?? 0) + 1;
          }
        }

        if (data['difficulty'] != null) {
          stats['Difficulty: ${data['difficulty']}'] =
              (stats['Difficulty: ${data['difficulty']}'] ?? 0) + 1;
        }
      }

      setState(() {
        questions = questionsList;
        statistics = stats;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Question Extractor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuestions,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $error'),
                      ElevatedButton(
                        onPressed: _loadQuestions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistics
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📊 Statistics',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              ...statistics.entries.map((entry) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(entry.key),
                                        Text(
                                          '${entry.value}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Questions List
                      Text(
                        '📚 All Questions (${questions.length})',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ...questions
                          .map((question) => _buildQuestionCard(question)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['title'] ?? 'Untitled Question',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.tag, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('ID: ${question['id']}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Type: ${question['type'] ?? 'Unknown'}'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Prompt: ${question['prompt'] ?? question['question'] ?? 'No prompt'}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (question['options'] != null && question['options'] is List) ...[
              const SizedBox(height: 8),
              const Text('Options:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...(question['options'] as List).asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, top: 2),
                  child: Text('${entry.key + 1}. ${entry.value}'),
                );
              }),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                const SizedBox(width: 4),
                Text('Answer: ${question['correctAnswer'] ?? 'Not specified'}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.stars, size: 16, color: Colors.orange[600]),
                const SizedBox(width: 4),
                Text('Points: ${question['points'] ?? 0}'),
              ],
            ),
            if (question['skills'] != null && question['skills'] is List) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.school, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                        'Skills: ${(question['skills'] as List).join(', ')}'),
                  ),
                ],
              ),
            ],
            if (question['ageGroups'] != null &&
                question['ageGroups'] is List) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.child_care, size: 16, color: Colors.purple[600]),
                  const SizedBox(width: 4),
                  Text(
                      'Age Groups: ${(question['ageGroups'] as List).join(', ')}'),
                ],
              ),
            ],
            if (question['subjects'] != null &&
                question['subjects'] is List) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.book, size: 16, color: Colors.teal[600]),
                  const SizedBox(width: 4),
                  Text(
                      'Subjects: ${(question['subjects'] as List).join(', ')}'),
                ],
              ),
            ],
            if (question['difficulty'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.trending_up, size: 16, color: Colors.red[600]),
                  const SizedBox(width: 4),
                  Text('Difficulty: ${question['difficulty']}'),
                ],
              ),
            ],
            if (question['duration'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.indigo[600]),
                  const SizedBox(width: 4),
                  Text('Duration: ${question['duration']} minutes'),
                ],
              ),
            ],
            if (question['explanation'] != null) ...[
              const SizedBox(height: 8),
              const Text('Explanation:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(question['explanation']),
            ],
            if (question['hint'] != null) ...[
              const SizedBox(height: 8),
              const Text('Hint:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(question['hint']),
            ],
            if (question['isActive'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    question['isActive'] ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: question['isActive'] ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text('Active: ${question['isActive'] ? 'Yes' : 'No'}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
