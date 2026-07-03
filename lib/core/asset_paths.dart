import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/organism.dart';

class OrganismAssetPath {
  static const _biomeMap = {
    1: 'campo',
    2: 'floresta',
    3: 'oceano',
    4: 'pantanal',
  };

  static const _fileMap = {
    1: 'Capim.png',
    2: 'Gafanhoto.png',
    3: 'Coelho.png',
    4: 'Sapo.png',
    5: 'Cobra.png',
    6: 'Raposa.png',
    7: 'Aguia.png',
    8: 'Arbusto.png',
    9: 'Lagarta.png',
    10: 'Aranha.png',
    11: 'Sapo.png',
    12: 'Cobra.png',
    13: 'Gaviao.png',
    14: 'Veado.png',
    15: 'Onça-pintada.png',
    16: 'Fitoplâncton.png',
    17: 'Alga.png',
    18: 'Camarao.png',
    19: 'Sardinha.png',
    20: 'Polvo.png',
    21: 'Atum.png',
    22: 'Tubarao.png',
    23: 'PlantaAquatica.png',
    24: 'Caramujo.png',
    25: 'Peixe.png',
    26: 'Garca.png',
    27: 'Jacare.png',
    28: 'CobraSucuri.png',
    29: 'OncaPintadaGalho.png',
  };

  static String getPath(Organism organism) {
    final biome = _biomeMap[organism.phaseId] ?? 'campo';
    final file = _fileMap[organism.id] ?? 'Capim.png';
    return 'animais/$biome/$file';
  }

  static String getBackgroundPath(int phaseId) {
    final biome = _biomeMap[phaseId] ?? 'campo';
    final suffix = kIsWeb ? 'Svelt' : '';
    return 'cenarios/$biome$suffix.png';
  }
}
