import 'package:odc_mobile_template/business/models/domain/domain.dart';

abstract class DomainNetworkService{
  Future<List<Domain>> getDomains();
}