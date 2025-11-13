import '../models/simulation.dart';

/// Service to manage PhET and other interactive simulations
class SimulationService {
  static final SimulationService _instance = SimulationService._internal();
  factory SimulationService() => _instance;
  SimulationService._internal();

  /// Get all available simulations for a specific age group
  Future<List<Simulation>> getSimulations({String ageGroup = 'bright'}) async {
    // Return simulations based on age group
    if (ageGroup == 'bright') {
      return _getBrightSimulations();
    } else {
      return _getJuniorSimulations();
    }
  }

  /// Get simulations specifically for Bright children (9-12)
  Future<List<Simulation>> _getBrightSimulations() async {
    return [
      const Simulation(
        id: 'states-of-matter',
        title: 'States of Matter Simulation',
        description:
            'Explore how atoms and molecules behave in different states of matter',
        iframeUrl:
            'https://phet.colorado.edu/sims/html/states-of-matter-basics/latest/states-of-matter-basics_en.html',
        topics: [
          'Atoms',
          'Molecules',
          'States of Matter',
          'Solids',
          'Liquids',
          'Gases',
        ],
        learningGoals: [
          'Describe characteristics of solids, liquids, and gases.',
          'Predict how changing temperature affects particle behavior.',
          'Compare how particles behave in different phases.',
          'Explain melting and freezing using molecular-level reasoning.',
          'Recognize that substances have unique melting, freezing, and boiling points.',
        ],
        scientificExplanation:
            'In this simulation, you will explore how atoms and molecules behave in different states of matter. '
            'Heating and cooling change how particles move, spread, and interact. '
            'You will see how solids keep their shape, liquids flow, and gases spread out to fill space.',
        warning:
            'Adult supervision is recommended. Some concepts may require explanation or guidance for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy Peasy',
        ageGroup: 'bright',
      ),
      const Simulation(
        id: 'balloons-static-electricity',
        title: 'Balloons & Static Electricity',
        description:
            'Explore how rubbing a balloon can make invisible electric charges appear. '
            'Watch how charges move, cling, push, and pull—then predict what happens next.',
        iframeUrl:
            'https://phet.colorado.edu/sims/html/balloons-and-static-electricity/latest/balloons-and-static-electricity_en.html',
        topics: [
          'Static Electricity',
          'Electric Charges',
          'Electric Force',
        ],
        learningGoals: [
          'Describe what happens when objects gain or lose charges through contact or rubbing.',
          'Show and explain how charge can move without touching (induction).',
          'Predict when objects will attract or repel each other depending on their charges.',
          'Explain why "grounding" removes excess charge and stops attraction or repulsion.',
          'Use simple models to show how charged and uncharged objects behave at a distance.',
        ],
        scientificExplanation:
            'When you rub a balloon on your hair or sweater, electrons (tiny negative charges) move from one object to the other. '
            'This creates static electricity—an imbalance of electric charges. Objects with opposite charges attract each other, '
            'while objects with the same charge push away. You can even move charges without touching through a process called induction!',
        warning:
            'Adult supervision is recommended. Some concepts may require explanation or guidance for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy Peasy',
        ageGroup: 'bright',
      ),
      const Simulation(
        id: 'density',
        title: 'Exploring Density',
        description:
            'Discover why some objects float, others sink, and how mass and volume work together to create density. '
            'Experiment by changing shapes, sizes, and materials to uncover hidden patterns.',
        iframeUrl:
            'https://phet.colorado.edu/sims/html/density/latest/density_en.html',
        topics: [
          'Density',
          'Mass',
          'Volume',
          'Archimedes\' Principle',
        ],
        learningGoals: [
          'Explain how an object\'s density depends on its mass and volume.',
          'Understand why two objects with the same mass can take up different amounts of space—and why two objects with the same volume can weigh differently.',
          'Recognize that density is an intensive property, meaning it doesn\'t change if you cut an object in half or reshape it.',
          'Measure an object\'s volume by observing how much water it displaces.',
          'Identify unknown materials by calculating their density and comparing your values to known reference materials.',
        ],
        scientificExplanation:
            'Density is a measure of how much "stuff" (mass) is packed into a certain amount of space (volume). '
            'The formula is: Density = Mass ÷ Volume. Objects with higher density sink in water, while objects with lower density float. '
            'This is why a big piece of wood can float while a small metal coin sinks—metal is much denser than wood!',
        warning:
            'Adult supervision is recommended. Some concepts may require explanation or guidance for younger learners.',
        estimatedMinutes: 20,
        difficulty: 'Easy Peasy',
        ageGroup: 'bright',
      ),
    ];
  }

  /// Get simulations for Junior children (6-8)
  Future<List<Simulation>> _getJuniorSimulations() async {
    return [
      // Junior simulations would go here with simpler content
      // For now, returning empty list as focus is on Bright
    ];
  }

  /// Get a single simulation by ID
  Future<Simulation?> getSimulationById(String id) async {
    final allSimulations = await getSimulations(ageGroup: 'bright');
    try {
      return allSimulations.firstWhere((sim) => sim.id == id);
    } catch (e) {
      return null;
    }
  }
}
