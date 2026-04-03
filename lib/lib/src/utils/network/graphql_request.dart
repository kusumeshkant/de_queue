class GraphQLRequest {
  final String query;
  final Map<String, dynamic>? variables;

  GraphQLRequest({
    required this.query,
    this.variables,
  });

  Map<String, dynamic> toJson() {
    return {
      "query": query,
      "variables": variables,
    };
  }
}
