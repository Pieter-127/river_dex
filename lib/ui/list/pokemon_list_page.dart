import 'package:flutter/cupertino.dart';
import 'package:river_dex/ui/list/pokemon_list_page_content.dart';

class PokemonListPage extends StatelessWidget {
  static const String routeName = '/';

  const PokemonListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
        child: PokemonListPageContent()
    );
  }
}
