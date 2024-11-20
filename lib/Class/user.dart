
class Users {
  final String id;
  final String userName;
  final String fullName;
  final String departmentId;
  final String gender;
  final String classId;
  final List<TrainingPoint> trainingPoint;
  final String email;
  final String? phone;
  final String? address;
  final List<EventRegistration> eventsRegistered;
  final List<String> roles;
  final int totalEventsRegistered;

  Users({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.departmentId,
    required this.gender,
    required this.classId,
    required this.trainingPoint,
    required this.email,
    this.phone,
    this.address,
    required this.eventsRegistered,
    required this.roles,
    required this.totalEventsRegistered,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      fullName: json['full_Name'] ?? '',
      departmentId: json['departmentId'] ?? '',
      gender: json['gender'] ?? '',
      classId: json['classId'] ?? '',
      trainingPoint: (json['training_point'] as List? ?? [])
          .map((tp) => TrainingPoint.fromJson(tp))
          .toList(),
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      eventsRegistered: (json['eventsRegistered'] as List? ?? [])
          .map((event) => EventRegistration.fromJson(event))
          .toList(),
      roles: List<String>.from(json['roles'] ?? []),
      totalEventsRegistered: json['totalEventsRegistered'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'full_Name': fullName,
      'departmentId': departmentId,
      'gender': gender,
      'classId': classId,
      'training_point': trainingPoint.map((tp) => tp.toJson()).toList(),
      'email': email,
      'phone': phone,
      'address': address,
      'eventsRegistered': eventsRegistered.map((event) => event.toJson()).toList(),
      'roles': roles,
      'totalEventsRegistered': totalEventsRegistered,
    };
  }
}

  class TrainingPoint {
    final int semesterOne;
    final int semesterTwo;
    final int semesterThree;
    final int semesterFour;
    final int semesterFive;
    final int semesterSix;
    final int semesterSeven;
    final int semesterEight;

    TrainingPoint({
      required this.semesterOne,
      required this.semesterTwo,
      required this.semesterThree,
      required this.semesterFour,
      required this.semesterFive,
      required this.semesterSix,
      required this.semesterSeven,
      required this.semesterEight,
    });

    factory TrainingPoint.fromJson(Map<String, dynamic> json) {
      return TrainingPoint(
        semesterOne: json['semesterOne'] ?? 0,
        semesterTwo: json['semesterTwo'] ?? 0,
        semesterThree: json['semesterThree'] ?? 0,
        semesterFour: json['semesterFour'] ?? 0,
        semesterFive: json['semesterFive'] ?? 0,
        semesterSix: json['semesterSix'] ?? 0,
        semesterSeven: json['semesterSeven'] ?? 0,
        semesterEight: json['semesterEight'] ?? 0,
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'semesterOne': semesterOne,
        'semesterTwo': semesterTwo,
        'semesterThree': semesterThree,
        'semesterFour': semesterFour,
        'semesterFive': semesterFive,
        'semesterSix': semesterSix,
        'semesterSeven': semesterSeven,
        'semesterEight': semesterEight,
      };
    }
  }

class EventRegistration {
  final String eventId;
  final String name;
  final DateTime registrationDate;
  final String qrCode;
  final bool checkInStatus;
  final DateTime? checkInTime;
  final bool checkOutStatus;
  final DateTime? checkOutTime;

  EventRegistration({
    required this.eventId,
    required this.name,
    required this.registrationDate,
    required this.qrCode,
    required this.checkInStatus,
    this.checkInTime,
    required this.checkOutStatus,
    this.checkOutTime,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      eventId: json['eventId'] ?? '',
      name: json['name'] ?? 'Chưa bổ sung',
      registrationDate: DateTime.parse(json['registrationDate']),
      qrCode: json['qrCode'] ?? '',
      checkInStatus: json['checkInStatus'] ?? false,
      checkInTime: json['checkInTime'] != null ? DateTime.parse(json['checkInTime']) : null,
      checkOutStatus: json['checkOutStatus'] ?? false,
      checkOutTime: json['checkOutTime'] != null ? DateTime.parse(json['checkOutTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'name': name,
      'registrationDate': registrationDate.toIso8601String(),
      'qrCode': qrCode,
      'checkInStatus': checkInStatus,
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutStatus': checkOutStatus,
      'checkOutTime': checkOutTime?.toIso8601String(),
    };
  }
}

class Notifications {
  // ignore: non_constant_identifier_names
  final String notification_id;
  final String createUser;
  final String message;
  final DateTime createDate;
  final bool isRead;

  Notifications({
    // ignore: non_constant_identifier_names
    required this.notification_id,
    required this.createUser,
    required this.message,
    required this.createDate,
    required this.isRead,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      notification_id: json['notification_id'] ?? '',
      createUser: json['createUser'] ?? '',
      message: json['message'] ?? '',
      createDate: DateTime.parse(json['createDate']),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notification_id,
      'createUser': createUser,
      'message': message,
      'createDate': createDate.toIso8601String(),
      'isRead': isRead,
    };
  }
}