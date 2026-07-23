import 'package:flutter/foundation.dart';
import '../model/rotas_model.dart';
import '../service/rota_service.dart';

class RotaController extends ChangeNotifier {
  final RotaService _service = RotaService();

  bool _carregando = false;
  bool get carregando => _carregando;

  RotaModel? _rota;
  RotaModel? get rota => _rota;

  String? _erro;
  String? get erro => _erro;

  Future<void> calcular({
    required String origem,
    required String destino,
    required double precoLitro,
    required double consumoKmL,
  }) async {
    _carregando = true;
    _erro = null;
    _rota = null;
    notifyListeners();

    try {
      final resultado = await _service.calcularRota(origem, destino);
      if (resultado == null) {
        _erro = 'Não encontrei essa rota. Confira os endereços.';
      } else {
        final litros = resultado.km / consumoKmL;
        _rota = RotaModel(
          distanciaKm: resultado.km,
          duracaoMin: resultado.minutos,
          litros: litros,
          custo: litros * precoLitro,
        );
      }
    } catch (_) {
      _erro = 'Erro ao calcular. Tente novamente.';
    }

    _carregando = false;
    notifyListeners();
  }
}