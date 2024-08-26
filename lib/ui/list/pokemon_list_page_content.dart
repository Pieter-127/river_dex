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
      body: body,
    );
  }

  Widget buildSuccessBody(PokemonListState data) {
    final List<Widget> slivers = [];

    slivers.add(
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: SearchWidget(
            onTextChanged: (String value) {
              ref.read(pokemonListProvider.notifier).filterPokemon(value);
            },
          ),
        ),
      ),
    );

    // Content handling
    if (data.response == null) {
      slivers.add(
        const SliverFillRemaining(
          child: Center(child: Text("Response empty")),
        ),
      );
    } else if (data.filteredResponse == null ||
        data.filteredResponse!.isEmpty) {
      slivers.add(
        const SliverFillRemaining(
          child: Center(
            child: Text("No matches found."),
          ),
        ),
      );
    } else {
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: PokemonListWidget(entries: data.filteredResponse ?? []),
        ),
      );
    }

    return CustomScrollView(
      slivers: slivers,
    );
  }
}
