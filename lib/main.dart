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
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // Lógica de favoritos
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void deleteFavorite(itemDel) {
    if (favorites.contains(itemDel)) {
      favorites.remove(itemDel);
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

    // Utilizando o LayoutBuilder, com o constraints, é possivel fazer a condição
    // do maxWidth na tela, se form maior ou igual a 600px ele abre o menu completo
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            // Add menu lateral
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
                    print('Selecionado: $value');
                    setState(() {
                      // Mudando de página
                      selectedIndex = value;
                    });
                  }),
            ),
            // Chama a pagina
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                // child: GeneratorPage(),
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// Pagina Início
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

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
          // Text('Uma ideia de nome:'),
          BigCard(pair: pair),

          SizedBox(
            height: 15,
          ),
          // Criar um Botão
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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

            ElevatedButton(
              onPressed: () {
                print('Botão Maldito!');
                appState.getNext();
              },
              child: Text('Próximo'),
            ),
          ]),
        ],
      ),
    );
  }
}

// Pagina Favoritos
class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('Você ainda não possui favoritos!'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Meus Favoritos ( Total: ${appState.favorites.length} )'),
        ),
        Expanded(
          // GridView fica com uma responsabilidade melhor, lado a lado
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (WordPair favorite in appState.favorites)
                ListTile(
                  leading: IconButton(
                    onPressed: () {
                      appState.deleteFavorite(favorite);
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: const Color.fromARGB(255, 136, 25, 25),
                    ),
                  ),
                  title: Text(favorite.asCamelCase),
                ),
            ],
          ),
        )
      ],
    );
  }
}

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
        child: Text(
            // "${pair.first} ${pair.second}",
            pair.asCamelCase,
            style: meuEstilo,
            semanticsLabel: "${pair.first} ${pair.second}"),
      ),
    );
  }
}
