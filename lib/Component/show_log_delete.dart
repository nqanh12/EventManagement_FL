import 'package:eventmanagement/Component/diglog_load.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:flutter/material.dart';

class ShowLogDelete extends StatefulWidget {
  const ShowLogDelete({super.key});

  @override
  ShowLogDeleteState createState() => ShowLogDeleteState();
}

class ShowLogDeleteState extends State<ShowLogDelete> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Placeholder widget
  }

  Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder  (
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: CustomText(
                text: title,
                fontSize: 20,
                color: Colors.black,
              ),
              content: CustomText(
                text: content,
                fontSize: 16,
                color: Colors.black,
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: Colors.red,
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : CustomText(
                    text: 'Hủy',
                    fontSize: MediaQuery.of(context).size.width * 0.01,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    onConfirm();
                    showLod(context, 'Đang xóa', 'Vui lòng đợi giây lát....');

                    Navigator.of(context).pop();
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : CustomText(
                    text: "Xóa",
                    fontSize: MediaQuery.of(context).size.width * 0.01,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}