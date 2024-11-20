import 'dart:async';
import 'package:eventmanagement/Component/button_access.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventmanagement/Service/info_account.dart';
import 'package:eventmanagement/Service/crud_event_service.dart';
import 'package:eventmanagement/Class/user.dart';
import 'package:eventmanagement/Class/event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => StudentDashboardState();
}

class StudentDashboardState extends State<StudentDashboard> {
  Timer? _timer;
  late Future<Users?> _userInfoFuture;
  Future<List<Event>>? _eventsFuture;

  @override
  void initState() {
    super.initState();
    _userInfoFuture = InfoAccountService().fetchUserInfo();
    _loadEvents();
  }

  void _loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? departmentId = prefs.getString('departmentId');
    setState(() {
      _eventsFuture = CrudEventService().fetchEvents().then((events) {
        return events.where((event) {
          return (event.departmentId == 'EN' || event.departmentId == departmentId);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 25, 117, 215),
                  Color.fromARGB(255, 255, 255, 255),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FutureBuilder<Users?>(
                            future: _userInfoFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Text("Error loading user info");
                              } else if (snapshot.hasData) {
                                return Text(
                                  snapshot.data?.fullName ?? "Unknown User",
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 25, 25, 25),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                );
                              } else {
                                return const Text("No user info available");
                              }
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go('/profile');
                            },
                            child: const CircleAvatar(
                              backgroundImage: AssetImage('assets/images/avatar.png'),
                              radius: 25,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Sự kiện sắp tới",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: FutureBuilder<List<Event>>(
                                    future: _eventsFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return const Center(child: Text("Error loading events"));
                                      } else if (snapshot.hasData) {
                                        final events = snapshot.data!;
                                        return ListView.builder(
                                          itemCount: events.length,
                                          itemBuilder: (context, index) {
                                            final event = events[index];
                                            return _buildEventCard(
                                              event,
                                              event.name,
                                              event.dateStart.toIso8601String(),
                                              event.dateEnd.toIso8601String(),
                                              event.locationId,
                                            );
                                          },
                                        );
                                      } else {
                                        return const Center(child: Text("No events available"));
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    CustomElevatedButton(
                                      onPressed: () {
                                        context.go('/list_event');
                                      },
                                      text: "Sự kiện",
                                      color: Colors.white,
                                      textColor: Colors.black,
                                      icon: Icons.event,
                                    ),
                                    const SizedBox(height: 10),
                                    CustomElevatedButton(
                                      onPressed: () {
                                        context.go('/student/profile');
                                      },
                                      text: "Điểm danh",
                                      color: Colors.white,
                                      textColor: Colors.black,
                                      icon: Icons.qr_code_scanner,
                                    ),
                                    const SizedBox(height: 10),
                                    CustomElevatedButton(
                                      onPressed: () {
                                        context.go('/student/profile');
                                      },
                                      text: "Thông báo ",
                                      color: Colors.white,
                                      textColor: Colors.black,
                                      icon: Icons.notifications,
                                    ),
                                    const SizedBox(height: 10),
                                    CustomElevatedButton(
                                      onPressed: () {
                                        context.go('/student/profile');
                                      },
                                      text: "Lịch sử",
                                      color: Colors.white,
                                      textColor: Colors.black,
                                      icon: Icons.history,
                                    ),
                                    const SizedBox(height: 10),
                                    CustomElevatedButton(
                                      onPressed: () {
                                        context.go('/student/profile');
                                      },
                                      text: "Cài đặt",
                                      color: Colors.white,
                                      textColor: Colors.black,
                                      icon: Icons.settings,

                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(dynamic event, String title, String dateStart, String dateEnd, String location) {
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy - HH:mm'); // Define the date format

    // Adjust the dateStart and dateEnd by adding 9 hours
    final adjustedDateStart = DateTime.parse(dateStart).add(const Duration(hours: 7));
    final adjustedDateEnd = DateTime.parse(dateEnd).add(const Duration(hours: 7));

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/student/event');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    "Ngày bắt đầu: ${dateFormat.format(adjustedDateStart)}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    "Ngày kết thúc: ${dateFormat.format(adjustedDateEnd)}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    "Địa điểm: $location",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: CustomElevatedButton(onPressed: () {}, text: "Xem chi tiết", color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}