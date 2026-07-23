import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/rota_controller.dart';

class CalculoRotaPage extends StatefulWidget {
  const CalculoRotaPage({super.key});

  @override
  State<CalculoRotaPage> createState() => _CalculoRotaPageState();
}

class _CalculoRotaPageState extends State<CalculoRotaPage> {
  final _formKey = GlobalKey<FormState>();
  final _origemController = TextEditingController();
  final _destinoController = TextEditingController();
  final _precoController = TextEditingController();
  final _consumoController = TextEditingController();

  @override
  void dispose() {
    _origemController.dispose();
    _destinoController.dispose();
    _precoController.dispose();
    _consumoController.dispose();
    super.dispose();
  }

  double _paraDouble(String v) =>
      double.tryParse(v.trim().replaceAll(',', '.')) ?? 0;

  Future<void> _calcular() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    await context.read<RotaController>().calcular(
          origem: _origemController.text,
          destino: _destinoController.text,
          precoLitro: _paraDouble(_precoController.text),
          consumoKmL: _paraDouble(_consumoController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final borda = OutlineInputBorder(borderRadius: BorderRadius.circular(12));
    final controller = context.watch<RotaController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Calcular rota')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _origemController,
                  decoration: InputDecoration(
                    labelText: 'Origem',
                    prefixIcon: const Icon(Icons.my_location),
                    border: borda,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe a origem' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _destinoController,
                  decoration: InputDecoration(
                    labelText: 'Destino',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: borda,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe o destino'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _precoController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Preço da gasolina (R\$/litro)',
                    prefixIcon: const Icon(Icons.local_gas_station_outlined),
                    border: borda,
                  ),
                  validator: (v) => _paraDouble(v ?? '') <= 0
                      ? 'Informe um preço válido'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _consumoController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Consumo do carro (km/litro)',
                    prefixIcon: const Icon(Icons.speed),
                    border: borda,
                  ),
                  validator: (v) => _paraDouble(v ?? '') <= 0
                      ? 'Informe o consumo'
                      : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: controller.carregando ? null : _calcular,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.carregando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Calcular'),
                ),
                const SizedBox(height: 24),
                if (controller.erro != null)
                  Text(
                    controller.erro!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                if (controller.rota != null) _resultado(controller.rota!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultado(rota) {
    String reais(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';
    String tempo(double min) {
      final h = min ~/ 60;
      final m = (min % 60).round();
      return h > 0 ? '${h}h ${m}min' : '${m}min';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _linha(Icons.route, 'Distância',
              '${rota.distanciaKm.toStringAsFixed(1)} km'),
          const Divider(),
          _linha(Icons.schedule, 'Tempo estimado', tempo(rota.duracaoMin)),
          const Divider(),
          _linha(Icons.local_gas_station, 'Combustível',
              '${rota.litros.toStringAsFixed(1)} litros'),
          const Divider(),
          _linha(Icons.attach_money, 'Custo total', reais(rota.custo),
              destaque: true),
        ],
      ),
    );
  }

  Widget _linha(IconData icone, String titulo, String valor,
      {bool destaque = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icone, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Text(titulo, style: TextStyle(color: Colors.grey.shade700)),
          const Spacer(),
          Text(
            valor,
            style: TextStyle(
              fontSize: destaque ? 20 : 16,
              fontWeight: destaque ? FontWeight.bold : FontWeight.w500,
              color: destaque ? Colors.green.shade700 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}