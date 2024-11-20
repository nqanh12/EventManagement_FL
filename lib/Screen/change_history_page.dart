import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Service/historychange_service.dart';
import 'package:eventmanagement/Component/text_font_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
class ChangeStoreHistoryScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  const ChangeStoreHistoryScreen({super.key, required this.eventId, required this.eventName});

  @override
  ChangeStoreHistoryScreenState createState() => ChangeStoreHistoryScreenState();
}

class ChangeStoreHistoryScreenState extends State<ChangeStoreHistoryScreen> {
  late Future<List<ChangeStoreHistory>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchChangeStoreHistory();
  }

  Future<List<ChangeStoreHistory>> _fetchChangeStoreHistory() async {
    HistoryChangeService historyChangeService = HistoryChangeService();
    return await historyChangeService.fetchChangeStoreHistory(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: "Lịch sử thay đổi", fontSize: 24, color: Colors.white),
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
        child: FutureBuilder<List<ChangeStoreHistory>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(child: CustomText(text: "Hiện tại không có lịch sử thay đổi nào", fontSize: 20, color: Colors.white));
            } else {
              final history = snapshot.data!;
              return ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final change = history[index];
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: ListTile(
                      title: CustomTextList(
                        text: change.userName,
                        fontSize: 21,
                        color: Colors.black,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextList(
                            text: "${change.content} ${change.userNameChange}",
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          CustomTextList(
                            text: 'Ngày thay đổi: ${DateFormat('dd/MM/yyyy HH:mm').format(change.createdDate)}',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                      leading: Icon(Icons.history, color: Colors.blue),
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