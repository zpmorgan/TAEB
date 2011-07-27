package TAEB::ScreenScraper;
use TAEB::OO;
use TAEB::Util qw/crow_flies natatime/;
use TAEB::Announcement;
use NetHack::Menu;
use Try::Tiny;

our %msg_string = (
    "You are blinded by a blast of light!" =>
        ['status_change', 'blindness', 1],
    "You can see again." =>
        ['status_change', 'blindness', 0],
    "You feel feverish." =>
        ['status_change', 'lycanthropy', 1],
    "You feel purified." =>
        ['status_change', 'lycanthropy', 0],
    "You feel quick!" =>
        ['status_change' => fast => 1],
    "You feel slow!" =>
        ['status_change' => fast => 0],
    "You seem faster." =>
        ['status_change' => fast => 1],
    "You seem slower." =>
        ['status_change' => fast => 0],
    "You feel slower." =>
        ['status_change' => fast => 0],
    "You speed up." =>
        ['status_change' => fast => 1],
    "Your quickness feels more natural." =>
        ['status_change' => fast => 1],
    "You are slowing down." =>
        ['status_change' => fast => 0],
    "Your limbs are getting oozy." =>
        ['status_change' => fast => 0],
    "You slow down." =>
        ['status_change' => fast => 0],
    "Your quickness feels less natural." =>
        ['status_change' => fast => 0],
    "\"and thus I grant thee the gift of Speed!\"" =>
        ['status_change' => fast => 1],
    "You slow down." =>
        ['status_change' => very_fast => 0],
    "Your quickness feels less natural." =>
        ['status_change' => very_fast => 0],
    "You are suddenly moving faster." =>
        ['status_change' => very_fast => 1],
    "You are suddenly moving much faster." =>
        ['status_change' => very_fast => 1],
    "Your knees seem more flexible now." =>
        ['status_change' => very_fast => 1],
    "You feel yourself slowing down." =>
        ['status_change' => very_fast => 0],
    "You feel yourself slowing down a bit." =>
        ['status_change' => very_fast => 0],
    "\"and thus I grant thee the gift of Stealth!\"" =>
        ['status_change' => stealthy => 1],
#    "You feel clumsy." XXX this is also an attribute loss message
    "You feel stealthy!" =>
        ['status_change' => stealthy => 1],
    "You feel less stealthy!" =>
        ['status_change' => stealthy => 0],
    "You feel very jumpy." =>
        ['status_change' => teleporting => 1],
    "You feel diffuse." =>
        ['status_change' => teleporting => 1],
    "You feel less jumpy." =>
        ['status_change' => teleporting => 0],
    "The fountain dries up!" =>
        ['dungeon_feature', 'fountain dries up'],
    "As the hand retreats, the fountain disappears!" =>
        ['dungeon_feature', 'fountain dries up'],
    # We need to calculate the amount we would gain _right now_ because
    # if we wait, the publisher queue is run after the bottom line and
    # we use the new AC.  Yuk.
    "The air around you begins to shimmer with a golden haze." =>
        ['protection_add', sub { TAEB->senses->spell_protection_return }],
    "The golden haze around you becomes more dense." =>
        ['protection_add', sub { TAEB->senses->spell_protection_return }],
    "You try to move the boulder, but in vain." =>
        ['immobile_boulder'],
    "Your stomach feels content." =>
        ['nutrition' => 900],
    "You hear crashing rock." =>
        ['pickaxe'],
    "A few ice cubes drop from the wand." =>
        [wand => 'wand of cold'],
    "The wand unsuccessfully fights your attempt to write!" =>
        [wand => 'wand of striking'],
    "A lit field surrounds you!" =>
        [wand => 'wand of light'],
    "Far below you, you see coins glistening in the water." =>
        [floor_item => sub { TAEB->new_item("1 gold piece") }],
    "You wrest one last charge from the worn-out wand." =>
        ['wrest_wand'],
    "You are stuck to the web." =>
        ['web' => 1],
    "You can't write on the water!" =>
        [dungeon_feature => 'fountain'],
    "There is a broken door here." =>
        [dungeon_feature => 'brokendoor'],
    "The dish washer returns!" =>
        ['dishwasher'],
    "Muddy waste pops up from the drain." =>
        ['ring_sink'],
    "A black ooze gushes up from the drain!" =>
        ['pudding'],
    "You get expelled!" =>
        [engulfed => 0],
    "You activated a magic portal!" =>
        ['portal'],
    "Something is engraved here on the headstone." =>
        ['dungeon_feature', 'grave'],
    "The heat and smoke are gone." =>
        ['branch', 'vlad'],
    "You smell smoke..." =>
        ['branch', 'gehennom'],
    "Several flies buzz around the sink." =>
        ['ring' => 'meat ring'],
    "The faucets flash brightly for a moment." =>
        ['ring' => 'ring of adornment'],
    "The sink looks nothing like a fountain." =>
        ['ring' => 'ring of protection from shape changers'],
    "The sink seems to blend into the floor for a moment." =>
        ['ring' => 'ring of stealth'],
    "The water flow seems fixed." =>
        ['ring' => 'ring of sustain ability'],
    "The sink glows white for a moment." =>
        ['ring' => 'ring of warning'],
    "Several flies buzz angrily around the sink." =>
        ['ring' => 'ring of aggravate monster'],
    "The cold water faucet flashes brightly for a moment." =>
        ['ring' => 'ring of cold resistance'],
    "You don't see anything happen to the sink." =>
        ['ring' => 'ring of invisibility'],
    "You see some air in the sink." =>
        ['ring' => 'ring of see invisible'],
    "Static electricity surrounds the sink." =>
        ['ring' => 'ring of shock resistance'],
    "The hot water faucet flashes brightly for a moment." =>
        ['ring' => 'ring of fire resistance'],
    "The sink quivers upward for a moment." =>
        ['ring' => 'ring of levitation'],
    "The sink looks as good as new." =>
        ['ring' => 'ring of regeneration'],
    "The sink momentarily vanishes." =>
        ['ring' => 'ring of teleportation'],
    "You hear loud noises coming from the drain." =>
        ['ring' => 'ring of conflict'],
    "The sink momentarily looks like a fountain." =>
        ['ring' => 'ring of polymorph'],
    "The sink momentarily looks like a regularly erupting geyser." =>
        ['ring' => 'ring of polymorph control'],
    "The sink looks like it is being beamed aboard somewhere." =>
        ['ring' => 'ring of teleport control'],
    "You hear a strange wind." =>
        ['dungeon_level' => 'oracle'],
    "You hear convulsive ravings."  =>
        ['dungeon_level' => 'oracle'],
    "You hear snoring snakes."  =>
        ['dungeon_level' => 'oracle'],
    "You hear someone say \"No more woodchucks!\""  =>
        ['dungeon_level' => 'oracle'],
    "You hear a loud ZOT!"  =>
        ['dungeon_level' => 'oracle'],
    "You enter what seems to be an older, more primitive world." =>
        ['dungeon_level' => 'rogue'],
    "You dig a pit in the floor." =>
        ['pit' => 1],
    "There's not enough room to kick down here." =>
        ['pit' => 1],
    "You can't reach over the edge of the pit." =>
        ['pit' => 1],
    "You float up, out of the pit!" =>
        ['pit' => 0],
    "You crawl to the edge of the pit." =>
        ['pit' => 0],
    "You are still in a pit." =>
        ['pit' => 1],
    "There is a pit here." =>
        ['pit' => 1],
    "You escape a pit." =>
        ['pit' => 0],
    "There's some graffiti on the floor here." =>
        ['engraving_type' => 'graffiti'],
    "You see a message scrawled in blood here." =>
        ['engraving_type' => 'scrawl'],
    "You experience a strange sense of peace." =>
        ['enter_room','temple'],
    "You hear the shrill sound of a guard's whistle." =>
        ['angry_watch'],
    "You see an angry guard approaching!" =>
        ['angry_watch'],
    "You're under arrest!" =>
        ['angry_watch'],
    "You are slowing down." =>
        ['status_change', 'stoning', 1],
    "Your limbs are stiffening." =>
        ['status_change', 'stoning', 1],
    "You feel more limber." =>  # praying
        ['status_change', 'stoning', 0],
    "You feel limber!" =>  # consuming acid
        ['status_change', 'stoning', 0],
    "You hear somene cursing shoplifters." =>
        ['level_message', 'shop'],
    "You hear the chime of a cash register." =>
        ['level_message', 'shop'],
    "You hear Neiman and Marcus arguing!" => # hallu
        ['level_message', 'shop'],
    "You hear the footsteps of a guard on patrol." =>
        ['level_message', 'vault'],
    "You hear someone counting money." =>
        ['level_message', 'vault'],
    "You hear someone searching." =>
        ['level_message', 'vault'],
    "Your health currently feels amplified!" =>
        ['resistance_change', 'shock', 1],
    "You feel insulated!" =>
        ['resistance_change', 'shock', 1],
    "You feel grounded in reality." =>
        ['resistance_change', 'shock', 1],
    "This water's no good!" =>
        [check => 'inventory'],
    "You feel as if you need some help." =>
        [check => 'inventory'],
    "\"A curse upon thee for sitting upon this most holy throne!\"" =>
        [check => 'inventory'],
    "Your right leg is in no shape for kicking." =>
        [status_change => wounded_legs => 1],
    "You hear nothing special." =>
        ['negative_stethoscope'],
    "You hear a voice say, \"It's dead, Jim.\"" =>
        ['negative_stethoscope'],
    "You determine that that unfortunate being is dead." =>
        ['negative_stethoscope'],
    "You couldn't quite make out that last message." =>
        ['quest_portal'],
    "You turn to stone!" =>
        ['polyself', 'stone golem'],
    # there can be other ceiling types
    "A trap door in the ceiling opens, but nothing falls out!" =>
        [dungeon_feature => trap => 0],
    # other ceiling types, other head types
    "A trap door in the ceiling opens and a rock falls on your head!" =>
        [dungeon_feature => trap => "falling rock trap"],
    "You feel a change coming over you." =>
        [dungeon_feature => trap => 0],
    "Fortunately for you, no boulder was released." =>
        [dungeon_feature => trap => 0],
    "An arrow shoots out at you!" =>
        [dungeon_feature => trap => "arrow trap"],
    "A little dart shoots out at you!" =>
        [dungeon_feature => trap => "dart trap"],
    "You notice a crease in the linoleum." =>
        [dungeon_feature => trap => "squeaky board"],
    "You notice a loose board below you." =>
        [dungeon_feature => trap => "squeaky board"],
    "A board beneath you squeaks loudly." =>
        [dungeon_feature => trap => "squeaky board"],
    "You are enveloped in a cloud of gas!" =>
        [dungeon_feature => trap => "sleeping gas trap"],
    "A cloud of gas puts you to sleep!" =>
        [dungeon_feature => trap => "sleeping gas trap"],
    "You land on a set of sharp iron spikes!" =>
        [dungeon_feature => trap => "spiked pit"],
    "KAABLAMM!!!" =>
        [dungeon_feature => trap => "pit"],
    "There's a gaping hole under you!" =>
        [dungeon_feature => trap => "hole"],
    "You take a walk on your web." =>
        [dungeon_feature => trap => "web"],
    "There is a spider web here." =>
        [dungeon_feature => trap => "web"],
    # levelport trap message ends with a '.'
    "You are momentarily blinded by a flash of light!" =>
        [dungeon_feature => trap => "magic trap"],
    "You see a flash of light!" =>
        [dungeon_feature => trap => "magic trap"],
    "You hear a deafening roar!" =>
        [dungeon_feature => trap => "magic trap"],
    # polymorph
    "A shiver runs up and down your spine!" =>
        [dungeon_feature => trap => "magic trap"],
    "You hear the moon howling at you." =>
        [dungeon_feature => trap => "magic trap"],
    "You hear distant howling." =>
        [dungeon_feature => trap => "magic trap"],
    "Your pack shakes violently!" =>
        [dungeon_feature => trap => "magic trap"],
    "You smell hamburgers." =>
        [dungeon_feature => trap => "magic trap"],
    "You smell charred flesh." =>
        [dungeon_feature => trap => "magic trap"],
    # can also get this when losing sleep res
    #"You feel tired."
    "You feel momentarily lethargic." =>
        [dungeon_feature => trap => "anti-magic trap"],
    "You feel momentarily different." =>
        [dungeon_feature => trap => "polymorph trap"],
    "Click! You trigger a rolling boulder trap!" =>
        [dungeon_feature => trap => "rolling boulder trap"],
    "You activated a magic portal!" =>
        [dungeon_feature => trap => "magic portal"],
    "You hear a CRASH! beneath you." =>
        [dungeon_feature => trap => 0],
    'You are suddenly in familiar surroundings.' =>
        [quest_entrance => 'Arc'],
    'Warily you scan your surroundings,' =>
        [quest_entrance => 'Bar'],
    'You descend through a barely familiar stairwell' =>
        [quest_entrance => 'Cav'],
    'What sorcery has brought you back to the Temple' =>
        [quest_entrance => 'Hea'],
    'You materialize in the shadows of Camelot Castle.' =>
        [quest_entrance => 'Kni'],
    'You find yourself standing in sight of the Monastery' =>
        [quest_entrance => 'Mon'],
    'You find yourself standing in sight of the Great' =>
        [quest_entrance => 'Pri'],
    'You arrive in familiar surroundings.' =>
        [quest_entrance => 'Ran'],
    'Even before your senses adjust, you recognize the kami' =>
        [quest_entrance => 'Sam'],
    'You breathe a sigh of relief as you find yourself' =>
        [quest_entrance => 'Tou'],
    'You materialize at the base of a snowy hill.' =>
        [quest_entrance => 'Val'],
    'You are suddenly in familiar surroundings.' =>
        [quest_entrance => 'Wiz'],
    'They are cursed.' =>
        ['cursed'],
    'It is cursed.' =>
        ['cursed'],
    'You start to float in the air!' =>
        [status_change => levitation => 1],
    'You float gently to the floor.' =>
        [status_change => levitation => 0],
    'You are floating high above the stairs.' =>
        [status_change => levitation => 1],
    'You have nothing to brace yourself against.' =>
        [status_change => levitation => 1],
    'You cannot reach the ground.' =>
        [status_change => levitation => 1],
    'You are floating high above the fountain.' =>
        [status_change => levitation => 1],
    'Floating in the air, you miss wildly!'  =>
        ['impeded_by_levitation'],
    'Your sacrifice sprouts wings and a propeller and roars away!' =>
        ['sacrifice_gone'],
    'Your sacrifice puffs up, swelling bigger and bigger, and pops!' =>
        ['sacrifice_gone'],
    'Your sacrifice collapses into a cloud of dancing particles and fades away!' =>
        ['sacrifice_gone'],
    'Your sacrifice disappears!' =>
        ['sacrifice_gone'],
    'Your sacrifice disappears in a flash of light!' =>
        ['sacrifice_gone'],
    'Your sacrifice disappears in a burst of flame!' =>
        ['sacrifice_gone'],
    'The blood covers the altar!' =>
        ['sacrifice_gone'],
    'You have no secondary weapon readied.' =>
        ['slot_empty', 'offhand'],
);

our @msg_regex = (
    [
            qr/^You are(?: already)? empty .*\.$/,
                ['slot_empty', 'weapon'],
    ],
    [
            qr/^You (?:turn into an?|feel like a new)(?: female| male|) ([^!]*)!$/,
                # Luckily, all the base races are M2_NOPOLY.
                ['polyself', sub {
                    $1 =~ /man|woman|elf|dwarf|gnome|orc/ ? undef : $1; }],
    ],
    [
            qr/^You offer the Amulet of Yendor to .*$/,
                ['sacrifice_gone'],
    ],
    [
            qr/^The blood floods the altar, which vanishes in a .* cloud!$/,
                ['sacrifice_gone'],
    ],
    [
            qr/^You return to .* form!$/,
                ['polyself', undef],
    ],
    [
            qr/^The altar is stained with .* blood.$/,
                ['sacrifice_gone'],
    ],
    [
            qr/^The .* appears to be in ex(?:cellent|traordinary) health for a statue.$/,
                ['negative_stethoscope'],
    ],
    [
            qr/^Your legs? feels? somewhat better\.$/,
                [status_change => wounded_legs => 0],
    ],
    [
            qr/^You can't go (?:up|down) here\.$/,
                ['dungeon_feature', 'bad staircase'],
    ],
    [
        qr/^There is a (staircase (?:up|down)|fountain|sink|grave) here\.$/,
            ['dungeon_feature', sub { $1 }],
    ],
    [
        qr/^You feel more confident in your (?:(weapon|spell casting|fighting) )?skills\.$/,
            [check => 'enhance'],
    ],
    # There's no message for cursing intervene() while blind and MRless :(
    [
        qr/^You notice a .* glow surrounding you\.$/, # sic: "a orange glow"
            [check => 'inventory'],
    ],
    # this can be the only message we get, if blind and MRless
    [
        qr/^The voice of.*: "Thou hast angered me\."$/,
            [check => 'inventory'],
    ],
    [
        qr/^You cannot escape from (?:the )?(.*)!/,
            ['cannot_escape', sub { $1 || '' }],
    ],
    [
        qr/^You throw (\d+) /,
            ['throw_count', sub { $1 }],
    ],
    [
        qr/^You fall into (?:a|your) pit!/,
            ['pit' => 1]
    ],
    [
        qr/^You stumble into (?:a|your) spider web!/,
            ['web' => 1]
    ],
    [
        qr/^You (?:see|feel) here (.*?)\./,
            ['floor_item', sub {
                if (defined TAEB->current_tile &&
                    TAEB->current_tile->item_count == 1) {
                    my $item = TAEB->new_item($1);
                    if (@{TAEB->current_tile->items}[0]->maybe_is($item)) {
                        TAEB->log->scraper("Not updating the $item here ".
                                           "because it's consistent with ".
                                           "what we thought was there.");
                        return;
                    } else {
                        TAEB->announce('tile_noitems');
                        return $item;
                    }
                } else {
                    TAEB->announce('tile_noitems');
                    return TAEB->new_item($1);
                }}],
    ],
    [
        qr/^You read: \"(.*)\"\./,
            ['floor_message', sub { (my $str = $1) =~ tr/_/ /; $str }],
    ],
    [
        qr/^The engraving on the .*? vanishes!/,
            [wand => map { "wand of $_" } 'teleportation', 'cancellation', 'make invisible'],
    ],
    [
        qr/^The bugs on the .*? stop moving!/,
            [wand => 'wand of death', 'wand of sleep'],
    ],
    [
        # digging, fire, lightning
        qr/^This .*? is a (wand of \S+)!/,
            [wand => sub { $1 }],
    ],
    [
        qr/^The .*? is riddled by bullet holes!/,
            [wand => 'wand of magic missile'],
    ],
    [
        # slow monster, speed monster
        qr/^The bugs on the .*? (slow|speed) (?:up|down)\!/,
            [wand => sub { "wand of $1 monster" }],
    ],
    [
        qr/^The engraving now reads:/,
            [wand => 'wand of polymorph'],
    ],
    [
        qr/^You (add to the writing|write) in the dust with a.* wand of (create monster|secret door detection)/,
            [wand => sub { "wand of $2" }],
    ],
    [
        qr/^.*? zaps (?:(?:him|her|it)self with )?an? .*? wand!/,
            ['check' => 'discoveries'],
    ],
    [
        qr/^(.*), price (\d+) zorkmids?(?: each)?/,
            [item_price => sub { TAEB->new_item($1), $2 } ],
    ],
    [
        qr/^(.*), no charge/,
            [item_price => sub { TAEB->new_item($1), 0 } ],
    ],
    [
        qr/^There are (?:several|many) (?:more )?objects here\./,
            [check => 'floor'],
    ],
    [
        qr/^(?:(?:The .*?)|She|It) (?:steals|stole) (.*)(?:\.|\!)/,
            [lost_item => sub { TAEB->new_item($1) }],
    ],
    [
        qr/^You are (?:almost )?hit by /,
            [check => 'floor'],
    ],
    [
        qr/^(.*?) engulfs you!/ =>
            ['engulfed' => 1],
    ],
    [
        qr/^(.*?) reads a scroll / =>
            [check => 'discoveries'],
    ],
    [
        qr/^(.*?) drinks an? .* potion|^(.*?) drinks a potion called / =>
            [check => 'discoveries'],
    ],
    [
        qr/^Autopickup: (ON|OFF)/ =>
            ['autopickup' => sub { $1 eq 'ON' }],
    ],
    [
        qr/^You (?:kill|destroy) (?:the|an?)(?: poor)?(?: invisible)? (.*)(?:\.|!)/ =>
            ['killed' => sub { $1 } ],
    ],
    [
        qr/^Suddenly, .* vanishes from the sink!/ =>
            ['ring' => 'ring of hunger'],
    ],
    [
        qr/^The sink glows (silver|black) for a moment\./ =>
            ['ring' => 'ring of protection'],
    ],
    [
        qr/^The water flow seems (greater|lesser) now.\./ =>
            ['ring' => 'ring of gain constitution'],
    ],
    [
        qr/^The water flow seems (stronger|weaker) now.\./ =>
            ['ring' => 'ring of gain strength'],
    ],
    [
        qr/^The water flow (hits|misses) the drain\./ =>
            ['ring' => 'ring of increase accuracy'],
    ],
    [
        qr/^The water's force seems (greater|smaller) now\./ =>
            ['ring' => 'ring of increase damage'],
    ],
    [
        qr/^You smell rotten (.*)\./ =>
            ['ring' => 'ring of poison resistance'],
    ],
    [
        qr/^You thought your (.*) got lost in the sink, but there it is!/ =>
            ['ring' => 'ring of searching'],
    ],
    [
        qr/^You see (.*) slide right down the drain!/ =>
            ['ring' => 'ring of free action'],
    ],
    [
        qr/(.*) is regurgitated!/ =>
            ['ring' => 'ring of slow digestion'],
    ],
    [
        qr/^You stop eating the (.*)\./ =>
            ['stopped_eating' => sub { $1 } ],
    ],
    [
        qr/You add the .* spell to your repertoire/ =>
            [check => 'spells'],
    ],
    [
        qr/You add the (.*) spell to your repertoire/ =>
            ['check' => 'discoveries'],
    ],
    [
        qr/You add the (.*) spell to your repertoire/ =>
            ['learned_spell' => sub { $1 }],
    ],
    [
        qr/crashes on .* and breaks into shards/ =>
            ['check' => 'discoveries'],
    ],
    [
        # Avoid 'stolen', which comes up in many more places
        # 'stole' comes up in quest dialog too sometimes, but checking
        # our inventory in response to that is not a disaster
        # This could be us stealing (unpaid becoming 'paid'), or a
        # monster stealing (missing items).
        qr/\bstole\b/ =>
            ['check' => 'inventory'],
    ],
    [   # Avoid matching shopkeeper name by checking for capital lettering.
        qr/Welcome(?: again)? to(?> [A-Z]\S+)+ ([a-z -]+)!/ =>
            ['enter_room',
             sub {
                (
                    $1 eq 'treasure zoo' ? 'zoo' : 'shop',
                    TAEB::Spoilers::Room->shop_type($1)
                )
             },
            ],
    ],
    [
        qr/You have a(?: strange) forbidding feeling\./ =>
            ['enter_room','temple'],
    ],
    [
        qr/, welcome to Delphi!\"$/ =>
            ['dungeon_level' => 'oracle'],
    ],
    [
        qr/^Some text has been (burned|melted) into the (?:.*) here\./ =>
            ['engraving_type' => sub { $1 } ],
    ],
    [
        qr/^Something is (written|engraved) here (?:in|on) the (?:.*)\./ =>
            ['engraving_type' => sub { $1 } ],
    ],
    [
        qr/^(?:(?:The )?(.*|Your)) medallion begins to glow!/ =>
            ['life_saving' => sub { $1 } ],
    ],
    [
        qr/^There is an altar to [\w\- ]+ \((law|neu|cha|unaligned)\w*\) here\./ =>
            ['dungeon_feature' => sub { ucfirst($1) .' altar' } ],
    ],
    [
        qr/^There's a (.*?) hiding under a (.*)!/ =>
            ['hidden_monster' => sub { ($1, $2) } ],
    ],
    [
        qr/^What a pity - you just ruined a future piece of (?:fine )?art!/ =>
            ['status_change', 'stoning', 0],
    ],
    [
        qr/^(.*?) (hits|misses)[.!]$/ =>
            ['attacked' => sub { ($1, $2 eq 'hits') } ],
    ],
    [
        qr/^Your .* get new energy\.$/ =>
            [status_change => very_fast => 1],
    ],
    [
        # This one is somewhat tricky.  There is no message for speed ending
        # if you are still very fast due to speed boots, so speed will stay
        # at 'fast'. This causes no harm until the boots are taken off or
        # destroyed; fortunately at that time we receive the following message,
        # which allows us to fix the mistaken speed.
        qr/^You feel yourself slow down.*\.$/ =>
            [status_change => very_fast => 0],
    ],
    [
        qr/^You (?:be chillin'|feel a momentary chill)\.$/ =>
            ['resistance_change', 'fire', 1],
    ],
    [
        qr/^You feel (?:warm\!|full of hot air\.)$/ =>
            ['resistance_change', 'cold', 1],
    ],
    [
        qr/^You feel (?:very firm|totally together, man)\.$/ =>
            ['resistance_change', 'disintegration', 1],
    ],
    [
        qr/^You feel(?: especially)? (?:healthy|hardy)(?:\.|\!)$/ =>
            ['resistance_change', 'poison', 1],
    ],
    [
        qr/^You feel(?: wide)? awake(?:\.|\!)$/ =>
            ['resistance_change', 'sleep', 1],
    ],
    [
        qr/^You (?:hurtle|float) in the opposite direction/ =>
            ['hurtle'],
    ],
    [
        qr/Air currents pull you down into \w+ (hole|pit)!/ =>
            [dungeon_feature => trap => sub { $1 }],
    ],
    [
        qr/You (?:float|fly) over \w+ (.*)\./ =>
            [dungeon_feature => trap => sub { $1 }],
    ],
    [
        qr/You escape \w+ (.*)\./ =>
            [dungeon_feature => trap => sub { $1 }],
    ],
    [
        qr/You hear a (?:loud|soft) click(?:!|\.)/ =>
            [dungeon_feature => trap => 0],
    ],
    [
        qr/You (?:burn|dissolve) \w+ spider web!/ =>
            [dungeon_feature => trap => 0],
    ],
    [
        qr/You tear through \w+ web!/ =>
            [dungeon_feature => trap => 0],
    ],
    [
        # polymorph issues
        qr/A gush of water hits you(?: on the head|r (?:left|right) arm)!/ =>
            [dungeon_feature => trap => "rust trap"],
    ],
    [
        qr/You see \w+ ((?:spiked )?pit) below you\./ =>
            [dungeon_feature => trap => sub { $1 }],
    ],
    [
        qr/\w+ pit (full of spikes )?opens up under you!/ =>
            [dungeon_feature => trap => sub { $1 ? "spiked pit" : "pit" }],
    ],
    [
        # steed issues
        qr/You fall into \w+ pit!/ =>
            [dungeon_feature => trap => "pit"],
    ],
    [
        qr/You flow through \w+ spider web\./ =>
            [dungeon_feature => trap => "web"],
    ],
    [
        qr/You stumble into \w+ spider web!/ =>
            [dungeon_feature => trap => "web"],
    ],
    [
        qr/You feel (?:oddly )?like the prodigal son\./ =>
            [dungeon_feature => trap => "magic trap"],
    ],
    [
        qr/You suddenly yearn for (?:Cleveland|your (?:nearby|distant) homeland)\./ =>
            [dungeon_feature => trap => "magic trap"],
    ],
    [
        qr/(?:There is|You discover) (?:the )?trigger(?: of your mine)? in a pile of soil below you\./ =>
            [dungeon_feature => trap => "land mine"],
    ],
    [
        qr/(.*) slips? as you throw it!/ =>
            [throw_slip => sub { $1 }],
    ],
    [
        qr/^Your (.*?) corpses? rots? away\./ =>
            [corpse_rot => sub { $1 }],
    ],
);

our @god_anger = (
    qr/^You feel that .*? is (bummed|displeased)\.$/                   => 1,
    qr/^"Thou must relearn thy lessons!"$/                             => 3,
    qr/^"Thou durst (scorn|call upon) me\?"$/                          => 8,
    qr/^Suddenly, a bolt of lightning strikes you!$/                   => 10000,
    qr/^Suddenly a bolt of lightning comes down at you from the heavens!$/ => 10000,
);

my $it = natatime(2, @god_anger);
while (my ($regex, $anger) = $it->()) {
    push @msg_regex, [
        $regex,
        ['god_angry' => $anger],
    ];
}

our @prompts = (
    qr/^What do you want to write with\?/   => 'write_with',
    qr/^What do you want to dip\?/          => 'dip_what',
    qr/^What do you want to dip into\?/     => 'dip_into_what',
    qr/^What do you want to throw\?/        => 'throw_what',
    qr/^What do you want to wield\?/        => 'wield_what',
    qr/^What do you want to use or apply\?/ => 'apply_what',
    qr/^In what direction\?/                => 'what_direction',
    qr/^In what direction do you want .*\?/ => 'what_direction',
    qr/^Talk to whom\? \(in what direction\)/ => 'what_direction',
    qr/^Itemized billing\? \[yn\] \(n\)/    => 'itemized_billing',
    qr/^Lock it\?/                          => 'lock',
    qr/^Unlock it\?/                        => 'unlock',
    qr/^Drink from the (fountain|sink)\?/   => 'drink_from',
    qr/^What do you want to drink\?/        => 'drink_what',
    qr/^What do you want to eat\?/          => 'eat_what',
    qr/^What do you want to sacrifice\?/    => 'sacrifice_what',
    qr/^What do you want to zap\?/          => 'zap_what',
    qr/^What do you want to read\?/         => 'read_what',
    qr/^What do you want to rub\?/          => 'rub_what',
    qr/^What do you want to rub on .*?\?/   => 'rub_on_what',
    qr/^For what do you wish\?/             => 'wish',
    qr/^Really attack (.*?)\?/              => 'really_attack',
    qr/^This spellbook is difficult to comprehend/ => 'difficult_spell',
    qr/^Dip (.*?) into the (fountain|pool of water|water|moat)\?/ => 'dip_into_water',
    qr/^There (?:is|are) (.*?) here; eat (?:it|one)\?/ => 'eat_ground',
    qr/^There (?:is|are) (.*?) here; sacrifice (?:it|one)\?/ => 'sacrifice_ground',
    qr/^What do you want to (?:write|engrave|burn|scribble|scrawl|melt) (?:in|into|on) the (.*?) here\?/ => 'write_what',
    qr/^What do you want to add to the (?:writing|engraving|grafitti|scrawl|text) (?:in|on|melted into) the (.*?) here\?/ => 'write_what',
    qr/^Do you want to add to the current engraving\?/ => 'add_engraving',
    qr/^Name an individual object\?/        => 'name_specific',
    qr/^What do you want to (?:call|name)\?/ => 'name_what',
    qr/^Call (.*?):/                        => 'name',
    qr/^What do you want to wear\?/         => 'wear_what',
    qr/^What do you want to put on\?/       => 'wear_what',
    qr/^What do you want to remove\?/       => 'remove_what',
    qr/^What do you want to take off\?/     => 'remove_what',
    qr/^Which ring-finger, Right or Left\?/   => 'which_finger',
    qr/^(.*?) for (\d+) zorkmids?\.  Pay\?/ => 'buy_item',
    qr/You did (\d+) zorkmids worth of damage!/ => 'buy_door',
    qr/^"Hello stranger, who are you\?"/ => 'vault_guard',
    qr/^How much will you offer\?/      => 'donate',
    qr/^Do you want to keep the save file\?/ => 'save_file',
    qr/^Advance skills without practice\?/ => 'advance_without_practice',
    qr/^Stop eating\?/ => 'stop_eating',
    qr/^You have (?:a little|much) trouble lifting .*\. Continue\?/ => 'continue_lifting',
    qr/^Beware, there will be no return! Still climb\?/ => 'really_escape',
);

our @exceptions = (
    qr/^You don't have that object/             => 'missing_item',
    qr/^You don't have anything to (?:zap|eat)/ => 'missing_item',
    qr/^You don't have anything to use or apply/=> 'missing_item',
    qr/^You don't have anything else to wear/   => 'missing_item',
    qr/^You are too hungry to cast that spell/  => 'hunger_cast',
    qr/^You have nothing to brace yourself against/ => 'impeded_by_levitation',
    # The next case is if we fail to kick something due to levitation,
    # and simultaneously are trapped by a momement-preventing trap.
    qr/^You are anchored by the/                => 'impeded_by_levitation',
    qr/^You are floating high above the/        => 'impeded_by_levitation',
    qr/^You don't have enough leverage to push the/ => 'impeded_by_levitation',
    qr/^You wobble unsteadily for a moment/     => 'impeded_by_levitation',
    qr/^You must be on the ground to spin a web/=> 'impeded_by_levitation',
    # An unfortunate message collision here; this can happen both on the
    # plane of Air without levitation, or using #sit with it. However,
    # an impeded_by_levitation message when not levitating should normally
    # be safely ignorable.
    qr/^You tumble in place/                    => 'impeded_by_levitation',
    # three cases for "you cannot reach the"; 'bottom' rules out picking
    # up items from an escaped-from pit, the other two are for saddling
    # and picking up items while levitating
    qr/^You can(?:no|')t reach the (?!bottom)/  => 'impeded_by_levitation',
    qr/^Not wearing any armor/                  => 'not_wearing',
    qr/^You are not wearing that/               => 'not_wearing',
);

our @location_requests = (
    qr/^To what position do you want to be teleported\?/ => 'controlled_tele',
    qr/^Where do you want to travel to\?/ => 'travel',
);

has messages => (
    is  => 'rw',
    isa => 'Str',
);

has old_messages => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { [] },
);

has parsed_messages => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { [] },
);

has calls_this_turn => (
    traits  => ['Counter'],
    is      => 'ro',
    default => 0,
    handles => {
        inc_calls_this_turn   => 'inc',
        reset_calls_this_turn => 'reset',
    },
);

has saw_floor_list_this_step => (
    is        => 'rw',
    isa       => 'Bool',
    default   => 0,
);

sub _recurse {
    local $SIG{__DIE__};
    die "Recursing screenscraper.\n";
}

sub scrape {
    my $self = shift;

    $self->check_cycling;

    try {
        # You don't have that object!
        $self->handle_exceptions;

        # handle ^X
        $self->handle_attributes;

        # handle --More-- menus
        $self->handle_more_menus;

        # handle death messages
        $self->handle_game_end;

        # handle menus
        $self->handle_menus;

        # handle --More--
        $self->handle_more;

        # handle other text
        $self->handle_fallback;

        # handle location requests
        $self->handle_location_request;

        # publish messages for all_messages
        $self->send_messages;
    }
    catch {
        if (/^Recursing screenscraper/) {
            @_ = 'TAEB';
            goto TAEB->can('process_input');
        }
        else {
            local $SIG{__DIE__}; # don't need to log again
            die "$_\n";
        }
    };
}

sub check_cycling {
    my $self = shift;

    $self->inc_calls_this_turn;

    if ($self->calls_this_turn > 500) {
        TAEB->log->scraper("It seems I'm iterating endlessly and making no progress.", level => 'critical');
        die 'Recursing screenscraper'; # will call appropriate emergency save/quit
    }
}

subscribe turn => sub {
    my $self = shift;

    $self->reset_calls_this_turn;
};

subscribe step => sub {
    my $self = shift;

    $self->saw_floor_list_this_step(0);
};

sub clear {
    my $self = shift;

    $self->messages('');
    splice @{ $self->parsed_messages };
}

sub handle_exceptions {
    my $response = TAEB->get_exceptional_response(TAEB->topline);
    if (defined $response) {
        TAEB->write($response);
        _recurse;
    }
}

# Error on exceptions that should have been caught earlier.
sub exception_impeded_by_levitation {
    if(TAEB->is_levitating) {
        TAEB->log->scraper("An action failed due to levitation, but this wasn't ".
                           "caught earlier", level => 'error');
    } else {
        TAEB->is_levitating(1);
    }
    return "\e\e\e";
}

sub handle_more {
    my $self = shift;

    # while there's a --More-- on the screen..
    while (TAEB->vt->as_string =~ /^(.*?)--More--/) {
        # add the text to the buffer
        $self->messages($self->messages . '  ' . $1);

        # try to get rid of the --More--
        TAEB->write(' ');
        _recurse;
    }
}

sub handle_attributes {
    my $self = shift;
    my ($method, $attribute);
    if (TAEB->topline =~ /^(\s+)Base Attributes/) {
        my $start = length($1);
        my $skip = $start + 17;

        (my $name = substr(TAEB->vt->row_plaintext(3), $skip)) =~ s/ //g;
        TAEB->name($name);

        # Alignment may end up on line 13 or 14 depending on if we are
        # polymorphed into something with a different gender
        # 4: race  5: role  12: gender 13-14: align
        for (4, 5, 12, 13, 14) {
            next unless my ($method, $attribute) =
                substr(TAEB->vt->row_plaintext($_), $start) =~
                    m/(race|role|gender|align)(?:ment)?\s+: (.*)\b/;
            $attribute = substr($attribute, 0, 3);
            $attribute = ucfirst lc $attribute;
            TAEB->$method($attribute);
        }

        # can't go in the loop above because it collides with race
        my ($polyrace) = substr(TAEB->vt->row_plaintext(10), $start) =~
            m/race\s+: (.*?)\s*$/;

        TAEB->polyself($polyrace =~ /^(?:orc|elf|gnome|dwarf|human)$/ ?
            undef : $polyrace);

        TAEB->log->scraper(sprintf 'It seems we are a %s %s %s %s named %s.', TAEB->role, TAEB->race, TAEB->gender, TAEB->align, TAEB->name);
        TAEB->send_message('character', TAEB->name, TAEB->role, TAEB->race,
                                        TAEB->gender, TAEB->align);

        TAEB->write(' ');
        _recurse;
    }
    # wizmode data; we should parse this eventually
    elsif (TAEB->topline =~ /^\s*Current Attributes:\s*$/) {
        TAEB->write(' ');
        _recurse;
    }
}

sub handle_more_menus {
    my $self = shift;
    my $each;
    my $afterloop;
    my $line_3 = 0;

    if (TAEB->topline =~ /^\s*Discoveries\s*$/) {
        $each = sub {
            my ($identity, $appearance) = /^\s+(.*?) \((.*?)\)/
                or return;
            TAEB->log->scraper("Discovery: $appearance is $identity");
            TAEB->send_message('discovery', $identity, $appearance);
        };
    }
    elsif (TAEB->topline =~ /Things that (?:are|you feel) here:/
        || ($line_3 = TAEB->vt->row_plaintext(2) =~ /Things that (?:are|you feel) here:/)
    ) {
        $self->messages($self->messages . '  ' . TAEB->topline) if $line_3;
        my @olditemlist = TAEB->current_tile->items;
        my @newitemlist = ();
        TAEB->announce('tile_noitems');
        $self->saw_floor_list_this_step(1);
        my $skip = 1;
        $each = sub {
            # skip the items until we get "Things that are here" which
            # typically is a message like "There is a door here"
            do { $skip = 0; return } if /^\s*Things that are here:/;
            return if $skip;

            my $item = TAEB->new_item($_);
            push @newitemlist, $item;
        };
        $afterloop = sub {
            # Let's see if any items were already there; this avoids
            # overwriting things like price and charge info. We assume
            # the items stay in the same order on the floor; if they
            # don't, they're probably different items. NetHack puts
            # newly-dropped items on the /start/ of the list of items
            # on the floor; TAEB puts newly seen items on the /end/ of
            # its list. In other words, a newly dropped item will be
            # at the start of the list, so we want to match the last
            # item on the ground to the last item in the array.
            my $newiter = $#newitemlist;
            my $olditer = $#olditemlist;
            # It's important to get the order right. This loop must
            # go backwards...
            while ($newiter >= 0 && $olditer >= 0) {
                if ($newitemlist[$newiter]->maybe_is(
                        $olditemlist[$olditer])) {
                    $newitemlist[$newiter] = $olditemlist[$olditer];
                }
                $newiter--;
                $olditer--;
            }
            # but this loop must go forwards.
            for my $item (@newitemlist) {
                TAEB->log->scraper("(Re)adding $item to the current tile.");
                TAEB->send_message('floor_item' => $item);
            }
            return 0;
        };
    }
    elsif (TAEB->topline =~ /Fine goods for sale:/) {
        $each = sub {
            /^\s*(.*), (\d+) zorkmids?/ and
                TAEB->send_message('item_price' => TAEB->new_item($1), $2);
            /^\s*(.*), no charge/ and
                TAEB->send_message('item_price' => TAEB->new_item($1), 0);
            return 0;
        }
    }
    elsif (TAEB->state eq 'dying' && TAEB->topline =~ /Voluntary challenges:\s*$/) {
        my $skip = 2;
        $each = sub {
            return if $skip-- > 0;
            s/\s+$//;

            s{^You were vegetarian\.$}                {vegetarian}   ||
            s{^You followed a strict vegan diet\.$}   {vegan}        ||
            s{^You went without food\.$}              {foodless}     ||
            s{^You were an atheist\.$}                {atheist}      ||
            s{^You never hit with a wielded weapon\.$}{weaponless}   ||
            s{^You were illiterate\.$}                {illiterate}   ||
            s{^You never genocided any monsters\.$}   {genoless}     ||
            s{^You never polymorphed an object\.$}    {polyitemless} ||
            s{^You never changed form\.$}             {polyselfless} ||
            s{^You used no wishes\.$}                 {wishless}     ||
            s{^You did not wish for any artifacts\.}  {artiwishless} ||
            s{^You were a pacifist\.}                 {pacifist}     ||
            (/^You used \d+ wish(es)\./ && next)                     ||
            (/You used a wielded weapon \d+ times?\./ && next)       ||
            TAEB->log->scraper("Unable to parse conduct string '$_'.");

            TAEB->death_report->add_conduct($_);
        };
    }


    if ($each) {
        my $iter = 0;
        while (1) {
            ++$iter;

            # find the first column the menu begins
            my ($endrow, $begincol);
            my $lastrow_contents = TAEB->vt->row_plaintext(TAEB->vt->y);
            if ($lastrow_contents =~ /^(.*?)--More--/) {
                $endrow = TAEB->vt->y;
                $begincol = length $1;
            }
            else {
                last if $iter > 1;
                die "Unable to find --More-- on the end row: $lastrow_contents";
            }

            if ($iter > 1) {
                # on subsequent iterations, the --More-- will be in the second
                # column when the menu is continuing
                last if $begincol != 1;
            }

            # now for each menu line, invoke the coderef
            for my $row (0 .. $endrow - 1) {
                local $_ = TAEB->vt->row_plaintext($row, $begincol, 80);
                $each->($_);
            }

            # get to the next page of the menu
            TAEB->write(' ');
            TAEB->process_input(0);
        }
        $afterloop->() if $afterloop;
        _recurse;
    }
}

sub handle_menus {
    my $self = shift;
    my $menu = NetHack::Menu->new(vt => TAEB->vt);

    my $selector;
    my $committer = sub { $menu->commit };

    if (TAEB->topline =~ /Pick up what\?/) {
        $selector = TAEB->menu_select('pickup');
    }
    elsif (TAEB->topline =~ /Pick a skill to advance/) {
        $selector = TAEB->menu_select('enhance');
    }
    elsif (TAEB->topline =~ /What would you like to identify first\?/) {
        $selector = TAEB->menu_select('identify');
    }
    elsif (TAEB->topline =~ /Choose which spell to cast/) {
        my $which_spell = TAEB->is_checking('spells') ? "\e"
                        : TAEB->single_select('cast') || "\e";
        $committer = sub { $which_spell };

        $selector = sub {
            my $slot = shift;

            # force bolt             1    attack         0%
            my ($name, $forgotten, $fail) =
                /^(.*?)\s+\d([ *])\s+\w+\s+(\d+)%\s*$/
                    or return;

            TAEB->send_message('know_spell',
                $slot, $name, $forgotten eq '*', $fail);

            return;
        };
    }
    elsif (TAEB->topline =~ /What would you like to drop\?/) {
        # this one is special: it'll handle updating the inventory
        my %dont_have = map { ($_, 1) } 'a' .. 'z', 'A' .. 'Z';

        $selector = sub {
            my $slot = shift;
            my $new_item = TAEB->new_item($_);

            TAEB->inventory->update($slot => $new_item);
            my $item = TAEB->inventory->get($slot);
            delete $dont_have{$slot} if $item;

            # if we can drop the item, drop it!
            if (!TAEB->is_checking('inventory')) {
                # $item will be undef for non-inventory items like gold
                my $drop = TAEB->ai->drop($item || $new_item);

                # dropping a part of the stack
                if (ref($drop) && $$drop < $item->quantity) {
                    my $new_item = $item->fork_quantity($$drop);
                    TAEB->send_message('floor_item' => $new_item);
                    return $$drop;
                }
                # dropping the whole stack
                elsif ($drop) {
                    TAEB->inventory->remove($slot) if $item;
                    TAEB->send_message('floor_item' => $item);
                    return 'all';
                }
            }

            return 0;
        };

        $committer = sub {
            for my $slot (keys %dont_have) {
                my $item = TAEB->inventory->get($slot);
                if ($item) {
                    TAEB->log->scraper("$item seems to have disappeared!",
                                       level => 'warning');
                    TAEB->inventory->remove($slot);
                }
            }
            $menu->commit;
        };
    }

    return unless $menu->has_menu;

    until ($menu->at_end) {
        TAEB->write($menu->next);
        TAEB->process_input(0);
    }

    $menu->select_quantity($selector) if $selector;

    TAEB->write($committer->());
    _recurse;
}

sub handle_fallback {
    my $self = shift;
    my $topline = TAEB->topline;
    $topline =~ s/\s+$/ /;

    my $response_needed = TAEB->vt->y == 0
                       || (TAEB->vt->y == 1 && TAEB->vt->x == 0);

    # Prompt that spills onto the next line
    if (!$response_needed && TAEB->vt->y == 1) {
        my $row_one = TAEB->vt->row_plaintext(1);
        $row_one =~ s/\s+$//;

        # NetHack clears the rest of the line when it continues the prompt
        # to the next line. We need to be strict here to avoid false positives
        if ($row_one =~ /^\S/ && length($row_one) == TAEB->vt->x - 1) {
            TAEB->log->scraper("Appending '$row_one' to the topline since it appears to be a continuation.");
            $topline .= $row_one;

            $response_needed = 1;
        }
    }

    $self->messages($self->messages . '  ' . $topline);

    if ($response_needed) {
        my $response = TAEB->get_response($topline);
        if (defined $response) {
            $self->messages($self->messages . $response);
            TAEB->write($response);
            _recurse;
        }
        else {
            $self->messages($self->messages . "(escaped)");
            TAEB->write("\e");
            TAEB->log->scraper("Escaped out of unhandled prompt: " . $topline, level => 'warning');
            _recurse;
        }
    }
}

sub handle_location_request {
    my $self = shift;

    return unless $self->messages =~
        /(?:^\s*|  )(.*?)  \(For instructions type a \?\)\s*$/;
    my $type = $1;

    my $dest = TAEB->get_location_request($type);
    if (defined $dest) {
        $self->messages($self->messages . sprintf "(%d, %d)",
                                                  $dest->x, $dest->y);
        TAEB->write(crow_flies(TAEB->vt->x, TAEB->vt->y,
                               $dest->x, $dest->y) . ".");
        _recurse;
    }
    else {
        $self->messages($self->messages . "(escaped)");
        TAEB->write("\e");
        TAEB->log->scraper("Escaped out of unhandled location request: " . $type, level => 'warning');
        _recurse;
    }
}

sub handle_game_end {
    my $self = shift;

    if (TAEB->topline =~ /^Do you want your possessions identified\?|^Die\?|^Really quit\?|^Do you want to see what you had when you died\?/) {
        TAEB->state('dying');
        TAEB->write('y');
        TAEB->log->scraper("Oh no! We died!");
        TAEB->death_state('inventory');
        _recurse;
    }
    elsif (TAEB->state ne 'dying' && TAEB->topline =~ /Final Attributes:\s*$/) {
        TAEB->state('dying');
        TAEB->log->scraper("Oh no! We died! With empty inventory.");
    }

    if (TAEB->topline =~ /^Really save\?/) {
        TAEB->log->scraper("Trying to do a clean save-and-exit shutdown...");
        TAEB->write('y');
        die "The game has been saved.\n";
    }

    return unless TAEB->state eq 'dying';

    if (TAEB->topline =~ /^Save bones\?|^Dump core\?/) {
        TAEB->write('n');
        _recurse;
    }

    if (TAEB->topline =~ /Final Attributes:\s*$/) {
        TAEB->death_state('attributes');

        # XXX: parse attributes

        TAEB->write(' ');
        _recurse;
    }
    elsif (TAEB->topline =~ /Vanquished creatures:\s*$/) {
        TAEB->death_state('kills');

        # XXX: parse kills

        TAEB->write(' ');
        _recurse;
    }
    elsif (TAEB->topline =~ /Voluntary challenges:\s*$/) {
        TAEB->death_state('conducts');

        # We parse conducts in handle_more_menus

        TAEB->write(' ');
        _recurse;
    }
    elsif (TAEB->topline =~ /^(Fare thee well|Sayonara|Aloha|Farvel|Goodbye) /) {
        TAEB->death_state('summary');

        TAEB->death_report->score($1)
            if TAEB->vt->row_plaintext(2) =~ /(\d+) points?/;

        TAEB->death_report->turns($1)
            if TAEB->vt->row_plaintext(3) =~ /(\d+) moves?/;

        # summary is always one page, so after that is high scores with no
        # "press space to close nethack"
        TAEB->write(' ');
        TAEB->interface->flush;

        # at this point the nethack process has now ended

        die "The game has ended.\n";
    }
    # No easy thing to check for here, so assume death_state isn't lying to us
    elsif (TAEB->death_state eq 'inventory') {
        TAEB->write(' ');

        # XXX: parse inventory

        _recurse;
    }
    # No easy thing to check for on subsequent pages, so again assume
    # death_state is honest
    elsif (TAEB->death_state eq 'kills') {
        TAEB->write(' ');

        # XXX: parse kills

        _recurse;
    }

    die "We're dying but I don't understand the message " . TAEB->topline;
}

sub all_messages {
    my $self = shift;
    local $_ = $self->messages;
    # XXX: hack here: replacing all spaces in an engraving with underscores
    # so that our message parsing (which just splits on double spaces)
    # doesn't explode
    s{You read: +"(.*)"\.}{
        (my $copy = $1) =~ tr/ /_/;
        q{You read: "} . $copy . q{".}
    }e;
    s/\s+ /  /g;

    my @messages = grep { length }
                   map { (my $trim = $_) =~ s/^\s+//; $trim =~ s/\s+$//; $trim }
                   split /  /, $_;
    return join $_[0], @messages
        if @_;
    return @messages;
}

sub send_messages {
    my $self = shift;

    for my $line ($self->all_messages) {
        study $line;
        my @messages;

        if (exists $msg_string{$line}) {
            push @messages, [
                map { ref($_) eq 'CODE' ? $_->() : $_ }
                @{ $msg_string{$line} }
            ];
        }

        for my $something (@msg_regex) {
            if ($line =~ $something->[0]) {
                push @messages, [
                    map { ref($_) eq 'CODE' ? $_->() : $_ }
                    @{ $something->[1] }
                ];
            }
        }

        push @messages, TAEB::Announcement->announcements_for_message($line);

        if (@messages) {
            my $msg_names = join ', ',
                            map { "'$_'" }
                            map {
                                blessed($_) && $_->isa('TAEB::Announcement')
                                ? $_->name : $_->[0]
                            } @messages;

            TAEB->log->scraper("Announcing $msg_names in response to '$line'");

            for (@messages) {
                if (blessed($_) && $_->isa('TAEB::Announcement')) {
                    TAEB->announce($_);
                }
                else {
                    TAEB->send_message(@$_);
                }
            }
        }
        else {
            TAEB->log->scraper("I don't understand this message: $line");
        }

        push @{ $self->parsed_messages }, [$line => scalar @messages];
        push @{ $self->old_messages }, $line;
        shift @{ $self->old_messages } if @{ $self->old_messages } > 100;
    }
}

sub farlook {
    my $self = shift;
    my $tile = shift;

    my $directions = crow_flies($tile->x, $tile->y);

    # Clear the messsages buffer so that it isn't double-parsed.
    my @parsed = $self->parsed_messages;
    TAEB->messages('');

    TAEB->write(';' . $directions . '.');
    TAEB->process_input;

    # use TAEB->messages as it may consist of multiple lines
    my $description = TAEB->messages;
    @{ $self->parsed_messages } = @parsed; #hide from UI

    return $description =~ /^(.)\s*(.*?)\s*\((.*)\)\s*(?:\[(.*)\])?\s*$/
        if wantarray;
    return $description;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head2 send_messages

Iterate over all_messages, invoking TAEB->send_message for each one we know
about.

=head2 farlook Int, Int -> (Str | Str, Str, Str, Str)

This will farlook (the C<;> command) at the given coordinates and return
whatever's there.

In scalar context, it will return the plain description string given by
NetHack. In list context, it will return the components: glyph, genus, species,
and how the monster is visible (infravision, telepathy, etc).

WARNING: Since this method interacts with NetHack directly, you cannot use it
in callbacks where there is menu interaction or (in general) any place except
command mode.

=cut

