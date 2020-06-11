import std.stdio,
    std.algorithm,
    std.conv,
    std.exception,
    std.getopt,
    std.range,
    std.string;

void main(string[] args)
{
    size_t maxCharsToUse = 7;
    bool quit = false;
    args.getopt(
        std.getopt.config.passThrough,
        "help|h", { writeln(HelpText); quit = true; },
        "v1", { maxCharsToUse = 6; },
        "v2", { maxCharsToUse = 7; },
    );

    if (quit) return;

    void process(Input)(Input input)
    {
        input.map!strip
            .map!(s => invert(s, maxCharsToUse))
            .joiner("\n")
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
string invert(string subj, size_t maxCharsToUse)
{
    if (subj.isHash)
        return subj.toWords(maxCharsToUse);
    else
        return subj.toHash;
}

bool isHash(string subj)
{
    import std.ascii;
    return subj.all!isHexDigit && subj.length >= 6;
}

string toWords(string hash, size_t maxCharsToUse)
in { assert(hash.length >= 6); }
body {
    int im = hash[0 .. 6].to!int(16 /* radix */);

    int[3] varietyPage = [0, 0, 0];
    if (maxCharsToUse == 7 && hash.length >= 7)
    {
        // We currently have only two pages for each position so the page value
        // must be either 0 or 1
        const variety = to!int(hash[6..7], 16);
        varietyPage[0] = (variety & 0b0000_0001) >> 0;
        varietyPage[1] = (variety & 0b0000_0010) >> 1;
        varietyPage[2] = (variety & 0b0000_0100) >> 2;
    }
    varietyPage[] *= 256;
    return "%s %s %s".format(
        words[0][((im & 0x00FF0000) >> 16) + varietyPage[0]].capitalize,
        words[1][((im & 0x0000FF00) >>  8) + varietyPage[1]].capitalize,
        words[2][((im & 0x000000FF) >>  0) + varietyPage[2]].capitalize
      );
}

string toHash(string wordstring)
{
    auto w = wordstring.split();
    enforce(w.length == 3, "Expected 3 words, not "~wordstring);

    ubyte[3] im;
    foreach (i, word; w)
    {
        const idx = words[i].countUntil(word.toLower);
        enforce(idx >= 0, "Word not found: '"~word~"'");
        im[i] = cast(ubyte)(idx % 256);
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

   Note that Aghast only bothers with the first seven characters of the hash, thus
these produce the same results:
   $ aghast 9f23a18123901 9f23a1812 9f23a18
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

   $ git log --format='%h' | ./aghast -
    Magenta Important Slipper
    Married Voiceless Skunk
    Corpulent Fruitful Dongle
    Nebulous Tall Wrench
    Defensive Stout Mouse
    Competent Fatherly Eviction
    Last Dull Pirate
    Painstaking Unruly Duck
    Comfortable Fat Halo
    Pungent Solid Pilot
    Agile Unsuitable Trout

OPTIONS
   --v1      Revert to version 1 behavior
   --v2      Use version 2 behavior (default)
   --help    Show this help

VERSIONS
   Version 2: doubles the number of words in each position.  To provide variety the
    first seven characters of the hash are now considered.  The '--v1' flag can be
    provided to make Aghast revert to the Version 1 behavior and provide backwards
    compatibility.  Providing only six characters of the hash also produces the same
    output as Version 1 (almost, see BUGS below).

BUGS
   Version 1 contained a bug where the word "adorable" in the first position could
    be mapped from two different bytes, thus reconstructing the original hash
    had a 50/50 chance of success.  This has been corrected in Version 2 with the
    substitution of "adopted" for the second "adorable".

ABOUT
   Written by Justin Whear <justin@economicmodeling.com>`;

enum words = [
    // List 1: adjectives
    [
// page 1,
"abandoned", "able", "absolute", "adorable", "adventurous", "academic",
"acceptable", "acclaimed", "accomplished", "accurate", "aching", "acidic",
"acrobatic", "active", "actual", "adept", "admirable", "admired", "adolescent",
"adopted", "advanced", "afraid", "affectionate", "aged", "aggravating",
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
"crowded", "cruddy", "cruel", "crushing", "cuddly", "cultivated", "cultured",
"cumbersome", "curly", "curvy", "cute", "cylindrical", "damaged", "damp",
"dangerous", "dapper", "daring", "darling", "dark", "dazzling", "dead",
"deadly", "deafening", "decent", "decisive", "deep", "defensive", "defiant",
"deficient", "delayed", "delectable", "delicious", "delightful", "delirious",
"demanding", "dense", "dependable", "deserted", "detailed", "determined",
"devoted", "different", "difficult", "digital", "diligent", "dimpled",
"dimwitted", "direct", "disastrous", "disfigured", "disgusting", "disloyal",
"dismal", "distant", "dreary", "dirty", "disguised", "dishonest", "large",

// page 2
"adamant", "adroit", "amatory", "animistic", "antic", "arcadian", "baleful",
"bellicose", "bilious", "boorish", "calamitous", "caustic", "cerulean", "comely",
"concomitant", "contumacious", "corpulent", "crapulous", "defamatory", "didactic",
"dilatory", "dowdy", "efficacious", "effulgent", "egregious", "endemic",
"equanimous", "execrable", "fastidious", "feckless", "fecund", "friable",
"fruity", "fulsome", "garrulous", "guileless", "gustatory", "heuristic",
"histrionic", "hubristic", "incendiary", "insolent", "intransigent", "inveterate",
"invidious", "irksome", "jejune", "jocular", "judicious", "kaput", "keen",
"kind", "kindhearted", "kindly", "knotty", "knowing", "known", "labored",
"lachrymose", "lackadaisical", "lacking", "lame", "lamentable", "languid",
"last", "late", "laughable", "lavish", "lazy", "lean", "learned", "left",
"legal", "lethal", "level", "lewd", "light", "likeable", "limpid", "limping",
"literate", "little", "lively", "livid", "living", "lonely", "longing", "loose",
"lopsided", "loquacious", "loud", "loutish", "lovely", "lowly", "lucky",
"ludicrous", "luminous", "lumpy", "lush", "luxuriant", "lying", "lyrical",
"macabre", "macho", "maddening", "madly", "magenta", "magical", "magnificent",
"majestic", "makeshift", "malicious", "mammoth", "maniacal", "mannered",
"marked", "married", "marvelous", "massive", "materialistic", "mature", "mean",
"measly", "meaty", "meek", "melancholy", "mellow", "melodic", "melted",
"mendacious", "merciful", "meretricious", "messy", "mighty", "milky", "minatory",
"mindless", "miniature", "minor", "mistaken", "misty", "mixed", "moaning",
"modern", "moldy", "momentous", "moody", "mordant", "mortified", "motionless",
"mountainous", "muddled", "muddy", "mundane", "munificent", "murky", "mushy",
"mute", "mysterious", "naive", "narrow", "nasty", "natural", "naughty",
"nauseating", "near", "neat", "nebulous", "necessary", "needless", "needy",
"nefarious", "neighborly", "nervous", "new", "next", "nice", "nifty",
"nimble", "nippy", "noiseless", "noisy", "nonchalant", "nondescript",
"nonsensical", "nonstop", "normal", "nostalgic", "nosy", "noxious", "numberless",
"numerous", "nutritious", "nutty", "oafish", "obedient", "obeisant",
"obese", "obnoxious", "obscene", "obsequious", "observant", "obsolete",
"obtainable", "obtuse", "oceanic", "odd", "offbeat", "old", "omniscient",
"onerous", "open", "opposite", "optimal", "orange", "ordinary", "organic",
"ossified", "outgoing", "outrageous", "outstanding", "painful", "painstaking",
"pale", "paltry", "panicky", "panoramic", "parallel", "parched", "parsimonious",
"past", "pastoral", "pathetic", "peaceful", "pendulous", "penitent",
"perfect", "periodic", "permissible", "pernicious", "perpetual", "pervasive",
"petite", "petulant", "platitudinous", "precious", "precipitate", "prickly",
"propitious", "proud", "puckish", "pungent", "puny", "quack", "quaint",
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
"jolly", "joyful",

// page 2
"quarrelsome", "querulous", "questionable", "quick", "quiescent", "quiet",
"quirky", "quixotic", "quizzical", "rabid", "ragged", "rainy",
"rambunctious", "rampant", "rapid", "rare", "raspy", "ratty", "ready", "real",
"reassured", "rebarbative", "rebellious", "recalcitrant", "receptive",
"recondite", "redolent", "redundant", "reflective", "regular", "relieved",
"repulsive", "responsive", "rhadamanthine", "ripe", "risible", "robust",
"rotten", "rotund", "rough", "round", "ruminative", "sable", "sad", "safe",
"sagacious", "salty", "salubrious", "same", "sarcastic", "sartorial", "sassy",
"satisfying", "savory", "scandalous", "scant", "scarce", "scared", "scary",
"scattered", "scientific", "scintillating", "scrawny", "screeching",
"second", "selfish", "serpentine", "shaggy", "shaky", "shallow", "sharp",
"shiny", "short", "silky", "silly", "skinny", "slimy", "slippery", "small",
"smarmy", "smiling", "smoggy", "smooth", "smug", "soggy", "solid", "sore",
"sour", "sparkling", "spasmodic", "spicy", "splendid", "spotless", "square",
"stale", "steady", "steep", "sticky", "stormy", "stout", "straight", "strange",
"strident", "strong", "stunning", "substantial", "successful", "succulent",
"superficial", "superior", "swanky", "sweet", "taboo", "tacit", "taciturn",
"tacky", "talented", "tall", "tame", "tan", "tangible", "tangy", "tart",
"tasteful", "tasteless", "tasty", "tawdry", "tearful", "tedious", "teeny",
"telling", "tenacious", "tender", "tense", "terrible", "testy", "thankful",
"thick", "thoughtful", "thoughtless", "tight", "timely", "tremulous",
"trenchant", "tricky", "trite", "troubled", "turbulent", "turgid", "twitterpated",
"ubiquitous", "ugly", "unaccountable", "unadvised",
"unarmed", "unbecoming", "unbiased", "uncovered", "undesirable",
"unequal", "unequaled", "uneven", "unhealthy", "uninterested", "unique",
"unkempt", "unknown", "unnatural", "unruly", "unsightly", "unsuitable",
"untidy", "unusual", "unwieldy", "unwritten", "upbeat", "uppity",
"upset", "uptight", "used", "useful", "useless", "utopian", "uttermost",
"uxorious", "vacuous", "vagabond", "vague", "valuable", "vast", "vengeful",
"venomous", "verdant", "versed", "vexed", "victorious", "vigorous", "violent",
"violet", "virtuous", "vivacious", "vivid", "voiceless", "volatile",
"voluble", "voracious", "vulgar", "wacky", "waggish", "waiting", "wakeful",
"wandering", "warlike", "warm", "wary", "wasteful", "watery", "weak",
"wealthy", "weary", "wet", "wheedling", "whimsical", "whispering", "white",
"wicked", "wide", "wiggly", "wild", "willing", "windy", "wiry",
"wise", "wistful", "withering", "witty", "wobbly", "woebegone", "womanly",
"wonderful", "woozy", "workable", "worried", "worthless", "wrathful",
"wretched", "wrong", "wry", "yellow", "yielding", "young", "youthful", "yummy",
"zany", "zealous", "zippy",
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
"umbrella", "unicorn", "velocipede", "wallpaper", "wizard", "wrench",

// page 2
"abacus", "academy", "acknowledgment", "actor", "affair", "aftershave", "agent",
"agrarian", "anagram", "analysis", "anarchist", "architect", "asset", "astrolabe",
"baker", "bandwidth", "banner", "barber", "barrage", "bass", "batman", "beard",
"behest", "bicycle", "bone", "borrower", "boxer", "breadcrumb", "brewer",
"brownie", "bugle", "builder", "bumblebee", "burglar", "bus", "businessman",
"butcher", "buzzard", "cameraman", "candle", "car", "carpenter", "catamount",
"celebrity", "champion", "character", "chassis", "chemistry", "cinema", "circle",
"citron", "clown", "coach", "cocktail", "comic", "conductor", "cornet", "country",
"crag", "cucumber", "cupboard", "curve", "dentist", "designer", "detective",
"developer", "dictator", "director", "distiller", "diver", "doctor", "doorman",
"drake", "duke", "earl", "election", "electrician", "emperor", "entendre",
"enterprise", "error", "eviction", "eyebrows", "facility", "fairy", "family",
"farmer", "fine", "fireman", "footballer", "foreman", "forestranger", "fulfillment",
"gardener", "geisha", "geometry", "gingerbread", "golfer", "gondola", "grapefruit",
"haberdasher", "highland", "hospital", "household", "housekeeper", "housewife",
"husband", "icebreaker", "issue", "jet", "journalist", "kayak", "king",
"lad", "lense", "leverage", "librarian", "lifeguard", "light", "lighthouse",
"linebacker", "magician", "mailbox", "mangrove", "math", "mechanic", "metal",
"milliner", "mineral", "mist", "mob", "mohawk", "mollusc", "motorcycle", "mound",
"mustache", "muttonchops", "myth", "nail", "napkin", "nation", "ninja",
"nonsense", "notebook", "nun", "nurse", "ocean", "octagon", "omission", "orangutan",
"outrage", "pagoda", "painter", "paramedic", "passage", "patty", "pawn",
"pennyloafer", "perfumer", "photographer", "pickaxe", "pilgrim", "pill",
"pilot", "pirate", "platinum", "platter", "plover", "plumber", "policeman",
"politician", "pollution", "pond", "pope", "postman", "preacher", "president",
"priest", "prince", "princess", "professor", "promise", "purse", "quarterback",
"queen", "radiosonde", "rations", "rebellion", "rectangle", "repairman", "reporter",
"ring", "roadway", "salesman", "savings", "scaffold", "scientist", "score",
"sea", "secretary", "server", "shadow", "sherry", "shoreline", "singer",
"snorer", "snowman", "soldier", "sonata", "space", "spectacles", "spill",
"spine", "spokesman", "stain", "state", "stem", "student", "studio", "summary",
"surgeon", "sweater", "tadpole", "tanker", "tankful", "tap", "target", "teacup",
"therapist", "thesis", "thunder", "toe", "toilet", "tongs", "trainer",
"transaction", "trapeze", "triangle", "trumpet", "turtleneck", "tuxedo",
"tweezers", "twine", "vacation", "valance", "vase", "venue", "vest", "vibraphone",
"vigilante", "vinyl", "viola", "vixen", "waiter", "winemaker", "zucchini",

    ]
];

// Ensure all arrays are the proper length
static assert(words[0].length == 512);
static assert(words[1].length == 512);
static assert(words[2].length == 512);

// Ensure all arrays are unique internally
auto findNonUnique(string[] arr)
{
    import std.algorithm : sort, findAdjacent;
    return arr.dup.sort.findAdjacent();
}

static foreach (i, arr; words)
{
    static assert(arr.findNonUnique().empty,
                  format!`Word list %s has repeat "%s"`(i, arr.findNonUnique().front));
}

// Ensure reversability
static assert("6bddf41".toWords(6).toHash == "6bddf4");
static assert("6bddf41".toWords(7).toHash == "6bddf4");
