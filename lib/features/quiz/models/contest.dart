//class Contest {
class Contests {
  Contests({required this.live, required this.past, required this.upcoming, required this.homeLive, required this.homeUpcoming});

  Contests.fromJson(Map<String, dynamic> json)
      : live = Contest.fromJson(json['live_contest'] as Map<String, dynamic>),
        past = Contest.fromJson(json['past_contest'] as Map<String, dynamic>),
        upcoming = Contest.fromJson(json['upcoming_contest'] as Map<String, dynamic>),
        homeLive = Contest.fromJson(json['home_live'] as Map<String, dynamic>),
        homeUpcoming = Contest.fromJson(json['home_upcoming'] as Map<String, dynamic>);

  final Contest past;
  final Contest live;
  final Contest upcoming;
  final Contest homeLive;
  final Contest homeUpcoming;
}

class Contest {
  Contest({required this.contestDetails, required this.errorMessage});

  Contest.fromJson(Map<String, dynamic> json) {
    final hasError = json['error'] as bool;
    errorMessage = hasError ? json['message'] as String : '';
    contestDetails = hasError
        ? <ContestDetails>[]
        : (json['data'] as List)
            .cast<Map<String, dynamic>>()
            .map(ContestDetails.fromJson)
            .toList(growable: false);
  }

  late final String errorMessage;
  late final List<ContestDetails> contestDetails;
}

class ContestDetails {
  ContestDetails({
    this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.description,
    this.image,
    this.entry,
    this.prizeStatus,
    this.dateCreated,
    this.status,
    this.topUsers,
    this.participants,
    this.contestTime,
    this.contestParticipantLimit,
    this.seatsLeft,
    this.registered,
    this.questionCount,
    this.rangesList,
    this.showDescription,
  });

  ContestDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    name = json['name'] as String?;
    startDate = json['start_date'] as String?;
    endDate = json['end_date'] as String?;
    startTime = json['start_time'] as String?;
    endTime = json['end_time'] as String?;
    description = json['description'] as String?;
    image = json['image'] as String?;
    entry = json['entry'] as String?;
    prizeStatus = json['prize_status'] as String?;
    dateCreated = json['date_created'] as String?;
    status = json['status'] as String?;
    topUsers = json['top_users'] as String?;
    participants = json['participants'] as String?;
    contestTime = json['contest_time'] as String?;
    contestParticipantLimit = json['contest_paticipant_limit'] as String?;
    seatsLeft = json['seats_left'] as String?;
    registered = json['registered'] as String?;
    questionCount = json['question_count'] as String?;
    rangesList = (json['ranges_list'] as Map?)?.cast<String, dynamic>();
  }

  String? id;
  String? name;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  String? description;
  String? image;
  String? entry;
  String? prizeStatus;
  String? dateCreated;
  String? status;
  String? topUsers;
  String? participants;
  String? contestTime;
  String? contestParticipantLimit;
  String? seatsLeft;
  String? registered;
  String? questionCount;
  Map<String, dynamic>? rangesList;
  bool? showDescription = false;
}
