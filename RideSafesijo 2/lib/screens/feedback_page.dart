import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ridesafe/screens/admin_page.dart';  // Add this import

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _feedbacks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    try {
      debugPrint('Starting to load feedbacks...'); 

      // First, check if we can access the table structure
      final response = await _supabase
          .from('user_feedback')
          .select('*');  // Select all columns to see what's available

      debugPrint('Raw response from Supabase: $response'); 

      if (response == null) {
        debugPrint('Response is null');
        setState(() {
          _feedbacks = [];
          _isLoading = false;
        });
        return;
      }

      // Convert response to List<Map>
      final feedbacksList = List<Map<String, dynamic>>.from(response);
      debugPrint('Converted feedbacks list: $feedbacksList'); 

      final feedbacksWithUserDetails = await Future.wait(
        feedbacksList.map((feedback) async {
          debugPrint('Processing feedback: $feedback'); // Debug each feedback item
          
          try {
            final userResponse = await _supabase
                .from('user_details')
                .select('full_name')
                .eq('id', feedback['user_id'])
                .single();
            
            debugPrint('User response: $userResponse');
            
            return {
              'id': feedback['id'],
              'user_id': feedback['user_id'],
              'rating': feedback['rating'] ?? 0,
              'feedback': feedback['feedback'] ?? feedback['feedback'] ?? '', // Try both column names
              'created_at': feedback['created_at'],
              'user_name': userResponse['full_name'] ?? 'Anonymous',
            };
          } catch (e) {
            debugPrint('Error fetching user details: $e');
            return {
              'id': feedback['id'],
              'user_id': feedback['user_id'],
              'rating': feedback['rating'] ?? 0,
              'feedback': feedback['feedback_text'] ?? feedback['feedback'] ?? '',
              'created_at': feedback['created_at'],
              'user_name': 'Anonymous',
            };
          }
        }),
      );

      debugPrint('Final processed feedbacks: $feedbacksWithUserDetails');

      setState(() {
        _feedbacks = feedbacksWithUserDetails;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error in _loadFeedbacks: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading feedbacks: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteFeedback(String feedbackId) async {
    try {
      await _supabase
          .from('user_feedback')
          .delete()
          .eq('id', feedbackId);
      
      _loadFeedbacks();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting feedback: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('User Feedback', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false, // This removes the back button
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _feedbacks.isEmpty
              ? const Center(
                  child: Text(
                    'No feedback available',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _feedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback = _feedbacks[index];
                    final createdAt = DateTime.parse(feedback['created_at']);
                    final formattedDate = 
                        '${createdAt.day}/${createdAt.month}/${createdAt.year}';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Colors.grey[900],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  feedback['user_name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteFeedback(feedback['id']),
                                ),
                              ],
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < (feedback['rating'] as int)
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              feedback['feedback'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}