import 'package:get_it/get_it.dart';
import 'package:river_dex/data/api_service.dart';
import 'package:river_dex/data/dto/pokemon_list_dto.dart';
import 'package:river_dex/data/provider/pokemon_list_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'util/mocks.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late PokemonListNotifier systemUnderTest;
  late GetIt getIt;

  mockApiService = MockApiService();
  getIt = GetIt.instance;
  getIt.registerSingleton<ApiService>(mockApiService);

  setUp(() {
    systemUnderTest = PokemonListNotifier();
  });

  test('Initial state is loading', () {
    expect(systemUnderTest.state.providerState,
        PokemonListProviderState.loading);
  });

  test('Successfully loads and filters Pokémon list', () async {
    final mockResponse = PokemonListDto(
      count: 2,
      next: "",
      previous: "",
      results: [
        Result(name: "Bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
        Result(name: "Ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/")
      ],
    );

    when(mockApiService.getPokemonList(151))
        .thenAnswer((_) async => mockResponse);

    await systemUnderTest.loadFirstGenPokemon();

    expect(systemUnderTest.state.providerState, PokemonListProviderState.success);

    systemUnderTest.filterPokemon("Bulba");
    expect(systemUnderTest.state.filteredResponse!.length, 1);
    expect(systemUnderTest.state.filteredResponse![0].pokemonName,
        "Bulbasaur");

    systemUnderTest.filterPokemon("002");
    expect(systemUnderTest.state.filteredResponse!.length, 1);
    expect(
        systemUnderTest.state.filteredResponse![0].pokemonName, "Ivysaur");
  });

  test('Handles error state correctly', () async {
    when(mockApiService.getPokemonList(151))
        .thenThrow(Exception("Failed to load data"));

    await systemUnderTest.loadFirstGenPokemon();

    expect(systemUnderTest.state.providerState,
        PokemonListProviderState.error);
    expect(systemUnderTest.state.response, isNull);
    expect(systemUnderTest.state.filteredResponse, isNull);
  });
}
