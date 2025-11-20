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
      // Math Games
      const WebGame(
        id: 'addition',
        title: 'Addition Game for Kids',
        description:
            'Build a water slide by choosing numbers that add to the correct total, complete challenges and improve your addition skills.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/addition.html',
        canvasSelector: null,
        topics: [
          'Addition',
          'Basic Math',
          'Numbers',
          'Arithmetic',
          'Problem Solving',
          'Math',
        ],
        learningGoals: [
          'Complete a range of challenges that will help improve your addition skills.',
          'Build a water slide while making sure you use sections that are the right length for the job.',
          'Choose numbers that add to the correct total.',
          'Finish as many of the challenges as you can.',
          'Have fun playing this free online math game for kids.',
        ],
        explanation:
            'Enjoy this fun addition game for kids! Complete a range of challenges that will help improve your addition skills. '
            'The interactive activities involve building a water slide while making sure you use sections that are the right length for the job. '
            'Choose numbers that add to the correct total, finish as many of the challenges as you can and have fun playing this free online math game for kids!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '➕',
        color: '2196F3', // Blue for math
      ),
      const WebGame(
        id: 'subtraction',
        title: 'Subtraction Game for Kids',
        description:
            'Repair a giant water slide by cutting pipe pieces to correct lengths, solve subtraction problems and complete challenges.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/subtraction.html',
        canvasSelector: null,
        topics: [
          'Subtraction',
          'Basic Math',
          'Numbers',
          'Arithmetic',
          'Problem Solving',
          'Math',
        ],
        learningGoals: [
          'Learn how to subtract as you repair a giant water slide.',
          'Cut pieces of pipe into the correct lengths in the cutting room.',
          'Solve a range of subtraction problems.',
          'See if you can successfully fix the slide.',
          'Put your subtraction skills to the test and complete the challenges.',
        ],
        explanation:
            'Check out this cool subtraction game that\'s great for kids! Learn how to subtract as you repair a giant water slide. '
            'Cut pieces of pipe into the correct lengths in the cutting room, solve a range of subtraction problems and see if you can successfully fix the slide. '
            'Put your subtraction skills to the test, complete the challenges and have fun playing this free online math game for kids!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '➖',
        color: 'FF9800', // Orange for math
      ),
      const WebGame(
        id: 'multiplication',
        title: 'Multiplication Game for Kids',
        description:
            'Move your mouse over signs and click the correct answer, improve your times tables skills with this interactive math game.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/multiplication.html',
        canvasSelector: null,
        topics: [
          'Multiplication',
          'Times Tables',
          'Basic Math',
          'Numbers',
          'Arithmetic',
          'Math',
        ],
        learningGoals: [
          'Have fun improving your math skills online with this cool multiplication game.',
          'Move your mouse over the signs and click on the number you think is the correct answer.',
          'See how many of the questions you can get right.',
          'Improve your times tables skills in a fun, interactive way.',
          'Enjoy this free educational activity that\'s perfect for kids.',
        ],
        explanation:
            'Check out this cool multiplication game for kids and have fun improving your math skills online! '
            'Move your mouse over the signs and click on the number you think is the correct answer. How many of the questions can you get right? '
            'Give it a go and find out! Enjoy this free educational activity that\'s perfect for kids wanting to improve their times tables skills in a fun, interactive way!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '✖️',
        color: '9C27B0', // Purple for math
      ),
      const WebGame(
        id: 'division',
        title: 'Division Game for Kids',
        description:
            'Click on flashing signs with correct answers, practice dividing with different numbers and take your division skills to a new level.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/division.html',
        canvasSelector: null,
        topics: [
          'Division',
          'Basic Math',
          'Numbers',
          'Arithmetic',
          'Problem Solving',
          'Math',
        ],
        learningGoals: [
          'Have fun improving your math skills online with this fun division game for kids.',
          'Click on the flashing signs as they display the answer you think is correct.',
          'Watch carefully and avoid clicking on the signs too early.',
          'Practice dividing with a range of different numbers.',
          'Move on to more difficult challenges and take your division skills to a new level.',
        ],
        explanation:
            'Have fun improving your math skills online with this fun division game for kids! '
            'Click on the flashing signs as they display the answer you think is correct, watch carefully and avoid clicking on the signs too early. '
            'Practice dividing with a range of different numbers, move on to more difficult challenges, take your division skills to a new level and have fun playing this free interactive math game!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '➗',
        color: 'E91E63', // Pink for math
      ),
      const WebGame(
        id: 'shapes',
        title: 'Shapes Game for Kids',
        description:
            'Learn about geometric and 3D shapes, drag shapes into correct groups and discover the difference between triangle types.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/shapes.html',
        canvasSelector: null,
        topics: [
          'Shapes',
          'Geometry',
          '2D Shapes',
          '3D Shapes',
          'Triangles',
          'Math',
        ],
        learningGoals: [
          'Enjoy this shapes game for kids and have fun improving your geometry skills.',
          'Learn about geometric and 3D shapes while completing a range of interactive activities and challenges.',
          'Drag shapes into the correct groups as they move across the screen.',
          'Discover how many shapes you know and identify different types.',
          'Learn to tell the difference between an equilateral triangle and an isosceles triangle.',
        ],
        explanation:
            'Enjoy this shapes game for kids and have fun improving your geometry skills! '
            'Learn about geometric and 3D shapes while completing a range of interactive activities and challenges. '
            'Drag shapes into the correct groups as they move across the screen. How many shapes do you know? '
            'Can you tell the difference between an equilateral triangle and an isosceles triangle? '
            'Give this fun geometry game for kids a try and find out!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '🔷',
        color: '00BCD4', // Cyan for math
      ),
      const WebGame(
        id: 'angles',
        title: 'Angles Game for Kids',
        description:
            'Learn about angles by rotating a water hose to squirt targets, understand how angles work with this interactive math game.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/angles.html',
        canvasSelector: null,
        topics: [
          'Angles',
          'Geometry',
          'Measurement',
          'Rotation',
          'Math Skills',
          'Math',
        ],
        learningGoals: [
          'Learn about angles with this fun angle game for kids that helps improve math skills.',
          'Try to squirt different objects on screen by rotating the water hose at various angles.',
          'See how many of the targets you can hit by adjusting the angle correctly.',
          'Understand how angles work while having fun with this free math game.',
          'Practice using angles in a practical, interactive way that kids will enjoy playing.',
        ],
        explanation:
            'Learn about angles with this fun angle game for kids that helps improve math skills with a range of cool interactive activities! '
            'Try to squirt different objects on screen by rotating the water hose at various angles, how many of the targets can you hit? '
            'Give it a try and find out! Understand how angles work while having fun with this free math game that kids will enjoy playing!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '📐',
        color: 'FF9800', // Orange for math
      ),
      const WebGame(
        id: 'measurements',
        title: 'Measurements Game for Kids',
        description:
            'Learn to measure length and weight of parcels, use interactive scales and a ruler to complete challenges and apply correct postage.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/measurements.html',
        canvasSelector: null,
        topics: [
          'Measurements',
          'Length',
          'Weight',
          'Scales',
          'Ruler',
          'Math',
        ],
        learningGoals: [
          'Learn to measure length and weight with this fun measurement game for kids.',
          'Practice your skills by measuring the length and weight of different parcels.',
          'Take the measurements and give the parcels a stamp featuring the right postage rate.',
          'Complete the challenges with the help of interactive scales and a ruler.',
          'Enjoy this educational activity for kids and have fun learning about math online.',
        ],
        explanation:
            'Learn to measure length and weight with this fun measurement game for kids! '
            'Practice your skills by measuring the length and weight of different parcels. '
            'Take the measurements and give the parcels a stamp featuring the right postage rate. '
            'Complete the challenges with the help of interactive scales and a ruler. '
            'Enjoy this educational activity for kids and have fun learning about math online!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '📏',
        color: '4CAF50', // Green for math
      ),
      const WebGame(
        id: 'grids-coordinates',
        title: 'Grids & Coordinates Game',
        description:
            'Use red compass arrows to move your car and pass the driving test, move north, south, east and west while avoiding obstacles.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/grids.html',
        canvasSelector: null,
        topics: [
          'Grids',
          'Coordinates',
          'Compass Directions',
          'Navigation',
          'Position',
          'Math',
        ],
        learningGoals: [
          'Learn how to use grids and coordinates with this interactive math game for kids.',
          'Use the red compass arrows to move your car and pass the driving test.',
          'Move north, south, east and west while trying to avoid bumping into any other objects.',
          'Finish by parking your car and see how well you did.',
          'Practice driving safely using the grid coordinates and positions.',
        ],
        explanation:
            'Learn how to use grids and coordinates with this interactive math game for kids! '
            'Use the red compass arrows to move your car and pass the driving test. '
            'Move north, south, east and west while trying to avoid bumping into any other objects. '
            'Finish by parking your car and see how well you did, can you drive safely using the grid coordinates and positions? '
            'Have fun playing this free online math game for kids!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '🧭',
        color: '2196F3', // Blue for math
      ),
      const WebGame(
        id: 'transformation',
        title: 'Transformation Game for Kids',
        description:
            'Learn about transformation, rotation and reflection by placing mirror lines and rotating houses clockwise and anti-clockwise.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/transformation.html',
        canvasSelector: null,
        topics: [
          'Transformation',
          'Rotation',
          'Reflection',
          'Translation',
          'Geometry',
          'Math',
        ],
        learningGoals: [
          'Have fun learning about transformation, rotation and reflection with this interactive math game for kids.',
          'Complete a number of activities that will test your skills.',
          'Place a mirror line in the correct position to reflect the house on to its shadow.',
          'Move on to other tasks such as rotating the house clockwise and anti-clockwise.',
          'Finish as many challenges as you can and enjoy improving your math skills online.',
        ],
        explanation:
            'Have fun learning about transformation, rotation and reflection with this interactive math game for kids! '
            'Complete a number of activities that will test your skills. '
            'Place a mirror line in the correct position to reflect the house on to its shadow before moving on to other tasks such as rotating the house clockwise and anti-clockwise. '
            'Finish as many challenges as you can and enjoy improving your math skills online!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '🔄',
        color: 'FF5722', // Deep Orange for math
      ),
      const WebGame(
        id: 'fractions',
        title: 'Fractions Game for Kids',
        description:
            'Practice in the gallery and testing room, move fractions into the right order and cut pipes into correct lengths.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/fractions.html',
        canvasSelector: null,
        topics: [
          'Fractions',
          'Numbers',
          'Ordering',
          'Measurement',
          'Basic Math',
          'Math',
        ],
        learningGoals: [
          'Have fun learning about fractions with this interactive fraction game for kids.',
          'Enjoy challenging activities that will help kids understand how fractions work.',
          'Practice in the gallery and testing room.',
          'Move fractions into the right order and cut pipes into the correct lengths.',
          'Improve your fraction skills and have fun playing this free math game online.',
        ],
        explanation:
            'Have fun learning about fractions with this interactive fraction game for kids! '
            'Enjoy challenging activities that will help kids understand how fractions work. '
            'Practice in the gallery and testing room, moving fractions into the right order and cutting pipes into the correct lengths. '
            'Improve your fraction skills and have fun playing this free math game online!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '🔢',
        color: 'F44336', // Red for math
      ),
      const WebGame(
        id: 'decimals',
        title: 'Decimals Game for Kids',
        description:
            'Move decimal frames in order from lowest to highest, change number sets and complete educational challenges to improve decimal skills.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/decimals.html',
        canvasSelector: null,
        topics: [
          'Decimals',
          'Numbers',
          'Ordering',
          'Number Sets',
          'Basic Math',
          'Math',
        ],
        learningGoals: [
          'Check out this free decimals game for kids and put your math skills to the test.',
          'Move the decimal frames so they are in order from the lowest to the highest.',
          'Change number sets and improve your decimal skills.',
          'Complete as many of the educational challenges as you can.',
          'Have fun learning about decimals with this interactive online math game for kids.',
        ],
        explanation:
            'Check out this free decimals game for kids and put your math skills to the test! '
            'Move the decimal frames so they are in order from the lowest to the highest, change number sets and improve your decimal skills. '
            'Complete as many of the educational challenges as you can and have fun learning about decimals with this interactive online math game for kids!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '🔟',
        color: '795548', // Brown for math
      ),
      const WebGame(
        id: 'number-patterns',
        title: 'Number Patterns Game',
        description:
            'Try unlocking the safe by dragging correct tiles into gaps, find rewards inside and move on to different challenges to crack the codes.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/numberpatterns.html',
        canvasSelector: null,
        topics: [
          'Number Patterns',
          'Patterns',
          'Problem Solving',
          'Logic',
          'Sequences',
          'Math',
        ],
        learningGoals: [
          'Check out this interactive number patterns game for kids and have fun trying to crack the code.',
          'Try unlocking the safe by dragging the correct tiles into the gaps.',
          'Find the rewards inside and move on to different challenges.',
          'Enjoy learning about number patterns with this cool educational activity for kids.',
          'Give it a try and see if you can crack the codes.',
        ],
        explanation:
            'Check out this interactive number patterns game for kids and have fun trying to crack the code! '
            'Try unlocking the safe by dragging the correct tiles into the gaps, find the rewards inside and move on to different challenges. '
            'Enjoy learning about number patterns with this cool educational activity for kids, give it a try and see if you can crack the codes!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '🔐',
        color: '607D8B', // Blue Grey for math
      ),
      const WebGame(
        id: 'place-values',
        title: 'Place Values Game for Kids',
        description:
            'Learn about place values with units like tens, hundreds and thousands, move digits into right positions to form correct numbers.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/placevalues.html',
        canvasSelector: null,
        topics: [
          'Place Values',
          'Tens',
          'Hundreds',
          'Thousands',
          'Number Positions',
          'Math',
        ],
        learningGoals: [
          'Learn about place values with this interactive game for kids.',
          'Improve your math skills and get comfortable with units such as tens, hundreds and thousands.',
          'Complete the challenges by moving digits into the right positions to form numbers that correctly answer the questions.',
          'See how the numbers change when multiplied and divided.',
          'Understand how place values work and have fun learning online.',
        ],
        explanation:
            'Learn about place values with this interactive game for kids! '
            'Improve your math skills and get comfortable with units such as tens, hundreds and thousands. '
            'Complete the challenges by moving digits into the right positions to form numbers that correctly answer the questions. '
            'See how the numbers change when multiplied and divided, understand how place values work and have fun learning online!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '🔢',
        color: '673AB7', // Deep Purple for math
      ),
      const WebGame(
        id: 'calculator',
        title: 'Calculator Game for Kids',
        description:
            'Learn how to use a calculator with functions like AC, memory recall, square root and percentage, complete calculations and have fun learning math.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/calculator.html',
        canvasSelector: null,
        topics: [
          'Calculator',
          'Calculator Functions',
          'All Clear (AC)',
          'Memory Recall (MR)',
          'Square Root',
          'Percentage',
          'Division',
          'Math',
        ],
        learningGoals: [
          'Learn how to use a calculator with this interactive math game for kids.',
          'Find out how you can use a calculator to make life easier when solving equations.',
          'Practice with calculator functions such as all clear (AC), memory recall (MR), square root, percentage and division.',
          'Complete the calculations and get familiar with the functions of a calculator.',
          'Have fun learning about math with this free online activity.',
        ],
        explanation:
            'Learn how to use a calculator with this interactive math game for kids! '
            'Find out how you can use a calculator to make life easier when solving equations. '
            'Practice with calculator functions such as all clear (AC), memory recall (MR), square root, percentage and division. '
            'Complete the calculations, get familiar with the functions of a calculator and have fun learning about math with this free online activity!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '🧮',
        color: '9C27B0', // Purple for math
      ),
      const WebGame(
        id: 'money-game',
        title: 'Money Game for Kids',
        description:
            'Learn about shopping with money, read shopping notes and purchase items while spending the least amount possible, drag correct money into the box.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/shoppingmoney.html',
        canvasSelector: null,
        topics: [
          'Money',
          'Shopping',
          'Counting Money',
          'Money Management',
          'Budgeting',
          'Math',
        ],
        learningGoals: [
          'Learn about shopping with money by playing this interactive game for kids.',
          'Complete a number of activities based around using money while shopping.',
          'Read the shopping note and purchase the items it suggests while remembering to spend the least amount of money possible.',
          'Choose the foods you want to buy and drag the correct amount of money into the green box.',
          'Enjoy this free math game for kids and have fun learning online.',
        ],
        explanation:
            'Learn about shopping with money by playing this interactive game for kids! '
            'Complete a number of activities based around using money while shopping. '
            'Read the shopping note and purchase the items it suggests while remembering to spend the least amount of money possible. '
            'Choose the foods you want to buy and drag the correct amount of money into the green box. '
            'Enjoy this free math game for kids and have fun learning online!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '💰',
        color: 'FF9800', // Orange for money/math
      ),
      const WebGame(
        id: 'problem-solving',
        title: 'Problem Solving Game for Kids',
        description:
            'Solve equations by dragging numbers onto the conveyor belt, watch them change through the transformation machine and work out which rule it used.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/problemsolving.html',
        canvasSelector: null,
        topics: [
          'Problem Solving',
          'Equations',
          'Number Patterns',
          'Transformation',
          'Logic',
          'Math',
        ],
        learningGoals: [
          'Check out this cool problem solving game for kids.',
          'Have fun improving your math skills while completing a range of interactive activities and challenges.',
          'Solve the equations by dragging numbers onto the conveyor belt and watching them change as they move through the special transformation machine.',
          'Watch closely to work out which rule the machine used to change the number.',
          'Give it a try and find out with this free online math game for kids.',
        ],
        explanation: 'Check out this cool problem solving game for kids! '
            'Have fun improving your math skills while completing a range of interactive activities and challenges. '
            'Solve the equations by dragging numbers onto the conveyor belt and watching them change as they move through the special transformation machine. '
            'Watch closely to work out which rule the machine used to change the number, can you solve the problems? '
            'Give it a try and find out with this free online math game for kids!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '🧩',
        color: 'E91E63', // Pink for problem solving/math
      ),
      const WebGame(
        id: 'probability',
        title: 'Probability Game for Kids',
        description:
            'Experiment with the random ball machine and see what results you get, learn about chances of getting red or blue balls and how probability works.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/probability.html',
        canvasSelector: null,
        topics: [
          'Probability',
          'Random Events',
          'Chances',
          'Statistics',
          'Data Analysis',
          'Math',
        ],
        learningGoals: [
          'Enjoy this interactive probability game for kids and have fun while improving your math skills.',
          'Experiment with the random ball machine and see what results you get.',
          'Learn what are the chances of getting a red ball and what about the blue balls?',
          'Learn how probability works and complete the educational challenges.',
          'Make the most of this free online math game for kids.',
        ],
        explanation:
            'Enjoy this interactive probability game for kids and have fun while improving your math skills! '
            'Experiment with the random ball machine and see what results you get, what are the chances of getting a red ball? '
            'What about the blue balls? Learn how probability works, complete the educational challenges and make the most of this free online math game for kids!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '🎲',
        color: '00BCD4', // Cyan for probability/math
      ),
      const WebGame(
        id: 'percentages',
        title: 'Percentages Game for Kids',
        description:
            'Plan a park using features like water, grass, flowers and playgrounds, follow instructions to include the right percentage of each feature.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/percentages.html',
        canvasSelector: null,
        topics: [
          'Percentages',
          'Planning',
          'Proportions',
          'Fractions',
          'Math',
        ],
        learningGoals: [
          'Enjoy this percentages game for kids and have fun improving your math skills.',
          'Plan a park using a range of different features such as water, grass, flowers, woodland and playgrounds.',
          'Follow the instructions and include the right percentage of each feature in the park.',
          'Complete the challenges and move on to more difficult activities.',
          'Have fun learning about percentages with this interactive game that children will enjoy.',
        ],
        explanation:
            'Enjoy this percentages game for kids and have fun improving your math skills! '
            'Your job is to plan a park using a range of different features such as water, grass, flowers, woodland and playgrounds. '
            'Follow the instructions and include the right percentage of each feature in the park. '
            'Complete the challenges, move on to more difficult activities and have fun learning about percentages with this interactive game that children will enjoy!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '🌳',
        color: '4CAF50', // Green for park/percentages/math
      ),
      const WebGame(
        id: 'mean-median-mode',
        title: 'Mean, Median & Mode Game',
        description:
            'Answer questions about a collection of buildings, put them in order, find the median and work out what height is the mode.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/meanmedianmode.html',
        canvasSelector: null,
        topics: [
          'Mean',
          'Median',
          'Mode',
          'Statistics',
          'Data Analysis',
          'Math',
        ],
        learningGoals: [
          'Enjoy this interactive math game for kids and learn more about the concepts of mean, median and mode.',
          'Answer a range of questions related to a collection of buildings.',
          'Put buildings in order and find the median.',
          'Work out what height is the mode.',
          'Complete the challenges and have fun improving your math skills with this free online math game.',
        ],
        explanation:
            'Enjoy this interactive math game for kids and learn more about the concepts of mean, median and mode! '
            'Answer a range of questions related to a collection of buildings, can you put them in order, find the median and work out what height is the mode? '
            'Give it a try and find out! Complete the challenges and have fun improving your math skills with this free online math game!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '📊',
        color: '2196F3', // Blue for statistics/math
      ),
      const WebGame(
        id: 'frequency-tables',
        title: 'Frequency Tables Game',
        description:
            'Take a survey of hobbies children enjoy, record data, tally results and make a frequency table to create a bar graph.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/math/frequencytables.html',
        canvasSelector: null,
        topics: [
          'Frequency Tables',
          'Charts',
          'Graphs',
          'Data Collection',
          'Statistics',
          'Math',
        ],
        learningGoals: [
          'Learn about frequency tables, charts, graphs and other math data with this fun math game for kids.',
          'Take a survey of what hobbies children enjoy, do they like reading, dancing, painting or football?',
          'Record the data and tally the results.',
          'Make a frequency table that can be used to create a bar graph.',
          'Analyze the data and enjoy learning about statistics with this cool math game for kids.',
        ],
        explanation:
            'Learn about frequency tables, charts, graphs and other math data with this fun math game for kids! '
            'The interactive activities involve taking a survey of what hobbies children enjoy, do they like reading, dancing, painting or football? '
            'Record the data, tally the results and make a frequency table that can be used to create a bar graph. '
            'Analyze the data and enjoy learning about statistics with this cool math game for kids!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'math',
        iconEmoji: '📈',
        color: '009688', // Teal for data/graphs/math
      ),
      const WebGame(
        id: 'map-routes-directions',
        title: 'Map Routes & Directions Game',
        description:
            'Practice following instructions, read carefully and give directions in correct order, plot shortest map routes between locations.',
        websiteUrl:
            'https://www.funenglishgames.com/readinggames/directions.html',
        canvasSelector: null,
        topics: [
          'Directions',
          'Map Reading',
          'Following Instructions',
          'Route Planning',
          'Reading Comprehension',
          'English',
        ],
        learningGoals: [
          'Check out this fun directions game and practice following instructions while completing a number of different challenges.',
          'Read the instructions carefully and give directions in the correct order.',
          'Plot the shortest possible map routes between locations such as a park, school, café, swimming pool and skate park.',
          'Achieve the goals by clicking on sections of road and using the quickest possible route on the interactive map of the town.',
          'Learn to follow instructions, complete as many tasks as you can and have fun with this great English activity for kids.',
        ],
        explanation: 'Check out this fun directions game! '
            'Practice following instructions while completing a number of different challenges. '
            'Read the instructions carefully and give directions in the correct order. '
            'Plot the shortest possible map routes between locations such as a park, school, café, swimming pool and skate park. '
            'Achieve the goals by clicking on sections of road and using the quickest possible route on the interactive map of the town. '
            'Learn to follow instructions, complete as many tasks as you can and have fun with this great English activity for kids!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '🗺️',
        color: 'FF5722', // Deep Orange for directions/english
      ),
      const WebGame(
        id: 'poetry-game',
        title: 'Poetry Game for Kids',
        description:
            'Read poetry verses and answer questions about mood and meaning, learn about metaphor, simile, alliteration, rhyme and more English terms.',
        websiteUrl: 'https://www.funenglishgames.com/readinggames/poem.html',
        canvasSelector: null,
        topics: [
          'Poetry',
          'Poems',
          'Metaphor',
          'Simile',
          'Alliteration',
          'Rhyme',
          'Adjective',
          'Conjunction',
          'Adverb',
          'Ellipsis',
          'Reading Comprehension',
          'English',
        ],
        learningGoals: [
          'Enjoy this fun poem game for kids.',
          'Read poetry verses before answering a range of related questions.',
          'Learn what is the mood of the poem and what are the verses describing.',
          'Press play and listen to the verses line by line.',
          'Learn about important English terms such as metaphor, simile, alliteration, rhyme, adjective, conjunction, adverb and ellipsis.',
          'Answer the questions, move on to the next verse, complete as many tasks as you can and have fun with this free poetry activity for kids.',
        ],
        explanation: 'Enjoy this fun poem game for kids! '
            'Read poetry verses before answering a range of related questions. '
            'What is the mood of the poem? What are the verses describing? '
            'Press play and listen to the verses line by line. '
            'Learn about important English terms such as metaphor, simile, alliteration, rhyme, adjective, conjunction, adverb and ellipsis. '
            'Answer the questions, move on to the next verse, complete as many tasks as you can and have fun with this free poetry activity for kids!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '📝',
        color: '9C27B0', // Purple for poetry/english
      ),
      const WebGame(
        id: 'non-fiction-game',
        title: 'Non Fiction Game for Kids',
        description:
            'Design layouts for children\'s books, news stories and toy catalogues, choose appropriate titles, text and pictures to inform, advertise or report.',
        websiteUrl:
            'https://www.funenglishgames.com/readinggames/nonfiction.html',
        canvasSelector: null,
        topics: [
          'Non Fiction',
          'Book Publishing',
          'Layout Design',
          'Writing Styles',
          'News Stories',
          'Children\'s Books',
          'Catalogue Pages',
          'Reading Skills',
          'English',
        ],
        learningGoals: [
          'Check out this non fiction book publishing game for kids.',
          'Choose between a children\'s book, news story and toy catalogue page before designing an appropriate layout.',
          'Think about what style of title, text and picture suits the chosen theme while remembering whether you are trying to inform, advertise or report.',
          'Challenge your reading skills, choose the best messages, complete the tasks and enjoy this fun English activity for kids.',
        ],
        explanation:
            'Check out this non fiction book publishing game for kids! '
            'Choose between a children\'s book, news story and toy catalogue page before designing an appropriate layout. '
            'Think about what style of title, text and picture suits the chosen theme while remembering whether you are trying to inform, advertise or report. '
            'Challenge your reading skills, choose the best messages, complete the tasks and enjoy this fun English activity for kids!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '📚',
        color: '795548', // Brown for books/english
      ),
      const WebGame(
        id: 'dictionary-game',
        title: 'Dictionary Game for Kids',
        description:
            'Use hints from the word machine to find correct words, look up the dictionary and identify which adjective, verb or noun best fits the clue.',
        websiteUrl:
            'https://www.funenglishgames.com/readinggames/dictionary.html',
        canvasSelector: null,
        topics: [
          'Dictionary',
          'Vocabulary',
          'Word Search',
          'Adjectives',
          'Verbs',
          'Nouns',
          'Reading Practice',
          'Alphabet',
          'English',
        ],
        learningGoals: [
          'Enjoy this fun dictionary game for kids.',
          'Use hints from the word machine to help you find the correct words to label the products hidden inside the boxes.',
          'Look up the dictionary and think about which adjective, verb or noun best fits the clue.',
          'Search through the alphabet for the best answer while reading the descriptions.',
          'Help the broken down word machine complete its job, test yourself with a variety of reading practice exercises and have fun with this great English activity for students.',
        ],
        explanation: 'Enjoy this fun dictionary game for kids! '
            'Use hints from the word machine to help you find the correct words to label the products hidden inside the boxes. '
            'Look up the dictionary and think about which adjective, verb or noun best fits the clue. '
            'Search through the alphabet for the best answer while reading the descriptions. '
            'Help the broken down word machine complete its job, test yourself with a variety of reading practice exercises and have fun with this great English activity for students!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '📖',
        color: '3F51B5', // Indigo for dictionary/english
      ),
      const WebGame(
        id: 'punctuation-game',
        title: 'Punctuation Games for Kids',
        description:
            'Complete grammar practice exercises to learn about full stops, question marks, commas, apostrophes, exclamation marks and inverted commas.',
        websiteUrl:
            'https://www.funenglishgames.com/grammargames/punctuation.html',
        canvasSelector: null,
        topics: [
          'Punctuation',
          'Grammar',
          'Full Stop',
          'Question Mark',
          'Comma',
          'Apostrophe',
          'Exclamation Mark',
          'Inverted Commas',
          'English',
        ],
        learningGoals: [
          'Check out this great punctuation game for kids.',
          'Have fun completing grammar practice exercises that help students learn about important English language punctuation such as the full stop, question mark, comma, apostrophe, exclamation mark and inverted commas.',
          'Read the sentences, aim the target and fire the correct punctuation where you think it should go in the sentence.',
          'Use the proper punctuation in the right location and you can move on to the next challenge, keep going and see if you can complete this interactive activity.',
        ],
        explanation: 'Check out this great punctuation game for kids! '
            'Have fun completing grammar practice exercises that help students learn about important English language punctuation such as the full stop, question mark, comma, apostrophe, exclamation mark and inverted commas. '
            'Read the sentences, aim the target and fire the correct punctuation where you think it should go in the sentence. '
            'Use the proper punctuation in the right location and you can move on to the next challenge, keep going and see if you can complete this interactive activity!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '✏️',
        color: 'E91E63', // Pink for punctuation/english
      ),
      const WebGame(
        id: 'conjunction-game',
        title: 'Conjunction Game for Kids',
        description:
            'Learn about sentence structure and the correct use of conjunctions like but, so, and, or, while, because, since, after, if and although.',
        websiteUrl:
            'https://www.funenglishgames.com/grammargames/conjunction.html',
        canvasSelector: null,
        topics: [
          'Conjunctions',
          'Joining Words',
          'Sentence Structure',
          'Compound Sentences',
          'Grammar',
          'But',
          'So',
          'And',
          'Or',
          'While',
          'Because',
          'Since',
          'After',
          'If',
          'Although',
          'English',
        ],
        learningGoals: [
          'Enjoy this great conjunction game for kids and have fun while learning more about sentence structure.',
          'The practice exercises involve understanding the correct use of conjunctions (joining words) such as but, so, and or, while, because, since, after, if and although.',
          'Complete each compound sentence by finding the right conjunction, read the sentences carefully, click the bubbles and find out if you were correct.',
          'This interactive English language activity offers perfect practice exercises for students.',
        ],
        explanation:
            'Enjoy this great conjunction game for kids and have fun while learning more about sentence structure! '
            'The practice exercises involve understanding the correct use of conjunctions (joining words) such as but, so, and or, while, because, since, after, if and although. '
            'Complete each compound sentence by finding the right conjunction, read the sentences carefully, click the bubbles and find out if you were correct. '
            'This interactive English language activity offers perfect practice exercises for students!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '🔗',
        color: '00BCD4', // Cyan for conjunctions/english
      ),
      const WebGame(
        id: 'prefix-suffix-game',
        title: 'Prefix & Suffix Game',
        description:
            'Learn how to add letters to the beginning or end of words to modify their meaning, add prefixes and suffixes and see if the result is a real word.',
        websiteUrl:
            'https://www.funenglishgames.com/grammargames/prefixsuffix.html',
        canvasSelector: null,
        topics: [
          'Prefixes',
          'Suffixes',
          'Word Formation',
          'Vocabulary',
          'Grammar',
          'Word Modification',
          'English',
        ],
        learningGoals: [
          'Check out this great prefix & suffix game for kids.',
          'Learn how to add letters to the beginning or end of a word to modify its meaning.',
          'Understand how prefixes and suffixes are used in the English language while enjoying fun challenges.',
          'Add prefixes and suffixes to words and see if the result is a real word.',
          'As the challenges become more difficult, try adding both a prefix and a suffix to make words.',
          'Complete as many challenges as you can and have fun learning about word formation!',
        ],
        explanation: 'Check out this great prefix & suffix game for kids! '
            'Learn how to add letters to the beginning or end of a word to modify its meaning. '
            'This excellent practice exercise activity will help students understand how prefixes and suffixes are used in the English language while they enjoy the fun challenges on offer. '
            'Add prefixes and suffixes to words and see if the result is a real word. '
            'As the challenges become more difficult, try adding both a prefix and a suffix to make words. '
            'How many challenges can you complete? Give it a go and find out!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '🔤',
        color: 'FF9800', // Orange for prefixes/suffixes/english
      ),
      const WebGame(
        id: 'verb-noun-adjective-game',
        title: 'Verb, Noun, Adjective Game',
        description:
            'Learn about different word types like verbs, nouns, adjectives, adverbs, pronouns, conjunctions, prepositions, articles, clauses and phrases.',
        websiteUrl:
            'https://www.funenglishgames.com/grammargames/verbnounadjective.html',
        canvasSelector: null,
        topics: [
          'Verbs',
          'Nouns',
          'Adjectives',
          'Adverbs',
          'Pronouns',
          'Conjunctions',
          'Prepositions',
          'Articles',
          'Clauses',
          'Phrases',
          'Word Types',
          'Grammar',
          'English',
        ],
        learningGoals: [
          'Learn about different word types such as the verb, noun and adjective with this fun game for kids.',
          'Complete a series of challenges related to nouns, verbs, adjectives, adverbs, pronouns, conjunctions, prepositions, articles, clauses and phrases.',
          'Find these types of words in sentences and understand when to use them properly.',
          'Use the interactive highlighter to choose the words you think best answer the questions.',
          'Complete as many challenges as you can and have fun learning English!',
        ],
        explanation:
            'Learn about different word types such as the verb, noun and adjective with this fun game for kids! '
            'This great online practice activity for students involves a series of challenges related to nouns, verbs, adjectives, adverbs, pronouns, conjunctions, prepositions, articles, clauses and phrases. '
            'Find these types of words in sentences and understand when to use them properly. '
            'Use the interactive highlighter to choose the words you think best answer the questions. '
            'Complete as many challenges as you can and have fun learning English!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '📝',
        color: '9C27B0', // Purple for word types/english
      ),
      const WebGame(
        id: 'debate-game',
        title: 'Debate Game for Kids',
        description:
            'Take part in interactive debates against opponents on interesting topics, listen to arguments, choose responses and try to win the judges\' votes.',
        websiteUrl: 'https://www.funenglishgames.com/writinggames/debate.html',
        canvasSelector: null,
        topics: [
          'Debate',
          'Arguments',
          'Persuasion',
          'Critical Thinking',
          'Public Speaking',
          'Discussion',
          'Opinions',
          'English',
        ],
        learningGoals: [
          'Enjoy this fun debate game for kids.',
          'Take part in an interactive debate against an opponent arguing from the opposite point of view on a range of interesting topics.',
          'Listen to what they have to say before choosing your response from a list of possible alternatives.',
          'The judges will then vote on who they thought had the best argument, try hard and see if you can get the crowd on your side and win the debate.',
          'Have fun learning about debating and arguments with this great online activity for students.',
        ],
        explanation: 'Enjoy this fun debate game for kids! '
            'Take part in an interactive debate against an opponent arguing from the opposite point of view on a range of interesting topics. '
            'Listen to what they have to say before choosing your response from a list of possible alternatives. '
            'The judges will then vote on who they thought had the best argument, try hard and see if you can get the crowd on your side and win the debate. '
            'Have fun learning about debating and arguments with this great online activity for students!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 20,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '💬',
        color: 'E91E63', // Pink for debate/english
      ),
      const WebGame(
        id: 'newspaper-game',
        title: 'Newspaper Game for Kids',
        description:
            'Practice headline writing with interactive challenges, learn how good news headlines and comments should be written and select the best comments for headlines.',
        websiteUrl:
            'https://www.funenglishgames.com/writinggames/newspaper.html',
        canvasSelector: null,
        topics: [
          'Newspaper',
          'Headlines',
          'Journalism',
          'Writing',
          'News Writing',
          'Headline Writing',
          'Comments',
          'English',
        ],
        learningGoals: [
          'Check out this fun newspaper game for kids.',
          'Practice your headline writing with a series of interactive challenges designed to help students understand how good news headlines and comments should be written.',
          'Take a look at the examples and select the comment that best answers questions relating to various newspaper headlines.',
          'Learn why newspaper headlines should be short, informative and to the point.',
          'Enjoy learning online with this cool journalism activity that\'s perfect for children.',
        ],
        explanation: 'Check out this fun newspaper game for kids! '
            'Practice your headline writing with a series of interactive challenges designed to help students understand how good news headlines and comments should be written. '
            'Take a look at the examples and select the comment that best answers questions relating to various newspaper headlines. '
            'Learn why newspaper headlines should be short, informative and to the point. '
            'Enjoy learning online with this cool journalism activity that\'s perfect for children!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '📰',
        color: '424242', // Dark Gray for newspaper/journalism/english
      ),
      const WebGame(
        id: 'advertising-game',
        title: 'Advertising Game',
        description:
            'Create attractive brochures and leaflets, design advertising campaigns with effective titles, pictures and words to capture readers\' attention.',
        websiteUrl:
            'https://www.funenglishgames.com/writinggames/advertising.html',
        canvasSelector: null,
        topics: [
          'Advertising',
          'Brochures',
          'Leaflets',
          'Design',
          'Marketing',
          'Writing',
          'Persuasion',
          'English',
        ],
        learningGoals: [
          'Enjoy this great advertising game and learn how to successfully create attractive and informative brochures and leaflets that will capture the attention of readers.',
          'Design a range of advertising campaigns that include a birthday invitation, café brochure and a leaflet aimed at keeping playgrounds clean.',
          'Use effective titles, pictures and words to make your leaflets and brochures.',
          'Create titles that are short, sharp and memorable. Choose bright, attractive, clear pictures that will grab attention and don\'t forget to include all the essential information in the text.',
          'Attract customers with unique advertising campaigns and have fun with this online design activity for kids.',
        ],
        explanation:
            'Enjoy this great advertising game and learn how to successfully create attractive and informative brochures and leaflets that will capture the attention of readers! '
            'Design a range of advertising campaigns that include a birthday invitation, café brochure and a leaflet aimed at keeping playgrounds clean. '
            'Use effective titles, pictures and words to make your leaflets and brochures. '
            'Create titles that are short, sharp and memorable. Choose bright, attractive, clear pictures that will grab attention and don\'t forget to include all the essential information in the text. '
            'Attract customers with unique advertising campaigns and have fun with this online design activity for kids!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 20,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '📢',
        color: 'FF5722', // Deep Orange for advertising/english
      ),
      const WebGame(
        id: 'letter-writing-game',
        title: 'Learn How to Write a Letter',
        description:
            'Learn how to write concise, well worded letters that are set out correctly, discover where to write your name, address, date and how to layout paragraphs.',
        websiteUrl: 'https://www.funenglishgames.com/writinggames/letters.html',
        canvasSelector: null,
        topics: [
          'Letter Writing',
          'Writing',
          'Formal Writing',
          'Letter Format',
          'Paragraphs',
          'Address',
          'Date',
          'English',
        ],
        learningGoals: [
          'Check out this great letter writing practice activity for kids.',
          'Learn how to write concise, well worded letters that are set out correctly.',
          'Discover where in the letter you should write your name and address.',
          'Learn how you should layout paragraphs and where the date should go.',
          'Find out the answers to these questions and more while enjoying this interactive activity that\'s perfect for students.',
        ],
        explanation:
            'Check out this great letter writing practice activity for kids! '
            'Learn how to write concise, well worded letters that are set out correctly. '
            'Where in the letter should you write your name and address? How should you layout paragraphs? Where does the date go? '
            'Find out the answer to these questions and more. '
            'Learn how to write a letter while you enjoy this interactive activity that\'s perfect for students!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '✉️',
        color: '2196F3', // Blue for letter writing/english
      ),
      const WebGame(
        id: 'story-writing-game',
        title: 'Story Writing Game for Kids',
        description:
            'Learn how to create the right atmosphere when planning stories, use correct words for ghost stories, spy stories or romance and choose your theme.',
        websiteUrl: 'https://www.funenglishgames.com/writinggames/story.html',
        canvasSelector: null,
        topics: [
          'Story Writing',
          'Creative Writing',
          'Atmosphere',
          'Ghost Stories',
          'Spy Stories',
          'Romance',
          'Story Planning',
          'Writing',
          'English',
        ],
        learningGoals: [
          'This great story writing game for kids will help teach children how to create the right atmosphere when planning stories based around a chosen topic.',
          'Use the correct words to create an atmosphere suitable for a ghost story, spy story or romance.',
          'Discover what words help create a spooky atmosphere and how about a spy thriller?',
          'Choose your theme and use the tips provided to help write your sentences.',
          'Enjoy learning how to write stories with the help of this fun, interactive activity that\'s perfect for students.',
        ],
        explanation:
            'This great story writing game for kids will help teach children how to create the right atmosphere when planning stories based around a chosen topic! '
            'Use the correct words to create an atmosphere suitable for a ghost story, spy story or romance. '
            'What words help create a spooky atmosphere? How about a spy thriller? '
            'Choose your theme and use the tips provided to help write your sentences. '
            'Enjoy learning how to write stories with the help of this fun, interactive activity that\'s perfect for students!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 20,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '📖',
        color: '9C27B0', // Purple for story writing/english
      ),
      const WebGame(
        id: 'instructions-game',
        title: 'Instructions Game for Kids',
        description:
            'Write clear, concise step-by-step instructions for activities like making a sandwich, putting up a tent and making a robot from a beginner\'s perspective.',
        websiteUrl:
            'https://www.funenglishgames.com/writinggames/instructions.html',
        canvasSelector: null,
        topics: [
          'Instructions',
          'Writing',
          'Step by Step',
          'Clear Writing',
          'Procedural Writing',
          'How To',
          'English',
        ],
        learningGoals: [
          'This instructions game for kids will help students understand the importance of writing clear, concise instructions for a range of interesting tasks.',
          'Choose from a list of different activities such as making a sandwich, putting up a tent and making a robot.',
          'Write step by step instructions in English for how it should be performed from the perspective of someone who has never done it before.',
          'It sounds easy but it\'s not quite as simple as you might think. Can you complete all the challenges?',
          'Give it a go and find out with this fun, interactive online activity for kids.',
        ],
        explanation:
            'This instructions game for kids will help students understand the importance of writing clear, concise instructions for a range of interesting tasks! '
            'Choose from a list of different activities such as making a sandwich, putting up a tent and making a robot. '
            'Write step by step instructions in English for how it should be performed from the perspective of someone who has never done it before. '
            'It sounds easy but it\'s not quite as simple as you might think. Can you complete all the challenges? '
            'Give it a go and find out with this fun, interactive online activity for kids!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 20,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '📋',
        color: '607D8B', // Blue Grey for instructions/english
      ),
      const WebGame(
        id: 'crossword-game',
        title: 'Fun Crossword Game for Kids',
        description:
            'Complete puzzles by filling in correct missing letters, click on empty spaces and select letters that appear throughout the crossword giving useful hints.',
        websiteUrl: 'https://www.funenglishgames.com/wordgames/crossword.html',
        canvasSelector: null,
        topics: [
          'Crossword',
          'Puzzles',
          'Vocabulary',
          'Word Recognition',
          'Spelling',
          'Problem Solving',
          'English',
        ],
        learningGoals: [
          'Check out this fun crossword game for kids.',
          'Complete the puzzle by filling in the correct missing letters.',
          'Click on an empty space in the crossword and select a letter you think might go there, the letter will then appear throughout the crossword in highlighted boxes, giving you useful hints on other words in the crossword.',
          'If you choose the wrong letter, other parts of the puzzle won\'t make sense, so be careful.',
          'Finishing the crossword will raise the difficulty from beginner to easy and onwards to normal, hard and expert. If you\'re stuck for ideas then simply choose \'give up\' and try a new crossword.',
          'This free online puzzle activity offers a great challenge for students.',
        ],
        explanation: 'Check out this fun crossword game for kids! '
            'Complete the puzzle by filling in the correct missing letters. '
            'Click on an empty space in the crossword and select a letter you think might go there, the letter will then appear throughout the crossword in highlighted boxes, giving you useful hints on other words in the crossword. '
            'If you choose the wrong letter, other parts of the puzzle won\'t make sense, so be careful. '
            'Finishing the crossword will raise the difficulty from beginner to easy and onwards to normal, hard and expert. '
            'If you\'re stuck for ideas then simply choose \'give up\' and try a new crossword. '
            'This free online puzzle activity offers a great challenge for students!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '🧩',
        color: 'FF9800', // Orange for crossword/english
      ),
      const WebGame(
        id: 'letter-matching-game',
        title: 'Letter Matching Game for Kids',
        description:
            'Test problem solving skills while improving recognition of the English alphabet, match letters in rows or columns to eliminate them from the grid.',
        websiteUrl:
            'https://www.funenglishgames.com/wordgames/lettermatching.html',
        canvasSelector: null,
        topics: [
          'Letter Matching',
          'Alphabet',
          'Problem Solving',
          'Puzzles',
          'Letter Recognition',
          'Strategy',
          'English',
        ],
        learningGoals: [
          'This fun letter game for kids tests your problem solving skills while helping improve your recognition of the English alphabet.',
          'Match letters together in either rows or columns to eliminate them from the grid.',
          'How far can you progress through the puzzle? Can you clear the grid?',
          'Letters drop into new positions as you solve the puzzle, enabling an element of strategy to help you on your way.',
          'This free letter matching puzzle is perfect for students and anyone interested in interactive English activities online.',
        ],
        explanation:
            'This fun letter game for kids tests your problem solving skills while helping improve your recognition of the English alphabet! '
            'Match letters together in either rows or columns to eliminate them from the grid. '
            'How far can you progress through the puzzle? Can you clear the grid? '
            'Letters drop into new positions as you solve the puzzle, enabling an element of strategy to help you on your way. '
            'This free letter matching puzzle is perfect for students and anyone interested in interactive English activities online!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '🔤',
        color: '00BCD4', // Cyan for letter matching/english
      ),
      const WebGame(
        id: 'spiderman-spelling-game',
        title: 'Spiderman Spelling Game',
        description:
            'Help Spiderman save the day by using his web of words to climb buildings, form words from letters and advance through fun stages to keep the city safe.',
        websiteUrl: 'https://calendar.google.com/calendar/u/0/r/month/2025/9/1',
        canvasSelector: null,
        topics: [
          'Spelling',
          'Word Formation',
          'Vocabulary',
          'Puzzles',
          'Word Games',
          'English',
        ],
        learningGoals: [
          'Help Spiderman save the day with this great spelling game for kids.',
          'Use Spiderman\'s web of words to climb buildings and keep the city safe from Doc Ock.',
          'Use letters to form as many different words as you can, advancing onwards through a variety of fun stages.',
          'This free word puzzle game will help students develop their English ability while entertaining them at the same time.',
          'Enjoy the challenge of this interactive activity and have fun learning online!',
        ],
        explanation:
            'Help Spiderman save the day with this great spelling game for kids! '
            'Use Spiderman\'s web of words to climb buildings and keep the city safe from Doc Ock. '
            'Use letters to form as many different words as you can, advancing onwards through a variety of fun stages. '
            'This free word puzzle game will help students develop their English ability while entertaining them at the same time. '
            'Enjoy the challenge of this interactive activity and have fun learning online!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '🕷️',
        color: 'D32F2F', // Red for Spiderman/spelling/english
      ),
      const WebGame(
        id: 'alphabet-game',
        title: 'Alphabet Game for Kids',
        description:
            'Quickly rearrange letters into words as they fall into the alphabet soup bowl, create more words before time runs out to score higher and earn bonuses.',
        websiteUrl:
            'https://www.funenglishgames.com/spellinggames/alphabet.html',
        canvasSelector: null,
        topics: [
          'Alphabet',
          'Spelling',
          'Word Formation',
          'Vocabulary',
          'Puzzles',
          'Time Management',
          'English',
        ],
        learningGoals: [
          'Check out this great alphabet game for kids.',
          'Quickly rearrange letters into words as they fall into the alphabet soup bowl.',
          'The more words you create before the time runs out, the higher your score.',
          'Solve the puzzles fast and earn a bonus.',
          'How many puzzles can you solve? Give this free word spelling activity a try and find out. Beat your high score and have fun learning English online.',
        ],
        explanation: 'Check out this great alphabet game for kids! '
            'Quickly rearrange letters into words as they fall into the alphabet soup bowl. '
            'The more words you create before the time runs out, the higher your score. '
            'Solve the puzzles fast and earn a bonus. '
            'How many puzzles can you solve? Give this free word spelling activity a try and find out. Beat your high score and have fun learning English online!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '🔤',
        color: '4CAF50', // Green for alphabet/spelling/english
      ),
      const WebGame(
        id: 'easy-spelling-game',
        title: 'Easy Spelling Game for Kids',
        description:
            'Learn to spell with this easy word puzzle game, combine letters to form different words and use provided pictures to help narrow down the options.',
        websiteUrl:
            'https://www.funenglishgames.com/spellinggames/learntospell.html',
        canvasSelector: null,
        topics: [
          'Spelling',
          'Word Formation',
          'Vocabulary',
          'Puzzles',
          'Letter Combination',
          'English',
        ],
        learningGoals: [
          'Learn to spell with this easy word puzzle game for kids.',
          'Combine letters to form a range of different words, how many can you get correct?',
          'Use the provided pictures to help narrow down the options and make the questions easier.',
          'This fun online activity will help improve student\'s spelling ability in a fun, interactive way.',
          'Get started and improve your English today!',
        ],
        explanation: 'Learn to spell with this easy word puzzle game for kids! '
            'Combine letters to form a range of different words, how many can you get correct? '
            'Use the provided pictures to help narrow down the options and make the questions easier. '
            'This fun online activity will help improve student\'s spelling ability in a fun, interactive way. '
            'Get started and improve your English today!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '✏️',
        color: '2196F3', // Blue for spelling/english
      ),
      const WebGame(
        id: 'word-guessing-puzzle-game',
        title: 'Word Guessing Puzzle Game',
        description:
            'Check out this classic word guessing puzzle game, enjoy the challenge of solving the word in just five guesses by inputting words and following clues.',
        websiteUrl:
            'https://www.funenglishgames.com/spellinggames/guessing.html',
        canvasSelector: null,
        topics: [
          'Word Guessing',
          'Puzzles',
          'Spelling',
          'Vocabulary',
          'Problem Solving',
          'Logic',
          'English',
        ],
        learningGoals: [
          'Check out this classic word guessing puzzle game for kids and enjoy the challenge of solving the word in just five guesses.',
          'Input a word, follow the clues and solve the puzzle as quick as you can.',
          'Even correct letters in the wrong location are handy, move them to a new place and see if that helps you narrow down the possibilities.',
          'This free online English activity is perfect for students looking to improve their language skills in a fun, interactive way.',
        ],
        explanation:
            'Check out this classic word guessing puzzle game for kids and enjoy the challenge of solving the word in just five guesses! '
            'Input a word, follow the clues and solve the puzzle as quick as you can. '
            'Even correct letters in the wrong location are handy, move them to a new place and see if that helps you narrow down the possibilities. '
            'This free online English activity is perfect for students looking to improve their language skills in a fun, interactive way!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Medium',
        ageGroup: 'junior',
        subject: 'english',
        iconEmoji: '🧩',
        color: '9C27B0', // Purple for puzzles/english
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
