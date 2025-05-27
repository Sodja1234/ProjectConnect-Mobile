import 'dart:convert';

import 'package:odc_mobile_template/business/models/domain/domain.dart';
import 'package:odc_mobile_template/business/services/domain/domainNetworkService.dart';

import '../../utils/http/HttpUtils.dart';
import '../utils/http/localHttpUtils.dart';

class DomainNetworkServiceImpl implements DomainNetworkService{
  String? baseUrl;
  HttpUtils? httpUtils;

  DomainNetworkServiceImpl({required this.baseUrl, required this.httpUtils});
  @override
  Future<List<Domain>> getDomains() async{
    var url = '$baseUrl/domains';
    var response = await httpUtils!.getData(url);
    var listData = jsonDecode(response);
    var listDomains = listData['data'];
    listDomains =listDomains.map<Domain>((e)=>Domain.fromJson(e)).toList();
    return listDomains;


  }


}

void main()async{
  var service = DomainNetworkServiceImpl(baseUrl: 'http://192.168.43.30:8000/api', httpUtils: LocalHttpUtils());
  var domains = await service.getDomains();
  domains.forEach((element) {
    print(element.toJson());
  });
}