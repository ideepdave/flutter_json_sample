class Dao {
  String message;
  String status;

  Dao({this.message, this.status});

  factory Dao.fromJson(Map<String, dynamic> parsedJson){
    return Dao(
        message: parsedJson['message'],
        status : parsedJson['status'],
    );
  }
}
