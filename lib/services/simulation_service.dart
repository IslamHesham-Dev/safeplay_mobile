import '../models/simulation.dart';

/// Service to manage PhET and other interactive simulations
class SimulationService {
  static final SimulationService _instance = SimulationService._internal();
  factory SimulationService() => _instance;
  SimulationService._internal();

  /// Get all available simulations for a specific age group
  Future<List<Simulation>> getSimulations(
      {String ageGroup = 'bright', String? subject}) async {
    // Return simulations based on age group and optional subject
    if (ageGroup == 'bright') {
      if (subject == 'science') {
        return await _getBrightScienceSimulations();
      } else if (subject == 'math') {
        return await _getBrightMathSimulations();
      }
      // Return all simulations if no subject specified
      final science = await _getBrightScienceSimulations();
      final math = await _getBrightMathSimulations();
      return [...science, ...math];
    } else {
      return _getJuniorSimulations();
    }
  }

  /// Get science simulations for Bright children (9-12)
  Future<List<Simulation>> _getBrightScienceSimulations() async {
    return _getBrightSimulations();
  }

  /// Get math simulations for Bright children (9-12)
  Future<List<Simulation>> _getBrightMathSimulations() async {
    return [
      const Simulation(
        id: 'equality-explorer-basics',
        title: 'Equality Explorer: Basics',
        description:
            'Learn how to make both sides of an equation equal using a balance scale. '
            'Experiment with weights, shapes, and numbers to discover how equations work, how inequalities behave, and how proportional reasoning helps you solve for the unknown.',
        iframeUrl:
            'https://phet.colorado.edu/sims/html/equality-explorer-basics/latest/equality-explorer-basics_en.html',
        topics: [
          'Equations',
          'Inequalities',
          'Proportional Reasoning',
        ],
        learningGoals: [
          'Solve equations using a balance model, exploring how adding or removing the same amount from each side keeps things equal.',
          'Explain your solving strategies, showing why your steps are correct and how they maintain equality.',
          'Understand inequalities, seeing what happens when one side is heavier or lighter.',
          'Use proportional reasoning to figure out the value of a single object using groups, multiples, and simple comparisons.',
        ],
        scientificExplanation:
            'Equations are like a balance scale—both sides must weigh the same to stay level. '
            'When you add or remove the same amount from each side, the scale stays balanced. '
            'This simulation helps you visualize how equations work, making abstract math concepts concrete and easier to understand.',
        warning:
            'Adult supervision is recommended. Some concepts may require explanation or guidance for younger learners.',
        estimatedMinutes: 20,
        difficulty: 'Easy Peasy',
        ageGroup: 'bright',
      ),
      const Simulation(
        id: 'area-model-introduction',
        title: 'Area Model Introduction',
        description:
            'Discover how multiplication comes to life using rectangles. '
            'Break numbers into parts, explore factors and products, and use the area model to understand why multiplication works—not just how.',
        iframeUrl:
            'https://phet.colorado.edu/sims/html/area-model-introduction/latest/area-model-introduction_en.html',
        topics: [
          'Factors',
          'Products',
          'Area Model',
          'Multiplication',
          'Partial Products',
        ],
        learningGoals: [
          'Understand area as multiplication, recognizing that the space inside a rectangle represents the product of its side lengths.',
          'Use the area model to simplify multiplication, breaking numbers into friendlier parts to solve problems step by step.',
          'Represent multiplication visually, showing a multiplication problem as the proportional area of a rectangle.',
          'Spot meaningful patterns, noticing how partial products combine to form the total area (and total answer).',
        ],
        scientificExplanation:
            'The area model shows multiplication as the space inside a rectangle. '
            'If a rectangle is 4 units wide and 3 units tall, its area is 4 × 3 = 12 square units. '
            'By breaking numbers into smaller parts, you can solve complex multiplication problems more easily—this is how mathematicians think!',
        warning:
            'Adult supervision is recommended. Some concepts may require explanation or guidance for younger learners.',
        estimatedMinutes: 20,
        difficulty: 'Easy Peasy',
        ageGroup: 'bright',
      ),
      const Simulation(
        id: 'mean-share-and-balance',
        title: 'Mean: Share and Balance',
        description: 'Explore how numbers can be shared fairly across a group. '
            'Use the idea of "leveling out" data to understand what the mean (average) really means, how it\'s calculated, and how unusual values can tip the balance.',
        iframeUrl:
            'https://phet.colorado.edu/sims/html/mean-share-and-balance/latest/mean-share-and-balance_en.html',
        topics: [
          'Central Tendency',
          'Mean',
        ],
        learningGoals: [
          'Explain how the mean is calculated, showing each step and why the method produces a fair overall value.',
          'Understand the mean as a balancing point, using ideas like fair share, leveling, and equal distribution.',
          'Predict what happens when outliers appear, and describe how extremely large or small values affect the mean.',
          'Compare data sets, exploring how changes to individual values shift the balanced or leveled outcome.',
          'Estimate the mean for both continuous (smooth) data and discrete (countable) data sets using intuitive reasoning.',
        ],
        scientificExplanation:
            'The mean (or average) is a way to find the "middle" of a group of numbers. '
            'Imagine leveling a pile of blocks so every stack is the same height—that\'s the mean! '
            'Add all the numbers together, then divide by how many numbers you have. The mean helps us understand data at a glance.',
        warning:
            'Adult supervision is recommended. Some concepts may require explanation or guidance for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy Peasy',
        ageGroup: 'bright',
      ),
      const Simulation(
        id: 'balancing-act',
        title: 'Balancing Act',
        description:
            'Experiment with weights, distances, and balance as you learn how a plank tilts or stays level. '
            'Use levers, torque, and proportional reasoning to predict what will happen—and solve fun balance puzzles along the way.',
        iframeUrl:
            'https://phet.colorado.edu/sims/html/balancing-act/latest/balancing-act_en.html',
        topics: [
          'Balance',
          'Proportional Reasoning',
          'Torque',
          'Lever Arm',
          'Rotational Equilibrium',
        ],
        learningGoals: [
          'Predict how different masses affect balance, learning how heavier or lighter objects influence a plank.',
          'Explore how position matters, observing how moving a mass closer or farther changes the motion of the plank.',
          'Create simple balance rules, describing when and why a plank will tilt to one side or stay level.',
          'Apply your rules to solve challenges, using torque and lever arm concepts to figure out real balancing puzzles.',
        ],
        scientificExplanation:
            'Balance is all about torque—the turning force that makes things rotate. '
            'A heavy weight far from the center creates more torque than a light weight close to the center. '
            'To balance a plank, both sides must have equal torque. This is why a small child far from the center can balance a heavy adult close to the center on a seesaw!',
        warning:
            'Adult supervision is recommended. Some concepts may require explanation or guidance for younger learners.',
        estimatedMinutes: 20,
        difficulty: 'Medium',
        ageGroup: 'bright',
      ),
    ];
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
            'https://safeplay-portal.web.app/phet/states-of-matter-basics_en.html',
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
