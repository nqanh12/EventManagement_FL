import 'package:eventmanagement/Class/feedback.dart';
import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Component/text_font_list.dart';
import 'package:eventmanagement/Until/format_date.dart';
import 'package:eventmanagement/Service/feedback_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeedbackListScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  const FeedbackListScreen({super.key, required this.eventId, required this.eventName});

  @override
  FeedbackListScreenState createState() => FeedbackListScreenState();
}

class FeedbackListScreenState extends State<FeedbackListScreen> {
  late Future<List<Feedbacks>> _feedbacksFuture;

  @override
  void initState() {
    super.initState();
    _feedbacksFuture = _fetchFeedbacks();
  }

  Future<List<Feedbacks>> _fetchFeedbacks() async {
    FeedbackService feedbackService = FeedbackService();
    List<Feedbacks> feedbacks = await feedbackService.fetchFeedbacks(widget.eventId);
    feedbacks.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    return feedbacks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: "Feedback của sự kiện ${widget.eventName}", fontSize: 24, color: Colors.white),
        backgroundColor: Color(0xFF2E3034),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/participant_list/${widget.eventId}/${widget.eventName}');
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E3034),
              Color(0xFF2E3034),
            ],
          ),
        ),
        child: FutureBuilder<List<Feedbacks>>(
          future: _feedbacksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(child: CustomText(text: "Hiện tại không có phản hồi nào", fontSize: 20, color: Colors.white));
            } else {
              final feedbacks = snapshot.data!;
              return ListView.builder(
                itemCount: feedbacks.length,
                itemBuilder: (context, index) {
                  final feedback = feedbacks[index];
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: ListTile(
                      title: CustomTextList(
                        text: feedback.userName,
                        fontSize: 21,
                        color: Colors.black,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextList(
                            text: feedback.feedback,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          CustomTextList(
                            text: 'Ngày gửi: ${DateFormatUtil.formatDateTime(feedback.createdDate)}',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          CustomTextList(
                            text: 'Trạng thái: ${feedback.confirm ? "Đã duyệt" : "Chưa duyệt"}',
                            fontSize: 14,
                            color: feedback.confirm ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                      leading: Icon(Icons.feedback, color: Colors.blue),
                      trailing: Visibility(
                        visible: !feedback.confirm,
                        child: CustomElevatedButton(
                          onPressed: () async {
                            await FeedbackService().changeFeedbackConfirmStatus(feedback.id);
                            setState(() {
                              _feedbacksFuture = _fetchFeedbacks();
                            });
                          },
                          text: 'Xác nhận',
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}