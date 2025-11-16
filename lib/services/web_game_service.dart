import '../models/web_game.dart';

/// Service for managing web-based educational games
class WebGameService {
  static final WebGameService _instance = WebGameService._internal();
  factory WebGameService() => _instance;
  WebGameService._internal();

  /// Get all web games for a specific age group
  Future<List<WebGame>> getWebGames(
      {String ageGroup = 'junior', String? subject}) async {
    if (ageGroup == 'junior') {
      return _getJuniorWebGames(subject: subject);
    } else if (ageGroup == 'bright') {
      return _getBrightWebGames(subject: subject);
    }
    return [];
  }

  /// Get web games for Junior children (6-8)
  Future<List<WebGame>> _getJuniorWebGames({String? subject}) async {
    final allGames = [
      const WebGame(
        id: 'food-chains',
        title: 'Food Chains',
        description:
            'Learn about various living things such as animals and plants, sort them into different categories and discover where they fit into the food chain.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/foodchains.html',
        canvasSelector: null,
        topics: [
          'Animals',
          'Plants',
          'Food Chains',
          'Habitats',
          'Ecosystems',
        ],
        learningGoals: [
          'Identify different animals and plants in a woodland habitat.',
          'Understand what a food chain is and how living things depend on each other.',
          'Sort animals by characteristics (fly, have legs, have shells).',
          'Explore how different habitats (ocean, forest, desert) have different food chains.',
          'Learn about producers, consumers, and decomposers in nature.',
        ],
        explanation:
            'A food chain shows how energy moves from one living thing to another. '
            'Plants make their own food using sunlight (producers). Animals that eat plants are called herbivores. '
            'Animals that eat other animals are called carnivores. In this game, you\'ll explore the woodland habitat '
            'and discover how animals like the fox, owl, squirrel, snail, bird, and caterpillar fit into the food chain!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🌳',
        color: '4CAF50', // Green
      ),
      const WebGame(
        id: 'microorganisms',
        title: 'Microorganisms',
        description:
            'Learn about microorganisms such as bacteria, fungi, and algae, discover where they live and understand their important role in ecosystems.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/microorganisms.html',
        canvasSelector: null,
        topics: [
          'Microbiology',
          'Bacteria',
          'Fungi',
          'Algae',
          'Plankton',
          'Decomposers',
          'Nitrogen Cycle',
          'Ecosystems',
        ],
        learningGoals: [
          'Identify different types of microorganisms (bacteria, fungi, algae, plankton).',
          'Understand the important role microorganisms play as decomposers in ecosystems.',
          'Discover where microorganisms live (food, plants, humans, and other living things).',
          'Learn about bacteria in decaying leaves, diseases, moldy fruit, yeast in breads, and yoghurt.',
          'Explore how microorganisms contribute to the nitrogen cycle and life on Earth.',
        ],
        explanation:
            'Microorganisms are tiny living things that are too small to see without a microscope! '
            'They include bacteria, fungi, algae, and plankton. These amazing creatures are very important to life on Earth. '
            'They act as decomposers, breaking down dead plants and animals, and play a vital role in the nitrogen cycle. '
            'In this game, you\'ll learn about bacteria that live in decaying leaves, diseases, moldy fruit, yeast in breads, '
            'bacteria in yoghurt, salmonella in uncooked food, and more. Look carefully and spot places where microorganisms might be at work!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🦠',
        color: '9C27B0', // Purple
      ),
      const WebGame(
        id: 'health-growth',
        title: 'Human Body Health & Growth',
        description:
            'Learn how the human body needs water, food, exercise and rest to stay healthy and grow properly with this interactive activity.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/healthgrowth.html',
        canvasSelector: null,
        topics: [
          'Human Body',
          'Health',
          'Nutrition',
          'Exercise',
          'Rest',
          'Growth',
          'Hydration',
          'Wellness',
        ],
        learningGoals: [
          'Understand the four essential needs for human health: water, food, exercise, and rest.',
          'Learn what happens when the body lacks water (dehydration), food (hunger and weakness), rest (tiredness), or exercise (laziness).',
          'Discover how a balanced lifestyle helps people grow into strong, healthy adults.',
          'Practice providing Ben with the right balance of water, food, exercise, and rest.',
          'Recognize the importance of taking care of our bodies for proper growth and development.',
        ],
        explanation:
            'Our bodies need four important things to stay healthy and grow properly: water, food, exercise, and rest! '
            'In this game, you\'ll help Ben stay healthy by providing him with what he needs. Without water, Ben will get dehydrated. '
            'Without food, he\'ll get hungry and weak. Without rest, he\'ll get tired. And without exercise, he\'ll get lazy. '
            'Ben needs a good balance of all these things if he is to grow into a strong, healthy adult. '
            'Can you help Ben live a healthy life? Use water, food, exercise, and rest to keep him happy and growing!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🏃',
        color: 'E91E63', // Pink/Red for health
      ),
      const WebGame(
        id: 'teeth-eating',
        title: 'Teeth & Eating',
        description:
            'Learn how different animals have different teeth adapted to their diet, from lions to sheep, and discover how human teeth compare.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/teetheating.html',
        canvasSelector: null,
        topics: [
          'Teeth',
          'Animals',
          'Herbivores',
          'Carnivores',
          'Adaptation',
          'Human Body',
          'Nutrition',
          'Biology',
        ],
        learningGoals: [
          'Discover how different animals have different teeth adapted to their diet (lions vs sheep).',
          'Learn about human teeth types: incisors, molars, and canines, and how they help us eat different foods.',
          'Understand how herbivores\' teeth are adapted to cut through leaves and grass.',
          'Explore how carnivores\' teeth are adapted for hunting and killing prey.',
          'Recognize that some animals have no teeth at all and how they eat differently.',
        ],
        explanation:
            'Did you know that lions have very different teeth than sheep? That\'s because they eat different foods! '
            'In this game, you\'ll learn how the size and shape of animals\' teeth are adapted to what they eat. '
            'Humans have different types of teeth too: incisors for cutting, molars for grinding, and canines for tearing. '
            'These teeth help us eat a wide range of foods! Herbivores (animals that only eat plants) have teeth specially adapted '
            'to cut through leaves and grass. Carnivores (animals that only eat meat) have teeth adapted for hunting and killing. '
            'And some animals have no teeth at all! Can you discover how teeth have adapted over time to help animals survive?',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🦷',
        color: '00BCD4', // Cyan/Teal for teeth
      ),
      const WebGame(
        id: 'plants-animals',
        title: 'Plants & Animals',
        description:
            'Spot plants and animals in an outdoor scene, discover where they live and learn how different habitats suit different living things.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/plantsanimals.html',
        canvasSelector: null,
        topics: [
          'Plants',
          'Animals',
          'Habitats',
          'Living Things',
          'Environment',
          'Nature',
          'Biology',
          'Ecosystems',
        ],
        learningGoals: [
          'Spot different living things in an outdoor scene such as flowers, trees, insects, and birds.',
          'Discover where different plants and animals live and why they choose those habitats.',
          'Understand how different animals live in habitats that suit their characteristics.',
          'Learn how plants thrive in environments that suit their needs.',
          'Explore interesting facts about plants and animals and their relationships with their habitats.',
        ],
        explanation:
            'Can you spot all the living things in an outdoor scene? In this game, you\'ll explore nature and discover plants and animals! '
            'You\'ll learn about flowers, trees, insects, birds, and more. Different animals tend to live in different habitats that suit '
            'their characteristics - some like forests, some like meadows, and some like ponds! The same is true for plants - they thrive '
            'in environments that suit them. A cactus loves the desert, while a fern loves the shade of a forest. '
            'As you complete the fun activities, you\'ll discover more about where plants and animals live and other interesting facts about these amazing living things!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🌿',
        color: '4CAF50', // Green for nature/plants
      ),
      const WebGame(
        id: 'keeping-healthy',
        title: 'Keeping Healthy',
        description:
            'Discover how different exercises like walking and running affect heart rate, and learn about the circulatory system and how your heart works.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/keephealthy.html',
        canvasSelector: null,
        topics: [
          'Health',
          'Heart',
          'Exercise',
          'Circulatory System',
          'Heart Rate',
          'Blood',
          'Arteries',
          'Veins',
        ],
        learningGoals: [
          'Discover how different exercises such as walking and running affect heart rate.',
          'Watch how Ruby\'s heart rate changes as she sleeps, sits, walks, and runs.',
          'Learn about the circulatory system and how the heart pumps blood around the body.',
          'Understand why blood goes to the lungs to pick up oxygen.',
          'Explore the important roles that arteries and veins play in the circulatory system.',
        ],
        explanation:
            'Did you know that your heart rate changes when you exercise? In this game, you\'ll help Ruby stay healthy and learn all about the heart! '
            'Ruby\'s heart rate will change as you make her sleep, sit, walk, and run. Watch how her body reacts to different activities and see how '
            'her beats per minute change! You\'ll learn about your circulatory system - how your heart works as it pumps blood around your body. '
            'You\'ll discover why blood goes to your lungs to pick up oxygen, and what important roles your arteries and veins have in the process. '
            'Keeping healthy is an important topic, and you can understand it better by seeing how the human heart reacts to different activities!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '❤️',
        color: 'F44336', // Red for heart/health
      ),
      const WebGame(
        id: 'how-plants-grow',
        title: 'How Plants Grow',
        description:
            'Experiment with heat and water to help a plant grow, learn about balance and discover what happens when conditions change.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/plantsgrow.html',
        canvasSelector: null,
        topics: [
          'Plants',
          'Growth',
          'Experiments',
          'Water',
          'Sunlight',
          'Temperature',
          'Balance',
          'Care',
        ],
        learningGoals: [
          'Use heat and water to help a plant grow to a healthy size.',
          'Understand that too much sun and moisture can have negative effects on plants.',
          'Learn to keep amounts in balance to keep plants growing healthily.',
          'Experiment with different conditions: closing blinds, removing sunlight, forgetting to water, or adding too much water.',
          'Discover what happens when conditions become too hot or too cold, and take the challenge to care for a plant for 4 weeks.',
        ],
        explanation:
            'Can you help a plant grow to a healthy size? In this game, you\'ll experiment with heat and water to see if you can make the plant grow! '
            'But be careful - too much sun and moisture can have a negative effect on the plant, so you need to be careful when giving it nutrients. '
            'Keep the amounts in balance and see how long you can keep the plant growing healthily! Experiment with different conditions: '
            'What does closing the blinds and removing the sunlight do? What happens if you forget to water the plant or add too much water? '
            'How about if the conditions become too hot or too cold? Can you take care of the plant for 4 weeks? Take up the challenge and give it a try!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🌱',
        color: '66BB6A', // Light green for plant growth
      ),
      const WebGame(
        id: 'skeleton-bones',
        title: 'Skeleton & Bones',
        description:
            'Sort and label bones of human and animal skeletons, discover where bones belong in the body and learn interesting facts about skeletons.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/movinggrowing.html',
        canvasSelector: null,
        topics: [
          'Skeleton',
          'Bones',
          'Human Body',
          'Anatomy',
          'Animals',
          'Exoskeletons',
          'Structure',
          'Biology',
        ],
        learningGoals: [
          'Sort and label the bones of a human skeleton and learn where they belong in the body.',
          'Explore skeletons of other animals such as insects, fish, and horses.',
          'Find out where bones such as ribs, skull, collar bone, and pelvis belong inside the human body.',
          'Learn that there are over 200 bones in the adult human body.',
          'Discover that insects have exoskeletons (skeletons on the outside of their bodies) like crabs and lobsters.',
        ],
        explanation:
            'Skeletons are the structures that hold our bodies together and are very important to keeping us healthy! '
            'In this game, you\'ll learn about moving and growing by sorting and labeling the bones of a human skeleton, '
            'as well as the skeletons of other animals such as an insect, fish, or horse. Find out where bones such as the ribs, '
            'skull, collar bone, and pelvis belong inside the human body. Did you know there are over 200 bones in the adult human body? '
            'Or that like crabs and lobsters, insects have exoskeletons (skeletons on the outside of their bodies)? '
            'Enjoy finding out more about animal bones and the human skeleton with this cool, interactive game!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🦴',
        color: '9E9E9E', // Gray for bones/skeleton
      ),
      const WebGame(
        id: 'plant-animal-differences',
        title: 'Plant & Animal Differences',
        description:
            'Sort plants and animals into different categories, discover which category living things like bees, penguins, horses, and trees fit into.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/plantanimaldif.html',
        canvasSelector: null,
        topics: [
          'Plants',
          'Animals',
          'Mammals',
          'Birds',
          'Insects',
          'Categories',
          'Classification',
          'Living Things',
        ],
        learningGoals: [
          'Learn about the differences between animals and plants by sorting them into different categories.',
          'Discover more about mammals, birds, insects, and plants through interactive sorting.',
          'Find out which category living things such as bees, penguins, horses, butterflies, humans, trees, and flowers fit into.',
          'Work quickly to sort items as the conveyor belt moves across the screen.',
          'Practice putting different plants and animals into the correct boxes and take up the challenge!',
        ],
        explanation:
            'Can you tell the difference between plants and animals? In this game, you\'ll learn about the differences between animals and plants '
            'by sorting them into different categories! Discover more about mammals, birds, insects, and plants with this fun activity. '
            'Find out which category living things such as bees, penguins, horses, butterflies, humans, trees, and flowers fit into. '
            'Work fast as the conveyor belt moves across the screen - quickly put the different plants and animals into the correct boxes! '
            'Take up the challenge and enjoy this cool, educational game that will help you understand how we classify living things!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🦋',
        color: 'FF9800', // Orange for butterflies/flowers
      ),
      const WebGame(
        id: 'life-cycle-plant',
        title: 'Life Cycle of a Plant',
        description:
            'Sort the parts of a flower and discover what each part does, learn about petals, sepals, stamens and more in this interactive activity.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/lifecycles.html',
        canvasSelector: null,
        topics: [
          'Plants',
          'Flowers',
          'Life Cycle',
          'Plant Parts',
          'Biology',
          'Pollination',
          'Reproduction',
          'Nature',
        ],
        learningGoals: [
          'Learn about the life cycle of a plant by sorting the parts of a flower.',
          'Discover what each flower part does and how it contributes to the life cycle of a living thing.',
          'Explore flower parts including petals, sepals, carpel, nectaries, receptacle, and stamens.',
          'Sort flower parts into the correct categories, label them, and learn useful information.',
          'Learn interesting facts: stamens make pollen, nectar is made in nectaries, and petals attract insects!',
        ],
        explanation:
            'Do you know what makes a flower grow? In this game, you\'ll learn about the life cycle of a plant by sorting the parts of a flower! '
            'Discover what each part does and how it contributes to the life cycle of a living thing. Enjoy the interactive flower dissection activity '
            'and find out more about the flower petals, sepals, carpel, nectaries, receptacle, and stamens. Experiment with the different parts of a flower, '
            'sort them into the correct categories, label them, and learn useful information. Did you know that stamens make pollen, the nectar used by bees '
            'to make honey is made in the nectaries of a flower, and petals are often bright so they attract insects? '
            'This fun, educational game will help you understand how plants grow and reproduce!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🌸',
        color: 'E91E63', // Pink for flowers
      ),
      const WebGame(
        id: 'electricity-circuits',
        title: 'Electricity Circuits',
        description:
            'Experiment with batteries, voltages and light bulbs, wire them in different ways and see how changing the circuit affects the results.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/electricitycircuits.html',
        canvasSelector: null,
        topics: [
          'Electricity',
          'Circuits',
          'Batteries',
          'Voltage',
          'Light Bulbs',
          'Physics',
          'Energy',
          'Technology',
        ],
        learningGoals: [
          'Learn about electricity circuits by experimenting with batteries, voltages, and light bulbs.',
          'Discover how wiring components in different ways can result in surprising outcomes.',
          'Understand how changing the battery voltage makes the light bulb glow brighter.',
          'Check your model and see how it looks as a circuit diagram.',
          'Enjoy challenges involving changing circuits, moving switches, replacing bulbs, and adding longer wires.',
        ],
        explanation:
            'How does electricity flow? In this game, you\'ll learn about electricity circuits as you experiment with batteries, voltages, and light bulbs! '
            'Wiring them in different ways can result in surprising outcomes. Try changing the battery in the circuit to make the light bulb glow brighter - '
            'increasing the voltage will have this effect. Check your model and see how it looks as a circuit diagram. Enjoy the variety of challenges that '
            'involve changing the circuit, moving switches, replacing bulbs, changing the battery volts, and adding longer wires. '
            'This fun, interactive electricity game will help you understand how electrical circuits work!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '⚡',
        color: 'FFC107', // Yellow/amber for electricity/energy
      ),
      const WebGame(
        id: 'forces-action',
        title: 'Forces in Action',
        description:
            'Experiment with gradients, weights, motion and resistance to see how they affect movement, try to get the truck down the ramp.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/forcesinaction.html',
        canvasSelector: null,
        topics: [
          'Forces',
          'Motion',
          'Physics',
          'Gradients',
          'Weights',
          'Resistance',
          'Experiments',
          'Mechanics',
        ],
        learningGoals: [
          'Learn about forces in action by experimenting with gradients, weights, motion, and resistance.',
          'Try to get the truck down the ramp and to the end of the track by adding a range of weights.',
          'Record the results in a table as you watch how different conditions affect the outcome of experiments.',
          'Discover what happens when you make a steep gradient or add a parachute to the back of the truck.',
          'Understand how forces affect the movement of various objects through hands-on experimentation.',
        ],
        explanation:
            'How do forces work? In this game, you\'ll learn about forces in action as you experiment with how gradients, weights, motion, and resistance '
            'affect the movement of various objects! Try to get the truck down the ramp and to the end of the track by adding a range of weights. '
            'Record the results in a table as you watch how the different conditions affect the outcome of the experiments. What happens when you make a '
            'steep gradient or add a parachute to the back of the truck? Find out while enjoying this fun, interactive game that will help you understand '
            'how forces work in the real world!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🚚',
        color: '607D8B', // Blue-gray for mechanics/physics
      ),
      const WebGame(
        id: 'how-we-see',
        title: 'How We See',
        description:
            'Learn how we see by experimenting with light and mirrors, change mirror angles to reflect light and illuminate objects.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/howwesee.html',
        canvasSelector: null,
        topics: [
          'Eyes',
          'Vision',
          'Light',
          'Mirrors',
          'Reflection',
          'Human Body',
          'Physics',
          'Optics',
        ],
        learningGoals: [
          'Learn how we see as you experiment with light and mirrors in this fun science game.',
          'Change the mirror angles to see which way they reflect the light.',
          'Practice to get the mirrors at the right angles so that the light reflects onto the tent.',
          'Use what you\'ve learned to try and illuminate other objects by controlling the path of the light.',
          'Understand how eyes are amazing parts of the human body and how vision works.',
        ],
        explanation:
            'Eyes are amazing parts of the human body! In this game, you\'ll learn how we see as you experiment with light and mirrors! '
            'Change the mirror angles to see which way they reflect the light. Practice hard and see if you can get the mirrors at the right angles '
            'so that the light reflects onto the tent. Once you\'ve achieved that goal, use what you\'ve learned to try and illuminate other objects '
            'by controlling the path of the light. Kids will love the challenge of this cool, interactive activity that will help you understand how '
            'light and vision work together!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '👁️',
        color: '9C27B0', // Purple for vision/optics
      ),
      const WebGame(
        id: 'earth-sun-moon',
        title: 'Earth, Sun & Moon',
        description:
            'Learn about orbits as you experiment with different dates and times, discover how Earth, Sun and Moon move through space.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/earthsunmoon.html',
        canvasSelector: null,
        topics: [
          'Earth',
          'Sun',
          'Moon',
          'Orbits',
          'Space',
          'Astronomy',
          'Calendar',
          'Solar System',
        ],
        learningGoals: [
          'Learn about the Earth, Sun & Moon\'s orbits as you experiment with different dates and times.',
          'Discover how long the Earth takes to orbit the Sun and how many hours it takes to spin around once on its own axis.',
          'Learn how long the Moon takes to orbit the Earth and how it all relates to our calendar.',
          'Watch how the Earth and Moon orbit the Sun and see if it matches your expectations.',
          'Find out more about the size of the Earth, Sun & Moon, their shape and the speed they travel through space.',
        ],
        explanation:
            'How do the Earth, Sun, and Moon move? In this game, you\'ll learn about the Earth, Sun & Moon\'s orbits as you experiment with '
            'different dates and times! Discover how long the Earth takes to orbit the Sun, how many hours it takes the Earth to spin around once '
            'on its own axis, how long the Moon takes to orbit the Earth, and how it all relates to our calendar and other useful facts. '
            'Watch how the Earth and Moon orbit the Sun - is it how you expected? Find the answers to these questions and learn more about the size '
            'of the Earth, Sun & Moon, their shape, and the speed they travel through space with this cool, interactive science game!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🌍',
        color: '1976D2', // Blue for space/astronomy
      ),
      const WebGame(
        id: 'circuits-conductors',
        title: 'Circuits & Conductors',
        description:
            'Experiment with conductors and power sources, find out what materials conduct electricity and try lighting the bulb with different objects.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/circuitsconductors.html',
        canvasSelector: null,
        topics: [
          'Electricity',
          'Circuits',
          'Conductors',
          'Materials',
          'Physics',
          'Energy',
          'Experiments',
          'Science',
        ],
        learningGoals: [
          'Learn about electricity circuits as you experiment with conductors and power sources.',
          'Find out what materials conduct electricity better than others.',
          'Try lighting the bulb by putting different objects and materials such as a coin, cork, rubber, key, chalk, plastic, or wire into the gap in the circuit.',
          'Discover what happens to the bulb brightness when you add another bulb to the circuit.',
          'Notice the difference in brightness if you have just one bulb but two batteries, and play around with different combinations.',
        ],
        explanation:
            'What makes electricity flow? In this game, you\'ll learn about electricity circuits as you experiment with conductors and power sources! '
            'Find out what materials conduct electricity better than others. Try lighting the bulb by putting different objects and materials such as a coin, '
            'cork, rubber, key, chalk, plastic, or wire into the gap in the circuit. What happens to the bulb brightness when you add another bulb to the circuit? '
            'Do you notice a difference in brightness if you have just one bulb but two batteries? Play around with different combinations, learn more about '
            'electricity, and enjoy this great science game that will help you understand how conductors work!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🔌',
        color: 'FF6F00', // Deep orange for electricity/conductors
      ),
      const WebGame(
        id: 'magnets-springs',
        title: 'Magnets & Springs',
        description:
            'Combine magnets and springs to complete magnetic challenges, find out what objects magnets attract and experiment with magnetic strength.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/magnetssprings.html',
        canvasSelector: null,
        topics: [
          'Magnets',
          'Springs',
          'Physics',
          'Forces',
          'Experiments',
          'Materials',
          'Science',
          'Mechanics',
        ],
        learningGoals: [
          'Learn about magnets and springs as you combine the two to complete various magnetic challenges.',
          'Find out what objects magnets are attracted to and discover if magnets pick up plastic objects or aluminum cans.',
          'Experiment and find out how magnets and springs work together.',
          'Discover how the distance you pull back the spring affects how far the magnet will travel.',
          'Try rotating the magnet or changing to a big or small size, and see how this affects the magnetic strength.',
        ],
        explanation:
            'How do magnets work? In this game, you\'ll learn about magnets and springs as you combine the two to complete various magnetic challenges! '
            'Find out what objects magnets are attracted to and more. Will the magnet pick up plastic objects? How about aluminum cans? Experiment and find out '
            'how magnets and springs work. How does the distance you pull back the spring affect how far the magnet will travel? Try rotating the magnet or '
            'changing to a big or small size - how does this affect the magnetic strength? Enjoy these challenges and more with this cool, interactive game '
            'that will help you understand how magnets and forces work!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🧲',
        color: 'E53935', // Red for magnets
      ),
      const WebGame(
        id: 'sun-light-shadows',
        title: 'Sun, Light & Shadows',
        description:
            'Experiment with different light sources and objects, discover how moving light closer or further affects shadow size and learn about the sun.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/lightshadows.html',
        canvasSelector: null,
        topics: [
          'Sun',
          'Light',
          'Shadows',
          'Physics',
          'Optics',
          'Experiments',
          'Science',
          'Nature',
        ],
        learningGoals: [
          'Learn about the sun, light, and shadows as you experiment with different light sources and objects.',
          'Discover how moving a light source closer to an object makes its shadow grow larger, while moving it away has the opposite effect.',
          'Experiment and see what happens to shadows when you tilt the light source or change its brightness.',
          'Head outside and see how sunlight creates shadows with various objects such as trees, houses, and cars.',
          'Learn how the sun\'s position in the sky affects the size of shadows, and discover that even the moon can create shadows.',
        ],
        explanation:
            'How do shadows work? In this game, you\'ll learn about the sun, light, and shadows as you experiment with different light sources and objects! '
            'Moving a light source closer to an object can make its shadow grow larger while moving the light source away can have the opposite effect. '
            'Experiment and see what happens to the shadows of different objects when you tilt the light source or change its brightness - what happens to the '
            'shadow if the light source is dim? Head outside and see how sunlight creates shadows with various objects such as trees, houses, and cars. '
            'Learn how the sun\'s position in the sky affects the size of shadows. Even the moon can create shadows when it reflects light from the sun. '
            'Enjoy the challenge of this cool science game that will help you understand how light and shadows work!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '☀️',
        color: 'FFA726', // Orange-yellow for sun/light
      ),
      const WebGame(
        id: 'changing-sounds',
        title: 'Changing Sounds',
        description:
            'Experiment with different musical instruments, discover how string length affects pitch and learn about sound through drums, guitar and bottles.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/changingsounds.html',
        canvasSelector: null,
        topics: [
          'Sound',
          'Music',
          'Instruments',
          'Pitch',
          'Loudness',
          'Physics',
          'Experiments',
          'Science',
        ],
        learningGoals: [
          'Learn about changing sounds and music as you experiment with different musical instruments.',
          'Discover how plucking strings of different lengths results in a variety of sounds, from high pitched to very low pitched.',
          'Play instruments such as drums, the guitar, and even a bottle, and experiment with different settings.',
          'Sort your results into a pitch and loudness grid to understand how sounds change.',
          'Listen to the noise as you blow on a bottle, then see what happens when you fill it with water, and discover how tightening drum skin changes pitch.',
        ],
        explanation:
            'How do sounds change? In this game, you\'ll learn about changing sounds and music as you experiment with different musical instruments! '
            'Plucking strings of different lengths results in a variety of sounds - some can be high pitched while others can be very low pitched. '
            'Play instruments such as drums, the guitar, and even a bottle. Experiment with different settings and sort your results into a pitch and loudness grid. '
            'Listen to the noise as you blow on a bottle and then see what happens when you try again after filling it with water. Bang on a drum and listen to '
            'the change in pitch as you tighten the drum skin. Kids will enjoy the challenges of this cool science game that will help you understand how sound works!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🎵',
        color: '9C27B0', // Purple for music/sound
      ),
      const WebGame(
        id: 'friction',
        title: 'Friction',
        description:
            'Experiment how vehicles move on different surfaces, discover which slows them down more and learn about kinetic friction through interactive play.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/friction.html',
        canvasSelector: null,
        topics: [
          'Friction',
          'Physics',
          'Forces',
          'Motion',
          'Surfaces',
          'Resistance',
          'Experiments',
          'Science',
        ],
        learningGoals: [
          'Learn about friction as you experiment how the movement of vehicles responds to different surfaces and levels of resistance.',
          'Discover which surface slows a vehicle down more - vinyl, wood, carpet, or ice.',
          'Try and get the car to the end of the track by putting the principles of kinetic friction into action.',
          'Change the track surface by scrolling through different surfaces and dragging the desired surface type onto the track.',
          'Understand how friction affects motion and why different surfaces create different amounts of resistance.',
        ],
        explanation:
            'How does friction work? In this game, you\'ll learn about friction as you experiment how the movement of vehicles responds to different surfaces and levels of resistance! '
            'Which surface slows a vehicle down more - vinyl, wood, carpet, or ice? Try and get the car to the end of the track by putting the principles and fun science information '
            'you learn about kinetic friction into action. To change the track surface simply scroll through the different surfaces at the bottom of the screen before clicking and '
            'dragging the desired surface type on to the track. Kids will enjoy this interactive and educational friction activity that will help you understand how friction affects motion!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🚗',
        color: 'D32F2F', // Red for friction/motion
      ),
      const WebGame(
        id: 'light-dark',
        title: 'Light & Dark',
        description:
            'Experiment with different objects to learn about light sources and reflections, discover which give out light and which just reflect it.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/lightdark.html',
        canvasSelector: null,
        topics: [
          'Light',
          'Dark',
          'Light Sources',
          'Reflections',
          'Physics',
          'Optics',
          'Experiments',
          'Science',
        ],
        learningGoals: [
          'Learn about light & dark as well as light sources & reflections as you experiment with different objects.',
          'Discover whether objects like a mirror ball give out light or just reflect light from another source.',
          'Experiment with different objects such as a lamp, torch, animal, or jacket and see what results you get.',
          'Learn the difference between light sources and reflections, and which light sources give the brightest light.',
          'Understand properties of sunlight and how wearing reflective strips can make cyclists stand out more for safety.',
        ],
        explanation:
            'What is the difference between light sources and reflections? In this game, you\'ll learn about light & dark as well as light sources & reflections as you experiment with different objects! '
            'Does a mirror ball give out light or does it just reflect light from another source? What about a lamp, torch, animal, or jacket? Play around with the objects and see what results you get. '
            'Learn the difference between light sources and reflections, which light sources give the brightest light, properties of sunlight and how wearing reflective strips can make cyclists stand out '
            'more so they are less likely to be hit by cars. Kids will enjoy experimenting with this interactive science game that will help you understand how light works!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '💡',
        color: 'FFC107', // Amber/yellow for light
      ),
      const WebGame(
        id: 'changing-state-water',
        title: 'Changing State of Water',
        description:
            'Experiment with different temperatures to learn about water states, discover what happens at 100 degrees and compare ice and water volume.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/statematerials.html',
        canvasSelector: null,
        topics: [
          'Water',
          'States of Matter',
          'Temperature',
          'Ice',
          'Steam',
          'Physics',
          'Chemistry',
          'Experiments',
          'Science',
        ],
        learningGoals: [
          'Learn about the changing states of water as you experiment with different temperatures.',
          'Discover what happens when water reaches 100 degrees and understand the boiling point.',
          'Find out whether water or ice takes up a larger volume and understand density changes.',
          'Play around with ice, water, and steam to see what happens when you heat and cool them.',
          'Watch what happens when heating steam to high temperatures and try turning water to gas and back to liquid.',
        ],
        explanation:
            'How does water change states? In this game, you\'ll learn about the changing states of water as you experiment with different temperatures! '
            'What happens when water reaches 100 degrees? Does water or ice take up a larger volume? Give it a go and find out! Play around with ice, water, and steam to find out what happens when you heat and cool them. '
            'Watch what happens if you try heating the steam to high temperatures, try turning water to gas and back to a liquid again and enjoy all the other challenges in this cool science game for kids. '
            'This interactive activity will help you understand how temperature affects the state of matter and how water transforms between solid, liquid, and gas!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '💧',
        color: '2196F3', // Blue for water
      ),
      const WebGame(
        id: 'reversible-changes',
        title: 'Reversible Changes',
        description:
            'Test different substances to learn about reversible and irreversible changes, discover what dissolves in water and explore chemistry facts.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/reversiblechanges.html',
        canvasSelector: null,
        topics: [
          'Reversible Changes',
          'Irreversible Changes',
          'Chemistry',
          'Dissolving',
          'Substances',
          'Experiments',
          'Science',
          'Materials',
        ],
        learningGoals: [
          'Learn about reversible & irreversible changes by testing what happens to different substances as you experiment with them.',
          'Find out what substances dissolve in water and discover lots of other interesting chemistry related facts.',
          'Discover whether all substances can be turned back to their original form after they mix with water or stay that way forever.',
          'Try dissolving flour, sugar, and sand in a beaker of water and observe what happens.',
          'Answer questions like: Is melting ice an irreversible change? How about cooking an egg?',
        ],
        explanation:
            'What are reversible and irreversible changes? In this game, you\'ll learn about reversible & irreversible changes by testing what happens to different substances as you experiment with them! '
            'Find out what substances dissolve in water and lots of other interesting chemistry related facts. Can all substances be turned back to their original form after they mix with water or will they stay that way forever? '
            'Try dissolving flour, sugar, and sand in a beaker of water, what happens? Is it what you expected? Is melting ice an irreversible change? How about cooking an egg? '
            'Challenge yourself to answer these questions and more with this cool science game that will help you understand the difference between reversible and irreversible changes!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🧪',
        color: '4CAF50', // Green for chemistry/experiments
      ),
      const WebGame(
        id: 'properties-materials',
        title: 'Properties of Materials',
        description:
            'Experiment with objects to discover material characteristics like flexibility, waterproofing and strength, then use blueprints to make objects.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/materialproperties.html',
        canvasSelector: null,
        topics: [
          'Materials',
          'Properties',
          'Flexibility',
          'Waterproof',
          'Strength',
          'Transparency',
          'Experiments',
          'Science',
        ],
        learningGoals: [
          'Learn about the properties of materials as you experiment with a variety of objects.',
          'Discover the interesting characteristics of materials - are they flexible, waterproof, strong, or transparent?',
          'Play around with the objects and see what interesting facts you observe.',
          'Test the properties of metal, paper, fabric, rubber, and glass before using a blueprint to make objects.',
          'Try making a car tire, saucepan, towel, notebook, sports bottle, and window, and discover what happens when using the wrong material.',
        ],
        explanation:
            'What are the properties of materials? In this game, you\'ll learn about the properties of materials as you experiment with a variety of objects! '
            'Discover the interesting characteristics of materials; are they flexible, waterproof, strong, or transparent? Play around with the objects and see what interesting facts you observe. '
            'Test the properties of metal, paper, fabric, rubber, and glass before using a blueprint to make objects from the different materials. Try making a car tire, saucepan, towel, notebook, '
            'sports bottle, and window - what happens when you try making them from the wrong material? Why are some better suited than others? Kids will enjoy the challenge of this cool, interactive game!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🔧',
        color: '795548', // Brown for materials/construction
      ),
      const WebGame(
        id: 'rocks-minerals-soils',
        title: 'Rocks, Minerals & Soils',
        description:
            'Complete experiments to learn about rocks, minerals and soils, discover properties of different rocks and find out which rocks split or float.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/rockssoils.html',
        canvasSelector: null,
        topics: [
          'Rocks',
          'Minerals',
          'Soils',
          'Geology',
          'Properties',
          'Experiments',
          'Science',
          'Earth Science',
        ],
        learningGoals: [
          'Learn about rocks, minerals & soils as you complete a variety of experiments.',
          'Discover that rocks, minerals, and soils have different characteristics that set them apart from others.',
          'Find out about the properties of rocks such as slate, marble, chalk, granite, and pumice.',
          'Answer scientific questions like: Which rocks split? Can you find a rock that floats?',
          'Explore the unique characteristics of different types of rocks and understand their properties.',
        ],
        explanation:
            'What makes rocks, minerals, and soils different? In this game, you\'ll learn about rocks, minerals & soils as you complete a variety of experiments! '
            'Rocks, minerals, and soils have different characteristics that set them apart from others. Find out about the properties of rocks such as slate, marble, chalk, granite, and pumice. '
            'Which rocks split? Can you find a rock that floats? Answer these and other scientific questions with this science game that will help you understand the fascinating world of geology!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🪨',
        color: '8D6E63', // Brown-gray for rocks/earth
      ),
      const WebGame(
        id: 'melting-points',
        title: 'Melting Points',
        description:
            'Experiment with different temperatures to learn about melting points, discover which substances melt at different temperatures.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/meltingpoints.html',
        canvasSelector: null,
        topics: [
          'Melting Points',
          'Temperature',
          'Solids',
          'Liquids',
          'Heat',
          'Chemistry',
          'Physics',
          'Experiments',
          'Science',
        ],
        learningGoals: [
          'Learn about the melting points of different substances by experimenting with different temperatures.',
          'Have fun as you heat and cool various solids and liquids.',
          'Discover at what point things like chocolate, aluminum, candle wax, butter, and ice candy melt.',
          'Find out which objects have the lowest melting points and which ones need high heat before they begin to change.',
          'Put substances into the testing beaker and observe the surprising results.',
        ],
        explanation:
            'What are melting points? In this game, you\'ll learn about the melting points of different substances by experimenting with different temperatures! '
            'Have fun as you heat and cool various solids and liquids. At what point do things like chocolate, aluminum, candle wax, butter, and ice candy melt? '
            'What objects have the lowest melting points and which ones need high heat before they begin to change? Put them into the testing beaker and give it a try, '
            'you might be surprised by the results. Enjoy this cool science game for kids that will help you understand how temperature affects different materials!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🔥',
        color: 'F44336', // Red for heat/fire
      ),
      const WebGame(
        id: 'solids-liquids-gases',
        title: 'Solids, Liquids and Gases',
        description:
            'Experiment with conditions that change matter between forms, discover how water exists as ice, liquid and steam, and categorize examples.',
        websiteUrl: 'https://www.sciencekids.co.nz/gamesactivities/gases.html',
        canvasSelector: null,
        topics: [
          'Solids',
          'Liquids',
          'Gases',
          'States of Matter',
          'Temperature',
          'Physics',
          'Chemistry',
          'Experiments',
          'Science',
        ],
        learningGoals: [
          'Learn about solids, liquids, and gases as you experiment with the conditions that change them from one form to another.',
          'Discover that water is a common example as it exists in all three forms - ice, liquid water, and steam.',
          'Challenge yourself to find the correct category for examples such as milk, sand, rain, helium, wood, and air.',
          'Watch what happens when you heat liquids and cool gases.',
          'Understand that the processes that change solids, liquids, and gases from one form to another are important science topics.',
        ],
        explanation:
            'What are solids, liquids, and gases? In this game, you\'ll learn about solids, liquids, and gases as you experiment with the conditions that change them from one form to another! '
            'Water is a common example as it exists in all three forms, you\'ve no doubt seen it as ice, liquid water, and steam. Challenge yourself to find the correct category for other examples '
            'such as milk, sand, rain, helium, wood, and air. Watch what happens when you heat liquids and cool gases. The processes that change solids, liquids, and gases from one form to another '
            'are important science topics - humans breathe in gases in the form of air and drink liquids such as water which help keep us alive. Educational and entertaining, this game offers a fun challenge for kids!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '💨',
        color: '00BCD4', // Cyan for gases/air
      ),
      const WebGame(
        id: 'heat-transfer',
        title: 'Heat Transfer',
        description:
            'Test different materials to learn about heat transfer, discover thermal conductors and insulators, and record temperature changes.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/keepingwarm.html',
        canvasSelector: null,
        topics: [
          'Heat Transfer',
          'Thermal Conductors',
          'Thermal Insulators',
          'Temperature',
          'Materials',
          'Physics',
          'Experiments',
          'Science',
        ],
        learningGoals: [
          'Learn about heat transfer and how to keep things warm by testing the characteristics of different materials.',
          'Discover that some materials are good thermal conductors, easily letting heat pass through them.',
          'Learn that other materials are good thermal insulators, not easily letting heat pass through them.',
          'Conduct experiments and watch how the temperature changes, then record your results on a table.',
          'Find out if metal, cardboard, and polystyrene are good at thermal insulation or have good thermal conductivity.',
        ],
        explanation:
            'How does heat transfer work? In this game, you\'ll learn about heat transfer and how to keep things warm by testing the characteristics of different materials! '
            'Some materials are good thermal conductors, easily letting heat pass through them, while others are good thermal insulators, not easily letting heat pass through them. '
            'Conduct experiments and watch how the temperature changes. Record your results on a table and make your own conclusions - some materials help keep things warm while others make them go cold quick. '
            'Find out if metal, cardboard, and polystyrene are good at thermal insulation or have good thermal conductivity by checking out this heat transfer activity!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🌡️',
        color: 'FF5722', // Deep orange for heat/thermal
      ),
    ];

    if (subject != null) {
      return allGames.where((game) => game.subject == subject).toList();
    }
    return allGames;
  }

  /// Get web games for Bright children (9-12)
  Future<List<WebGame>> _getBrightWebGames({String? subject}) async {
    final juniorGames = await _getJuniorWebGames(subject: subject);
    return juniorGames
        .map(
          (game) => _cloneGameForAgeGroup(
            game,
            idSuffix: 'bright',
            targetAgeGroup: 'bright',
          ),
        )
        .toList();
  }

  WebGame _cloneGameForAgeGroup(
    WebGame game, {
    required String idSuffix,
    required String targetAgeGroup,
  }) {
    return WebGame(
      id: '${game.id}-$idSuffix',
      title: game.title,
      description: game.description,
      websiteUrl: game.websiteUrl,
      canvasSelector: game.canvasSelector,
      topics: List<String>.from(game.topics),
      learningGoals: List<String>.from(game.learningGoals),
      explanation: game.explanation,
      warning: game.warning,
      estimatedMinutes: game.estimatedMinutes,
      difficulty: game.difficulty,
      ageGroup: targetAgeGroup,
      subject: game.subject,
      iconEmoji: game.iconEmoji,
      color: game.color,
    );
  }
}
