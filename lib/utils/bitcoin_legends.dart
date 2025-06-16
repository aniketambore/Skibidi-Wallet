import 'package:bitwit_shit/app_config.dart';

enum BitcoinLegendType {
  skibidiSatoshi,
  skibidiAdamBack,
  skibidiHalFinney,
  skibidiNickSzabo,
  skibidiPieterWuille,
  skibidiAndreasAntonopoulos,
  skibidiTadgeDryja,
  skibidiJosephPoon,
  skibidiSuperTestnet,
  skibidiUncleRockstarDev,
  skibidiJimmySong,
  skibidiLuke,
  skibidiJackDorsey,
  skibidiBob,
}

class BitcoinLegend {
  final String name;
  final String description;
  final String image;
  final String level;

  BitcoinLegend({
    required this.name,
    required this.description,
    required this.image,
    required this.level,
  });

  static BitcoinLegend fromType(BitcoinLegendType type) {
    final imageUrl = AppConfig.imageBaseUrl;

    switch (type) {
      /// Local Assets Based Legends
      case BitcoinLegendType.skibidiSatoshi:
        return BitcoinLegend(
          name: 'SKIBIDI SATOSHI',
          image: 'assets/legends/skibidi_satoshi.png',
          description:
              'The OG toilet flusher. Invented Bitcoin, then vanished. No cap.',
          level: "OG",
        );
      case BitcoinLegendType.skibidiBob:
        return BitcoinLegend(
          name: 'SKIBIDI BOB',
          image: 'assets/legends/skibidi_bob.png',
          description:
              'Fresh to the Bitcoin game. Still learning, still vibing. WAGMI, Bob!',
          level: "Newbie",
        );

      /// Remote Assets Based Legends
      case BitcoinLegendType.skibidiAdamBack:
        return BitcoinLegend(
          name: 'SKIBIDI ADAM BACK',
          image: '$imageUrl/v1749974325/skibidi_adam_back_nmgrhy.png',
          description:
              'Hashcash hacker. Helped power up Bitcoin from day one. Still stacking, still vibing.',
          level: "Cyberpunk",
        );
      case BitcoinLegendType.skibidiHalFinney:
        return BitcoinLegend(
          name: 'SKIBIDI HAL FINNEY',
          image: '$imageUrl/upload/v1749974325/skibidi_hal_p8p6x7.png',
          description:
              'Bitcoin pioneer and cryptographic legend. Early adopter and contributor. No cap.',
          level: "Legend",
        );
      case BitcoinLegendType.skibidiNickSzabo:
        return BitcoinLegend(
          name: 'SKIBIDI NICK SZABO',
          image: '$imageUrl/v1749974333/skibidi_nick_szabo_vgvk6z.png',
          description:
              'Bit gold brainiac. Cypherpunk vibes, always thinking ahead.',
          level: "Architect",
        );
      case BitcoinLegendType.skibidiPieterWuille:
        return BitcoinLegend(
          name: 'SKIBIDI PIETER WUILLE',
          image: '$imageUrl/v1749974327/skibidi_pieter_wuille_iyr4jb.png',
          description:
              'SegWit wizard & code ninja. Upgraded Bitcoin\'s brain - big brain moves only.',
          level: "Wizard",
        );
      case BitcoinLegendType.skibidiAndreasAntonopoulos:
        return BitcoinLegend(
          name: 'SKIBIDI ANDREAS',
          image: '$imageUrl/v1749974325/skibidi_andreas_uekop9.png',
          description:
              'Bitcoin’s hype master and educator. Dropping knowledge bombs and orange pills daily.',
          level: "Sensei",
        );
      case BitcoinLegendType.skibidiJosephPoon:
        return BitcoinLegend(
          name: 'SKIBIDI JOSEPH POON',
          image: '$imageUrl/v1749974326/skibidi_joseph_poon_hz0meq.png',
          description:
              'Lightning Network co-creator. Scaling Bitcoin with giga-brain moves and endless energy.',
          level: "Trailblazer",
        );
      case BitcoinLegendType.skibidiTadgeDryja:
        return BitcoinLegend(
          name: 'SKIBIDI TADGE DRYJA',
          image: '$imageUrl/v1749974334/skibidi_tadge_o9wpzk.png',
          description:
              'Lightning Network co-inventor. Scaling Bitcoin with big brain energy and fast moves.',
          level: "Lightning OG",
        );
      case BitcoinLegendType.skibidiSuperTestnet:
        return BitcoinLegend(
          name: 'SKIBIDI SUPER TESTNET',
          image: '$imageUrl/v1749974334/skibidi_supertestnet_hxfr7i.png',
          description:
              'Independent Freelance Bitcoin dev. Creator of great new Bitcoin & Lightning tools',
          level: "Hacker",
        );
      case BitcoinLegendType.skibidiUncleRockstarDev:
        return BitcoinLegend(
          name: 'SKIBIDI UNCLE ROCKSTAR DEV',
          image: '$imageUrl/v1749974333/skibidi_uncle_rockstar_dev_uvxcf4.png',
          description:
              'BTCPay Server legend. Code with vibes, memes with style. Uncle to all plebs.',
          level: "Rockstar",
        );
      case BitcoinLegendType.skibidiLuke:
        return BitcoinLegend(
          name: 'SKIBIDI LUKE DASHJR',
          image: '$imageUrl/v1749974334/skibidi_luke_wzusfl.png',
          description:
              'Core dev since forever. Keeps Bitcoin pure. Code monk, full node mode—no cap.',
          level: "Core OG",
        );
      case BitcoinLegendType.skibidiJimmySong:
        return BitcoinLegend(
          name: 'SKIBIDI JIMMY SONG',
          image: '$imageUrl/v1749974325/skibidi_jimmy_song_sebprk.png',
          description:
              'Code cowboy and Bitcoin educator. Rockin’ the hat, droppin’ knowledge, keeping it real.',
          level: "Cowboy",
        );
      case BitcoinLegendType.skibidiJackDorsey:
        return BitcoinLegend(
          name: 'SKIBIDI JACK DORSEY',
          image: '$imageUrl/v1749974325/skibidi_jack_dorsey_omayfy.png',
          description:
              'Bird boss turned Bitcoin maxi. Building blocks, dropping sats, and rocking the beard.',
          level: "Visionary",
        );
    }
  }
}
