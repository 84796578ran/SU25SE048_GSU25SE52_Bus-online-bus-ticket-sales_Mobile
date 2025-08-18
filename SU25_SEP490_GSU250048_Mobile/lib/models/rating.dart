class Rating {
  final int ticketId;
  final int customerId;
  final int score;
  final String? comment;

  Rating({
    required this.ticketId,
    required this.customerId,
    required this.score,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'customerId': customerId,
      'score': score,
      'comment': comment,
    };
  }
}