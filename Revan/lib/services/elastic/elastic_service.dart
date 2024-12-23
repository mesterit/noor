import '../../common/config.dart';
import 'elastic_client.dart';
import 'elastic_query.dart';

class ElasticService {
  final Uri uri;
  final bool isBlog;

  ElasticService({
    required this.uri,
    this.isBlog = false,
    String? languageCode,
    String status = 'publish',
  }) {
    _initAlasticSercice(languageCode: languageCode, status: status);
  }

  final mustList = ElasticActionList();
  final mustNotList = ElasticActionList();
  final _sortList = <Map<String, dynamic>>[];

  void _initAlasticSercice({
    String? languageCode,
    String status = 'publish',
  }) {
    if (kBoostEngineConfig.isMultiLanguages) {
      String? lang;
      if (kBoostEngineConfig.languages.contains(languageCode)) {
        lang = languageCode;
      }

      lang ??= kBoostEngineConfig.defaultLanguage;
      if (lang?.isNotEmpty ?? false) {
        mustList.addMatch(key: '_lang', value: lang);
      }
    }

    mustList.addStatus(status);
  }

  void addSort({
    required String key,
    required dynamic value,
  }) {
    _sortList.add({key: value});
  }

  Future<List<Map<String, dynamic>>> search({
    int? offset,
    required int limit,
  }) async {
    final query = ElasticQuery.bool(
      must: mustList.actions,
      mustNot: mustNotList.actions.isNotEmpty ? mustNotList.actions : null,
    );

    final result = await ElasticClient.search(
      index: ElasticClient.indexName(
        uri,
        blog: isBlog,
      ),
      limit: limit,
      offset: offset ?? 0,
      sort: _sortList.isNotEmpty ? _sortList : null,
      query: query,
    );
    return result.docs;
  }
}

class ElasticActionList {
  final _list = <Map<String, dynamic>>[];

  List<Map<String, dynamic>> get actions => _list;

  void addStatus(String status) {
    _list.add(ElasticQuery.status(status: status));
  }

  void addMatch({
    required String key,
    required dynamic value,
  }) {
    _list.add(ElasticQuery.match(key: key, value: value));
  }

  void addFilter({
    required String keyFilter,
    required String key,
    required dynamic value,
  }) {
    _list
        .add(ElasticQuery.filter(keyFilter: keyFilter, key: key, value: value));
  }

  void addRange({
    required String key,
    num? gteValue,
    num? lteValue,
  }) {
    _list.add(
        ElasticQuery.range(key: key, gteValue: gteValue, lteValue: lteValue));
  }

  void addQuery({
    required String query,
    required ElasticQueryOperator queryOperator,
    required dynamic fields,
  }) {
    _list.add(ElasticQuery.queryString(
      query: query,
      queryOperator: queryOperator,
      fields: fields,
    ));
  }

  void addMultiMatch({
    required String query,
    required List<String> fields,
  }) {
    _list.add(ElasticQuery.multiMatch(query: query, fields: fields));
  }
}
