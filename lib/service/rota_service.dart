import 'dart:convert';
import 'package:http/http.dart' as http;

class RotaService {
  static const _apiKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjM2N2Q4NGVlZDg1ZjQzMTBhYjMxNzY4OGExNTAwYmYwIiwiaCI6Im11cm11cjY0In0=';
  static const _base = 'https://api.openrouteservice.org';

  Future<List<double>?> _geocodificar(String endereco) async {
  final url = Uri.parse(
    '$_base/geocode/search'
    '?api_key=$_apiKey'
    '&text=${Uri.encodeComponent(endereco)}'
    '&boundary.country=BR'
    '&size=1',
  );
  final resp = await http.get(url);
  print('>>> GEOCODE "$endereco" status=${resp.statusCode}');
  print('>>> GEOCODE body=${resp.body}');
  if (resp.statusCode != 200) return null;

  final dados = jsonDecode(resp.body);
  final features = dados['features'] as List;
  if (features.isEmpty) return null;

  final coords = features[0]['geometry']['coordinates'] as List;
  return [(coords[0] as num).toDouble(), (coords[1] as num).toDouble()];
}

Future<({double km, double minutos})?> calcularRota(
  String origem,
  String destino,
) async {
  final o = await _geocodificar(origem);
  final d = await _geocodificar(destino);
  if (o == null || d == null) return null;

  final url = Uri.parse(
    '$_base/v2/directions/driving-car'
    '?api_key=$_apiKey'
    '&start=${o[0]},${o[1]}'
    '&end=${d[0]},${d[1]}',
  );
  final resp = await http.get(url);
  print('>>> ROTA status=${resp.statusCode}');
  print('>>> ROTA body=${resp.body}');
  if (resp.statusCode != 200) return null;

  final dados = jsonDecode(resp.body);
  final resumo = dados['features'][0]['properties']['summary'];
  final metros = (resumo['distance'] as num).toDouble();
  final segundos = (resumo['duration'] as num).toDouble();

  return (km: metros / 1000, minutos: segundos / 60);
}
 }