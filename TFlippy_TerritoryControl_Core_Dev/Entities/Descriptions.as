// item description

const string[] descriptions =
{
	/* 00  */               "",
	/* 01  */               "Bombs for Knight only.",   // bomb
	/* 02  */               "Arrows for Archer and mounted bow.",         // arrows
	/* 03  */               "",                     //
	/* 04  */               "Highly explosive powder keg for Knight only.",                  // keg
	/* 05  */               "A stone throwing, ridable siege engine, requiring a crew of two.", // catapult
	/* 06  */               "A bolt-firing pinpoint accurate siege engine, requiring a crew of two. Allows respawn and class change.",     //ballista
	/* 07  */               "Raw stone material.",                                        // stone
	/* 08  */               "Raw wood material.",                                           // wood
	/* 09  */               "Lanterns help with mining in the dark, and lighten the mood.",                         // lantern
	/* 10  */               "A small boat with two rowing positions and a large space for cargo.",     // dinghy
	/* 11  */               "A siege engine designed to break open walls and fortifications.",         // ram
	/* 12  */               "A mill saw turns tree logs into wood material.",                             // saw
	/* 13  */               "A trading post. Requires a trader to reside inside.", // tradingpost
	/* 14  */               "Excalibur is the legendary sword of King Arthur, attributed with magical powers to conquer all enemies.",  // excalibur
	/* 15  */               "Piercing bolts for ballista.", // mat_bolts
	/* 16  */               "A simple wooden ladder for climbing over defenses.", // ladder
	/* 17  */               "A stone boulder useful for crushing enemies.", // boulder
	/* 18  */               "An empty wooden crate for storing and transporting inventory.", // crate
	/* 19  */               "",
	/* 20  */               "An explosive mine. Triggered by contact with an enemy.", // mine
	/* 21  */               "Fire satchel for Knight only.", // satchel
	/* 22  */               "A health regenerating heart.", // heart
	/* 23  */               "A sack for storing more inventory on your back.", // sack
	/* 24  */               "A seedling of an oak tree ready for planting.", // tree_bushy
	/* 25  */               "A seedling of a pine tree ready for planting.", // tree_pine
	/* 26  */               "A decorative flower seedling.", // flower
	/* 27  */               "Grain used as food.", // grain
	/* 28  */               "Wooden swing door.", // wooden_door
	/* 29  */               "Stone spikes used as a defense around fortifications.", // spikes
	/* 30  */               "A trampoline used for bouncing and jumping over enemy walls.", // trampoline
	/* 31  */               "A stationary arrow-firing death machine.", // mounted_bow
	/* 32  */               "Fire arrows used to set wooden structures on fire.", // fire arrows
	/* 33  */               "A fast rowing boat used for quickly getting across water.", // longboat
	/* 34  */               "A tunnel for quick transportation.", // tunnel
	/* 35  */               "", //
	/* 36  */               "Bucket for storing water. Useful for fighting fires.", //bucket
	/* 37  */               "A slow armoured boat which acts also as a water base for respawn and class change.", // warboat
	/* 38  */               "A generic factory. Requires Research Room, technology upgrade and big enough population to produce items.", //
	/* 39  */               "Kitchen produces food which heal wounds.", //  kitchen
	/* 40  */               "A plant nursery with grain, oak and pine tree seeds.", //  nursery
	/* 41  */               "Barracks allow changing class to Archer or Knight.", //  barracks
	/* 42  */               "A storage than can hold materials and items and share them with other storages.", //  storage
	/* 43  */               "A mining drill. Increases speed of digging and gathering resources, but gains only half the possible resources.", //  drill
	/* 44  */               "Bombs for Knights & arrows for Archers.\nAutomatically distributed on respawn.", //  military basics
	/* 45  */               "Items used for blowing stuff up.", //  explosives
	/* 46  */               "Items used for lighting things on fire.", //  pyro
	/* 47  */               "When team is in possession of stone construction technology it allows builders to make stone walls, doors, traps and spikes.", //  stone tech
	/* 48  */               "Dorm increases population count and allows spawning and healing inside. Requires a migrant.", //  dorm
	/* 49  */               "Research room.", //  research
	/* 50  */               "Water arrows for Archer. Can extinguish fires and stun enemies.",         // water arrows
	/* 51  */               "Bomb arrows for Archer.",         // bomb arrows
	/* 52  */               "Water bomb for Knight. Can extinguish fires and stun enemies.",         // water bomb
	/* 53  */               "Water absorbing sponge. Useful for unflooding tunnels and reducing water stuns.",         // sponge

	/* 54  */               "Builder workshop for building utilities and changing class to Builder",         // buildershop
	/* 55  */               "Knight workshop for building explosives and changing class to Knight",         // Knightshop
	/* 56  */               "Archer workshop for building arrows and changing class to Archer",         // Archershop
	/* 57  */               "Siege workshop for building wheeled siege engines",         // vehicleshop
	/* 58  */               "Naval workshop for building boats",         // boatshop
	/* 59  */               "Place of merriment and healing",         // quarters/inn
	/* 60  */               "A Cache for storing your materials, items and armaments.",         // storage cache
};

namespace Descriptions
{
	const string
	bomb                       = getTranslatedString("Bombs for Knight only."),
	waterbomb                  = getTranslatedString("Water bomb for Knight. Can extinguish fires and stun enemies."),
	mine                       = getTranslatedString("An explosive mine. Triggered by contact with an enemy."),
	keg                        = getTranslatedString("Highly explosive powder keg for Knight only."),
	satchel                    = getTranslatedString("Fire satchel for Knight only."), //OLD

	arrows                     = getTranslatedString("Arrows for Archer and mounted bow."),
	waterarrows                = getTranslatedString("Water arrows for Archer. Can extinguish fires and stun enemies."),
	firearrows                 = getTranslatedString("Fire arrows used to set wooden structures on fire."),
	bombarrows                 = getTranslatedString("Bomb arrows for Archer."),

	ram                        = getTranslatedString("A siege engine designed to break open walls and fortifications."), //OLD
	catapult                   = getTranslatedString("A stone throwing, ridable siege engine, requiring a crew of two."),
	ballista                   = getTranslatedString("A bolt-firing pinpoint accurate siege engine, requiring a crew of two. Allows respawn and class change."),
	ballista_ammo              = getTranslatedString("Piercing bolts for ballista."),
	ballista_bomb_ammo         = getTranslatedString("Explosive bolts for ballista."),

	stone                      = getTranslatedString("Raw stone material."),
	wood                       = getTranslatedString("Raw wood material."),

	lantern                    = getTranslatedString("Lanterns help with mining in the dark, and lighten the mood."),
	bucket                     = getTranslatedString("Bucket for storing water. Useful for fighting fires."),
	filled_bucket              = getTranslatedString("A wooden bucket pre-filled with water for fighting fires."),
	sponge                     = getTranslatedString("Water absorbing sponge. Useful for unflooding tunnels and reducing water stuns."),
	boulder                    = getTranslatedString("A stone boulder useful for crushing enemies."),
	trampoline                 = getTranslatedString("A trampoline used for bouncing and jumping over enemy walls."),
	saw                        = getTranslatedString("A circular saw that turns tree logs into wood material."),
	drill                      = getTranslatedString("A mining drill. Increases speed of digging and gathering resources, but gains only half the possible resources."),
	crate                      = getTranslatedString("An empty wooden crate for storing and transporting inventory."),
	food                       = getTranslatedString("For healing. Don't think about this too much."),

	tradingpost                = getTranslatedString("A trading post. Requires a trader to reside inside."),
	excalibur                  = getTranslatedString("Excalibur is the legendary sword of King Arthur, attributed with magical powers to conquer all enemies."),
	ladder                     = getTranslatedString("A simple wooden ladder for climbing over defenses."),


	heart                      = getTranslatedString("A health regenerating heart."),
	sack                       = getTranslatedString("A sack for storing more inventory on your back."), //OLD
	tree_bushy                 = getTranslatedString("A seedling of an oak tree ready for planting."),
	tree_pine                  = getTranslatedString("A seedling of a pine tree ready for planting."),
	flower                     = getTranslatedString("A decorative flower seedling."),
	grain                      = getTranslatedString("Grain used as food."),
	wooden_door                = getTranslatedString("Wooden swing door."),
	spikes                     = getTranslatedString("Stone spikes used as a defense around fortifications."),

	mounted_bow                = getTranslatedString("A stationary arrow-firing death machine."),
	dinghy                     = getTranslatedString("A small boat with two rowing positions and a large space for cargo."),
	longboat                   = getTranslatedString("A fast rowing boat used for quickly getting across water."),
	warboat                    = getTranslatedString("A slow armoured boat which acts also as a water base for respawn and class change."),
	tunnel                     = getTranslatedString("A tunnel for quick transportation."),


	factory                    = getTranslatedString("A generic factory. Requires Research Room, technology upgrade and big enough population to produce items."), //OLD
	kitchen                    = getTranslatedString("Kitchen produces food which heal wounds."), //OLD
	nursery                    = getTranslatedString("A plant nursery with grain, oak and pine tree seeds."), //OLD
	barracks                   = getTranslatedString("Barracks allow changing class to Archer or Knight."), //OLD
	storage                    = getTranslatedString("A storage than can hold materials and items and share them with other storages."), //OLD

	militarybasics             = getTranslatedString("Bombs for Knights & arrows for Archers.\nAutomatically distributed on respawn."),
	explosives                 = getTranslatedString("Items used for blowing stuff up."),
	pyro                       = getTranslatedString("Items used for lighting things on fire."),
	stonetech                  = getTranslatedString("When team is in possession of stone construction technology it allows builders to make stone walls, doors, traps and spikes."), //OLD
	dorm                       = getTranslatedString("Dorm increases population count and allows spawning and healing inside. Requires a migrant."), //OLD
	research                   = getTranslatedString("Research room."), //OLD
	buildershop                = getTranslatedString("Builder workshop for building utilities and changing class to Builder"),
	knightshop                 = getTranslatedString("Knight workshop for building explosives and changing class to Knight"),
	archershop                 = getTranslatedString("Archer workshop for building arrows and changing class to Archer"),
	vehicleshop                = getTranslatedString("Siege workshop for building wheeled siege engines"),
	boatshop                   = getTranslatedString("Naval workshop for building boats"),
	quarters                   = getTranslatedString("Place of merriment and healing"),
	storagecache               = getTranslatedString("A Cache for storing your materials, items and armaments."),
	quarry               	   = getTranslatedString("A Quarry intended to mine stone, fueled by wood."),

	//Quarters.as
	beer                       = getTranslatedString("A refreshing mug of beer."),
	meal                       = getTranslatedString("A hearty meal to get you back on your feet."),
	egg                        = getTranslatedString("A suspiciously undercooked egg, maybe it will hatch."),
	burger                     = getTranslatedString("A burger to go."),

	//Magic Scrolls
	scroll_carnage             = getTranslatedString("This magic scroll when cast will turn all nearby enemies into a pile of bloody gibs."),
	scroll_drought             = getTranslatedString("This magic scroll will evaporate all water in a large surrounding orb.");
}