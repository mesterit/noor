class ElasticQuery {
  static Map<String, dynamic> matchAll() => {'match_all': {}};

  static Map<String, dynamic> status({String status = 'publish'}) => {
        'match': {'status': status}
      };

  static Map<String, dynamic> bool({
    List<Map<String, dynamic>>? must,
    List<Map<String, dynamic>>? mustNot,
  }) {
    var query = <String, dynamic>{};
    if (must?.isNotEmpty ?? false) {
      query['must'] = must;
    }
    if (mustNot?.isNotEmpty ?? false) {
      query['must_not'] = mustNot;
    }
    return {'bool': query};
  }

  static Map<String, dynamic> queryString({
    required String query,
    required ElasticQueryOperator queryOperator,
    required dynamic fields,
  }) {
    return {
      'query_string': {
        'query': query,
        'default_operator': queryOperator.keyText,
        'fields': fields,
      }
    };
  }

  static Map<String, dynamic> match({
    required String key,
    required dynamic value,
  }) {
    return {
      'match': {key: value}
    };
  }

  static Map<String, dynamic> multiMatch({
    required String query,
    required List<String> fields,
  }) {
    return {
      'multi_match': {'query': query, 'fields': fields}
    };
  }

  static Map<String, dynamic> filter({
    required String keyFilter,
    required String key,
    required dynamic value,
  }) {
    return {
      keyFilter: {key: value}
    };
  }

  static Map<String, dynamic> range({
    required String key,
    num? gteValue,
    num? lteValue,
  }) {
    return {
      'range': {
        key: {
          'gte': gteValue ?? 0.0,
          'lte': lteValue ?? 0.0,
        }
      }
    };
  }
}

enum ElasticQueryOperator {
  and;

  String get keyText {
    switch (this) {
      case ElasticQueryOperator.and:
        return 'AND';
      default:
        return '';
    }
  }
}
