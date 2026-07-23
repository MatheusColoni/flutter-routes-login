# Routes — Calculadora de Rotas e Combustível

App em Flutter que calcula a distância entre dois endereços e estima quanto você vai gastar de combustível na viagem, com base no preço da gasolina e no consumo do carro.

## Funcionalidades

- **Autenticação com Firebase** — cadastro e login por email e senha, com sessão persistente (o app lembra que você está logado).
- **Cálculo de rota** — informa origem e destino e o app retorna a distância real de carro (não em linha reta) e o tempo estimado.
- **Estimativa de custo** — a partir do preço por litro e do consumo do veículo (km/L), calcula quantos litros serão gastos e o valor total em reais.
- **Preço salvo no aparelho** — o último preço de gasolina informado é lembrado entre as sessões.

## Tecnologias

| Pacote | Uso |
|---|---|
| `firebase_core` / `firebase_auth` | Autenticação por email e senha |
| `provider` | Gerenciamento de estado (`ChangeNotifier`) |
| `http` | Requisições à API de rotas |
| `shared_preferences` | Persistência local do preço da gasolina |
| [OpenRouteService](https://openrouteservice.org) | Geocoding (endereço → coordenadas) e cálculo de rota |

## Arquitetura

O projeto segue uma separação em camadas — a interface não conversa diretamente com o Firebase nem com a API de rotas:

```
view  →  controller  →  service  →  API externa
                ↓
              model
```

- **model** — classes de dados puras (`UsuarioModel`, `RotaModel`).
- **service** — comunicação com o mundo externo (Firebase Auth, OpenRouteService).
- **controller** — `ChangeNotifier` que guarda o estado (carregando, resultado, erro) e notifica a interface automaticamente.
- **view** — apenas telas e widgets; lê o estado via `context.watch` e dispara ações via `context.read`.

### Estrutura de pastas

```
lib/
├── controller/
│   ├── auth_controller.dart      # login, cadastro, logout, usuário atual
│   └── rota_controller.dart      # cálculo de distância e custo
├── model/
│   ├── usuario_model.dart
│   └── rota_model.dart
├── service/
│   ├── auth_service.dart         # Firebase Auth + tratamento de erros
│   └── rota_service.dart         # OpenRouteService (geocoding + rota)
├── view/
│   ├── auth_gate.dart            # decide entre login e home
│   ├── login_page.dart
│   ├── cadastro_page.dart
│   ├── home_page.dart
│   └── calculo_rota_page.dart
├── firebase_options.dart         # gerado pelo flutterfire configure
└── main.dart
```

### Navegação automática

O `AuthGate` escuta o stream `authStateChanges()` do Firebase e troca de tela sozinho: quem está logado vai para a `HomePage`, quem não está vai para a `LoginPage`. Não há `Navigator.push` manual depois do login nem depois do logout.

## Configuração

### Pré-requisitos

- Flutter SDK instalado
- Uma conta no [Firebase](https://console.firebase.google.com)
- Uma chave gratuita da [OpenRouteService](https://openrouteservice.org)
- Android: `minSdkVersion` **23** ou maior (exigido pelo `firebase_auth`)

### 1. Instalar as dependências

```bash
flutter pub get
```

### 2. Configurar o Firebase

Instale as ferramentas de linha de comando:

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
```

Conecte o projeto (gera o `lib/firebase_options.dart`):

```bash
flutterfire configure
```

No console do Firebase, ative o método de login: **Authentication → Sign-in method → Email/Password → Enable**. Sem isso o cadastro retorna o erro `operation-not-allowed`.

### 3. Configurar a chave da OpenRouteService

Crie uma conta gratuita, gere um token do plano *Standard* no dashboard e informe a chave em `lib/service/rota_service.dart`:

```dart
static const _apiKey = 'SUA_CHAVE_AQUI';
```

O plano gratuito cobre 2.000 requisições por dia.

### 4. Rodar

```bash
flutter run
```

## Atenção: chaves de API no repositório

A chave da OpenRouteService está hardcoded em `rota_service.dart`. **Antes de publicar este repositório**, mova a chave para fora do código — caso contrário ela fica visível para qualquer pessoa e pode ser usada até estourar sua cota.

Abordagem recomendada com [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv):

1. Crie um arquivo `.env` na raiz com `ORS_API_KEY=sua_chave`.
2. Adicione `.env` ao `.gitignore`.
3. Leia a chave com `dotenv.env['ORS_API_KEY']`.
4. Versione um `.env.example` sem o valor real, para quem clonar o projeto saber o que preencher.

O `firebase_options.dart` pode ser versionado normalmente — são identificadores públicos do app, protegidos pelas regras de segurança do próprio Firebase, e não credenciais secretas.

## Melhorias na interface

A tela de login foi retrabalhada a partir de uma versão inicial:

- Hierarquia de botões: "Entrar" preenchido (ação primária) e "Cadastrar" apenas com contorno (secundária).
- Campo de senha com `obscureText` e botão de mostrar/ocultar.
- Altura de toque confortável (52px) e largura total nos botões.
- Teclado correto por campo (`emailAddress`, `TextInputAction.next`) e fechamento ao tocar fora ou arrastar a tela.
- Layout centralizado de verdade e limitado a 400px de largura, para não esticar em tablet e web.
- Validação de formulário com `Form` + `validator` em todos os campos.


