import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:river_dex/ui/model/pokedex_entry_model.dart';

class PokemonListWidget extends StatelessWidget {
  final List<PokedexEntryModel> entries;

  const PokemonListWidget({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: entries[index].imageUrl,
                placeholder: (context, url) => SizedBox(
                  width: 100,
                  height: 100,
                  child:
                      Lottie.asset('assets/animations/loading_animation.json'),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 8),
              Text(
                "${entries[index].pokemonName}\n${entries[index].number}",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              )
            ],
          ),
        );
      },
    );
  }
}
