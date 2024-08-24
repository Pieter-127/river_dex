import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:river_dex/data/provider/pokemon_list_provider.dart';
import 'package:river_dex/ui/list/components/search_widget.dart';

import 'components/list_error_widget.dart';
import 'components/list_loader_widget.dart';
import 'components/pokemon_list_widget.dart';

class PokemonListPageContent extends ConsumerStatefulWidget {
  const PokemonListPageContent({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      PokemonListPageContentState();
}

class PokemonListPageContentState
    extends ConsumerState<PokemonListPageContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pokemonListProvider.notifier).loadFirstGenPokemon();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(pokemonListProvider);
    final Widget body;
    switch (data.providerState) {
      case PokemonListProviderState.loading:
        body = const Center(child: ListLoaderWidget(width: 200, height: 200));
      case PokemonListProviderState.success:
        body = buildSuccessBody(data);
      case PokemonListProviderState.error:
        body = ListErrorWidget(callback: () {
          ref.read(pokemonListProvider.notifier).loadFirstGenPokemon();
        });
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("RiverDex"),
        ),
        body: body);
  }

  Widget buildSuccessBody(PokemonListState data) {
    final Widget content;

    if (data.response == null) {
      //this shouldn't be a possible state, would be an api issue
      content = const Center(child: Text("Response empty"));
    } else {
      if (data.filteredResponse == null || data.filteredResponse!.isEmpty) {
        content = const Center(
          child: Text("No matches found."),
        );
      } else {
        content =
            PokemonListWidget(entries: (data.filteredResponse ?? List.empty()));
      }
    }
    return SingleChildScrollView(
        child: Column(
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: SearchWidget(
              onTextChanged: (String value) {
                ref.read(pokemonListProvider.notifier).filterPokemon(value);
              },
            )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8), child: content)
      ],
    ));
  }
}
