import std.stdio,
	std.algorithm,
	std.conv,
	std.exception,
	std.getopt,
	std.range,
	std.string;

void main(string[] args)
{
	bool quit = false;
	args.getopt(
		std.getopt.config.passThrough,
		"help|h", { writeln(HelpText); quit = true; }
	);

	if (quit) return;

    void process(Input)(Input input)
	{
		input.map!strip
			.map!invert
			.map!(l => l ~ "\n")
			.copy(stdout.lockingTextWriter());
	}

	foreach (arg; args[1..$])
	{
		if (arg == "-")
			process(stdin.byLine.map!(to!string));
		else
			process([arg]);
	}

}

// If subj is a hash, turn it into words, 
//    otherwise assume it's words and turn it into a hash
string invert(string subj)
{
	if (subj.isHash)
		return subj.toWords;
	else
		return subj.toHash;
}

bool isHash(string subj)
{
	import std.ascii;
	return subj.all!isHexDigit && subj.length >= 6;
}

string toWords(string hash)
in { assert(hash.length >= 6); }
body {
	int im = hash[0 .. 6].to!int(16 /* radix */);
	return "%s %s %s".format(
						words[0][(im & 0x00FF0000) >> 16].capitalize,
						words[1][(im & 0x0000FF00) >> 8].capitalize,
						words[2][im & 0x000000FF].capitalize
					);
}

string toHash(string wordstring)
{
	auto w = wordstring.split();
	enforce(w.length == 3, "Expected 3 words, not "~wordstring);

	ubyte[3] im;
	foreach (i, word; w)
	{
		auto idx = words[i].countUntil(word.toLower);
		enforce(idx >= 0, "Word not found: '"~word~"'");
		im[i] = cast(ubyte)idx;
	}
	return "%(%.2x%)".format(im);
}

// HERE ENDETH THE SOURCE CODE PROPER AND BEGINNETH THE RESOURCES

enum HelpText = 
`aghast: the human-friendly hash translator
 
USAGE
   Aghast translates unpronounceable hashes into friendly names and vice-versa.
For example, we can invoke aghast with some hashes we got from git:

   $ aghast 9f23a18123901 a2ce23
    Cluttered Essential Stingray
    Colorful Ill Cockroach

   Note that Aghast only bothers with the first six characters of the hash, thus
these produce the same results:
   $ aghast 9f23a18123901 9f23a1812 9f23a1
    Cluttered Essential Stingray
    Cluttered Essential Stingray
    Cluttered Essential Stingray

   Aghast can also go the other way, translating the human-friendly names back into
hashes:
   $ aghast 'Cluttered Essential Stingray' 'Colorful Ill Cockroach'
    9f23a1
    a2ce23 

   Be sure to surround those names in quotes when on the command line!  Aghast will
also gladly read from STDIN for you if '-' is supplied as an argument:

   $ echo '9f23a1' | ./aghast -
    Cluttered Essential Stingray

ABOUT
   Written by Justin Whear <justin@economicmodeling.com>`;

enum words = [
	// List 1: adjectives
	[
"abandoned", "able", "absolute", "adorable", "adventurous", "academic",
"acceptable", "acclaimed", "accomplished", "accurate", "aching", "acidic",
"acrobatic", "active", "actual", "adept", "admirable", "admired", "adolescent",
"adorable", "advanced", "afraid", "affectionate", "aged", "aggravating",
"aggressive", "agile", "agitated", "agonizing", "agreeable", "ajar", "alarmed",
"alert", "alienated", "alive", "all", "altruistic", "amazing", "ambitious",
"ample", "amusing", "anchored", "ancient", "angelic", "angry", "anguished",
"animated", "annual", "another", "antique", "anxious", "apprehensive",
"appropriate", "apt", "arctic", "arid", "aromatic", "artistic", "ashamed",
"assured", "astonishing", "athletic", "attached", "attentive", "attractive",
"austere", "authentic", "authorized", "automatic", "avaricious", "average",
"aware", "awesome", "awful", "awkward", "babyish", "bad", "back", "baggy",
"bare", "barren", "basic", "beautiful", "belated", "beloved", "beneficial",
"better", "best", "bewitched", "big", "biodegradable", "bitter", "black",
"bland", "blank", "blaring", "bleak", "blind", "blissful", "blond", "blue",
"blushing", "bogus", "boiling", "bold", "bony", "boring", "bossy", "bouncy",
"bountiful", "bowed", "brave", "breakable", "brief", "bright", "brilliant",
"brisk", "broken", "bronze", "brown", "bruised", "bubbly", "bulky", "bumpy",
"buoyant", "burdensome", "burly", "bustling", "busy", "buttery", "buzzing",
"calculating", "calm", "candid", "canine", "capital", "carefree", "careful",
"careless", "caring", "cautious", "cavernous", "celebrated", "charming",
"cheap", "cheerful", "cheery", "chief", "chilly", "chubby", "circular",
"classic", "clean", "clear", "clever", "closed", "cloudy", "clueless", "clumsy",
"cluttered", "coarse", "cold", "colorful", "colossal", "comfortable", "common",
"compassionate", "competent", "complete", "complex", "complicated", "composed",
"concerned", "concrete", "confused", "conscious", "considerate", "constant",
"content", "conventional", "cooked", "cool", "cooperative", "coordinated",
"corny", "corrupt", "costly", "courageous", "courteous", "crafty", "crazy",
"creamy", "creative", "creepy", "criminal", "crisp", "critical", "crooked",
"crowded", "cruel", "crushing", "cuddly", "cultivated", "cultured",
"cumbersome", "curly", "curvy", "cute", "cylindrical", "damaged", "damp",
"dangerous", "dapper", "daring", "darling", "dark", "dazzling", "dead",
"deadly", "deafening", "decent", "decisive", "deep", "defensive", "defiant",
"deficient", "delayed", "delectable", "delicious", "delightful", "delirious",
"demanding", "dense", "dependable", "deserted", "detailed", "determined",
"devoted", "different", "difficult", "digital", "diligent", "dimpled",
"dimwitted", "direct", "disastrous", "disfigured", "disgusting", "disloyal",
"dismal", "distant", "dreary", "dirty", "disguised", "dishonest", "large",
	],

	// List 2: more adjectives
	[
"distant", "dizzy", "dopey", "doting", "drab", "drafty", "dramatic", "dreary",
"droopy", "dry", "dull", "eager", "earnest", "early", "easy", "ecstatic",
"edible", "educated", "elaborate", "elastic", "elated", "elderly", "electric",
"elegant", "embarrassed", "eminent", "emotional", "enchanted", "enchanting",
"energetic", "enlightened", "enormous", "enraged", "entire", "envious",
"essential", "esteemed", "ethical", "everlasting", "evil", "exalted",
"excellent", "exemplary", "exhausted", "excited", "exotic", "expensive",
"expert", "extroverted", "fabulous", "faint", "fair", "faithful", "fake",
"famous", "fancy", "fantastic", "faraway", "fast", "fat", "fatal", "fatherly",
"fearful", "fearless", "feisty", "feline", "female", "feminine", "fickle",
"filthy", "finished", "firm", "firsthand", "fixed", "flaky", "flamboyant",
"flashy", "flawed", "flawless", "flickering", "flimsy", "flippant", "flowery",
"fluffy", "fluid", "flustered", "focused", "fond", "foolhardy", "foolish",
"forceful", "forked", "formal", "forsaken", "forthright", "fortunate",
"fragrant", "frail", "frank", "frayed", "free", "fresh", "frequent", "friendly",
"frightened", "frigid", "frilly", "frizzy", "frosty", "frozen", "frugal",
"fruitful", "full", "fumbling", "functional", "funny", "fussy", "fuzzy",
"generous", "gentle", "genuine", "giant", "giddy", "gigantic", "gifted",
"giving", "glamorous", "glaring", "gleaming", "gleeful", "gloomy", "glorious",
"glossy", "glum", "golden", "good", "gorgeous", "graceful", "gracious", "grand",
"grandiose", "grateful", "grave", "gray", "great", "greedy", "green",
"gregarious", "grim", "grimy", "grizzled", "gross", "grouchy", "grounded",
"growing", "growling", "grubby", "gruesome", "grumpy", "guilty", "gullible",
"gummy", "hairy", "handmade", "handsome", "handy", "happy", "hard", "harmless",
"harsh", "hasty", "hateful", "haunting", "healthy", "heartfelt", "hearty",
"heavenly", "heavy", "hefty", "helpful", "helpless", "hidden", "hideous",
"high", "hilarious", "hoarse", "hollow", "homely", "honest", "honorable",
"hopeful", "horrible", "hospitable", "hot", "huge", "humble", "humming",
"hungry", "hurtful", "icky", "icy", "ideal", "idle", "idiotic", "idolized",
"ignorant", "ill", "illegal", "illiterate", "illustrious", "imaginary",
"immaculate", "immaterial", "immediate", "immense", "impassioned", "impeccable",
"impartial", "imperfect", "impish", "impolite", "important", "impossible",
"impractical", "impressive", "improbable", "impure", "incomplete", "incredible",
"indelible", "indolent", "infamous", "infantile", "inferior", "infinite",
"informal", "innocent", "insecure", "insidious", "insistent", "instructive",
"intelligent", "intent", "intentional", "internal", "international", "intrepid",
"irritating", "itchy", "jaded", "jagged", "jaunty", "jealous", "jittery",
"jolly", "joyful"
	],

	// List 3: nouns
	[
"aardvark", "albatross", "alligator", "alpaca", "ant", "anteater", "antelope",
"ape", "armadillo", "baboon", "badger", "barracuda", "bat", "bear", "beaver",
"bee", "bison", "boar", "also", "buffalo", "galago", "butterfly", "camel",
"caribou", "cat", "caterpillar", "cattle", "cow", "cheetah", "chicken",
"chimpanzee", "chinchilla", "chough", "clam", "cobra", "cockroach", "cod",
"coyote", "crab", "crane", "crocodile", "crow", "deer", "dinosaur", "dog",
"dogfish", "dolphin", "donkey", "dove", "dragonfly", "duck", "dugong",
"eagle", "echidna", "eel", "elephant", "elk", "emu", "falcon", "ferret",
"finch", "fish", "flamingo", "fly", "fox", "frog", "gazelle", "gerbil",
"giraffe", "gnat", "gnu", "goat", "goose", "goldfish", "gorilla",
"grasshopper", "grouse", "gull", "hamster", "hawk", "hedgehog", "heron",
"herring", "hornet", "horse", "hummingbird", "hyena", "jackal", "jaguar",
"jay", "jellyfish", "kangaroo", "koala", "komodo", "lapwing", "ladybug",
"lark", "lemur", "leopard", "lion", "llama", "lobster", "locust", "louse",
"magpie", "mallard", "manatee", "meerkat", "mink", "mole", "monkey", "moose",
"mouse", "mosquito", "mule", "narwhal", "newt", "octopus", "opossum",
"ostrich", "otter", "owl", "ox", "oyster", "panther", "parrot", "partridge",
"peafowl", "pelican", "penguin", "pig", "pigeon", "pony", "porcupine",
"porpoise", "quail", "rabbit", "raccoon", "ram", "rat", "raven", "reindeer",
"rook", "salamander", "salmon", "sandpiper", "sardine", "scorpion", "seahorse",
"seal", "shark", "sheep", "shrew", "shrimp", "skunk", "snail", "snake",
"spider", "squid", "squirrel", "starling", "stingray", "stinkbug", "stork",
"swallow", "swan", "tapir", "termite", "tiger", "toad", "trout", "turkey",
"turtle", "viper", "vulture", "wallaby", "walrus", "wasp", "weasel", "whale",
"wolf", "wombat", "woodpecker", "worm", "wren", "yak", "zebra", "airplane",
"alarm", "alien", "argument", "astronaut", "baseball", "boat", "book", "camera",
"canvas", "chair", "clover", "club", "dirigible", "dollar", "dongle", "dwarf",
"editor", "elf", "engineer", "ent", "finger", "fire", "ferrari", "halfling",
"halo", "hammer", "gnome", "grass", "gumdrop", "icicle", "insect", "jamboree",
"judge", "keyboard", "lake", "lamp", "lawyer", "mask", "minefield", "monocle",
"mug", "nerd", "opponent", "peanut", "piano", "pipe", "poet", "pragmatist",
"punchbowl", "rifle", "road", "rocket", "saxophone", "scooter", "scout",
"siren", "slipper", "starship", "teacher", "teapot", "trombone", "truck",
"umbrella", "unicorn", "velocipede", "wallpaper", "wizard", "wrench"
	]
];
static assert(words[0].length == 256);
static assert(words[1].length == 256);
static assert(words[2].length == 256);
