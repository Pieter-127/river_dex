import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:river_dex/data/mapper/pokemon_list_mapper.dart';

import '../../injectable.dart';
import '../../ui/model/pokedex_entry_model.dart';
import '../api_service.dart';

enum PokemonListProviderState { loading, success, error }

class PokemonListState {
  final PokemonListProviderState providerState;
  final List<PokedexEntryModel>? response;
  final List<PokedexEntryModel>? filteredResponse;

  PokemonListState(
      {required this.providerState, this.response, this.filteredResponse});

  PokemonListState copyWith(
      {PokemonListProviderState? providerState,
      List<PokedexEntryModel>? response,
      List<PokedexEntryModel>? filteredResponse,
      String? filterText}) {
    return PokemonListState(
      providerState: providerState ?? this.providerState,
      response: response ?? this.response,
      filteredResponse: filteredResponse ?? this.filteredResponse,
    );
  }
}

class PokemonListNotifier extends StateNotifier<PokemonListState> {
  PokemonListNotifier()
      : super(
            PokemonListState(providerState: PokemonListProviderState.loading));

  Future<void> loadFirstGenPokemon() async {
    _setLoading();
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.getPokemonList(151);
      _setSuccess(response.toPokedexEntry());
    } catch (e) {
      _setError();
    }
  }

  void filterPokemon(String text) {
    if (state.response == null) return;

    final filteredList = state.response!.where((pokemon) {
      final name = pokemon.pokemonName.toLowerCase();
      final number = pokemon.number;
      final query = text.toLowerCase();
      return name.contains(query) || number.contains(query);
    }).toList();

    state = state.copyWith(filterText: text, filteredResponse: filteredList);
  }

  void _setLoading() {
    state = state.copyWith(providerState: PokemonListProviderState.loading);
  }

  void _setSuccess(List<PokedexEntryModel> response) {
    state = state.copyWith(
      providerState: PokemonListProviderState.success,
      response: response,
      filteredResponse: response,
    );
  }

  void _setError() {
    state = state.copyWith(providerState: PokemonListProviderState.error);
  }
}

final pokemonListProvider =
    StateNotifierProvider<PokemonListNotifier, PokemonListState>((ref) {
  return PokemonListNotifier();
});
