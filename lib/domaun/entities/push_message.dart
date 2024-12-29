class PushMessage {
  final String messageId;
  final String title;
  final String body;
  final DateTime deteTime;
  final Map<String, dynamic>? data;
  final String? imageUrl;

  PushMessage({
    required this.messageId,
    required this.title, 
    required this.body, 
    required this.deteTime, 
    this.data, 
    this.imageUrl
    });

  @override
  String toString() {
    // TODO: implement toString
    return '''
      PushMessage:
        messageId: $messageId
        title:     $title
        body:      $body
        deteTime:  $deteTime
        data:      $data
        imageUrl:  $imageUrl
    ''';
  }  

}