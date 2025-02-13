import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Gerador de Nomes',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// Aqui pe onde fica a lógica (regra de negócio)
class MyAppState extends ChangeNotifier {
  WordPair current = WordPair.random();
  List<WordPair> history = <WordPair>[];

  GlobalKey? historyListKey;

  void getNext() {
    // Insere corretamente no histórico permanecendo a escolha do favorito
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  // Lógica de favoritos
  List<WordPair> favorites = <WordPair>[];

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;

    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  void deleteFavorite(WordPair itemDel) {
    if (favorites.contains(itemDel)) {
      favorites.remove(itemDel);
    }
    notifyListeners();
  }

  void cleaningHistory() {
    if (history.isNotEmpty) {
      history = <WordPair>[];
    }
    notifyListeners();
  }
}

// Aqui cria um controlador para a primeira página
// Isso inclui menus e paginas que vão ser puxadas
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0; // Padrão home page

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    // Funcionalidade do menu
    Widget page;
    if (selectedIndex == 0) {
      page = GeneratorPage();
    } else if (selectedIndex == 1) {
      page = FavoritePage();
      // // Cria um conteudo teste fictício (retangulo com x no meio)
      // page = Placeholder();
    } else {
      throw UnimplementedError(' Nenhuma tela para o menu $selectedIndex');
    }

    // Faz uma animação de cor
    var mainArea = ColoredBox(
      color: colorScheme
          .primaryContainer, // Altere para surface ou outra cor desejada
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    // Utilizando o LayoutBuilder, com o constraints, é possivel fazer a condição
    // do maxWidth na tela, se form maior ou igual a 600px ele abre o menu completo
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            // Usando padrão de menu mobile para telas pequenas
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Início',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Favoritos',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Início'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favoritos'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

// Pagina Início
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    WordPair pair = appState.current;
    final theme = Theme.of(context);

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          SizedBox(height: 10),
          // Text('Uma ideia de nome:'),
          BigCard(pair: pair),

          SizedBox(
            height: 15,
          ),
          // Criar um Botão
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Primeiro teste
              // ElevatedButton(
              //   onPressed: () {
              //     appState.toggleFavorite();
              //   },
              //   child: Row(
              //     children: [
              //       Icon(
              //         // Icons.favorite_border_outlined,
              //         icon,
              //         color: Colors.red,
              //         size: 24.4,
              //         semanticLabel: 'Favoritar',
              //       ),
              //       SizedBox(width: 5),
              //       Text('Favoritar')
              //     ],
              //   ),
              // ),

              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                label: Text('Favoritar'),
                icon: Icon(
                  icon,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),

              ElevatedButton.icon(
                onPressed: () {
                  print('Botão Maldito!');
                  appState.getNext();
                },
                label: Text('Próximo'),
                icon: Icon(
                  Icons.skip_next,
                  color: theme.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),

              ElevatedButton.icon(
                onPressed: () {
                  appState.cleaningHistory();
                },
                label: Text('Limpar'),
                icon: Icon(
                  Icons.cleaning_services,
                  color: const Color.fromARGB(255, 181, 182, 101),
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
          // Coloca um espaço abaixo para conteúdo não ir para o rodapé
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

// Monta o card principal com o NOME
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meuEstilo = theme.textTheme.displayMedium!.copyWith(
        // decoration: TextDecoration.underline,
        // decorationStyle: TextDecorationStyle.wavy,
        color: theme.colorScheme.onPrimary,
        height: 2);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        // child: Text(
        //     // "${pair.first} ${pair.second}",
        //     pair.asCamelCase,
        //     style: meuEstilo,
        //     semanticsLabel: "${pair.first} ${pair.second}"),

        child: MergeSemantics(
            child: Wrap(
          children: [
            Text(
              pair.first,
              style: meuEstilo.copyWith(fontWeight: FontWeight.w100),
            ),
            Text(
              pair.second,
              style: meuEstilo.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        )),
      ),
    );
  }
}

// Pagina Favoritos
class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('Meus Favoritos ( Total: ${appState.favorites.length} )'),
        ),
        Expanded(
          // Make better use of wide windows with a grid.
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (var pair in appState.favorites)
                ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      appState.deleteFavorite(pair);
                    },
                  ),
                  title: Text(
                    pair.asLowerCase,
                    semanticsLabel: pair.asPascalCase,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey();

  /// Monta o gradient no topo da lista de histórico
  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    if (appState.history.isEmpty) {
      return SizedBox(); // Retorna vazio caso a lista esteja vazia
    }

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      // blendMode mescla o shader com o gradiente criado
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 50),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
