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
}

class MyHomePage extends StatelessWidget {
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

    return Scaffold(
      body: Center(
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
            ])
          ],
        ),
      ),
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
