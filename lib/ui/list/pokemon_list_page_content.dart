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
        break;
      case PokemonListProviderState.success:
        body = buildSuccessBody(data);
        break;
      case PokemonListProviderState.error:
        body = ListErrorWidget(callback: () {
          ref.read(pokemonListProvider.notifier).loadFirstGenPokemon();
        });
        break;
      default:
        body = const Center(child: Text('Unexpected state'));
        break;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("RiverDex"),
      ),
      body: Column(
        // Ensure that Expanded is inside a Column here
        children: [
          Expanded(
            child: body,
          ),
        ],
      ),
    );
  }

  Widget buildSuccessBody(PokemonListState data) {
    final Widget content;

    if (data.response == null) {
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: SearchWidget(
            onTextChanged: (String value) {
              ref.read(pokemonListProvider.notifier).filterPokemon(value);
            },
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: content,
          ),
        ),
      ],
    );
  }
}
