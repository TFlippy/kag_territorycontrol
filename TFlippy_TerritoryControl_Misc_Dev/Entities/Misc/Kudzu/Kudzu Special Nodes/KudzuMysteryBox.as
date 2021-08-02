#include "KudzuCommon.as"
#include "LootSystem.as";

void onInit(CBlob @ this)
{
	this.SetLight(true);
	this.SetLightRadius(30.0f);
	this.SetLightColor(SColor(255, 255, 255, 255));
}

void onDie(CBlob@ this)
{
	server_SpawnRandomItem(this, @c_items);
}

// name, amount, bonus, weight
LootItem@[] c_items = //Same as the mystery box EXCEPT no badgers and no gold ore
{
	LootItem("mat_stone", 25, 1000, 800),
	LootItem("mat_wood", 25, 1000, 700),
	LootItem("mat_sulphur", 20, 250, 550),
	LootItem("mat_coal", 10, 100, 600),
	LootItem("rifle", 1, 1, 170),
	LootItem("revolver", 1, 2, 248),
	LootItem("smg", 1, 1, 198),
	LootItem("mysterybox", 1, 3, 780),
	LootItem("egg", 1, 2, 750),
	LootItem("landfish", 1, 1, 450),
	LootItem("cowo", 0, 1, 55),
	LootItem("chicken", 1, 2, 125),
	LootItem("mat_mithril", 0, 100, 250),
	LootItem("lantern", 1, 1, 500),
	LootItem("bomb", 1, 2, 675),
	LootItem("mine", 1, 2, 475),
	LootItem("keg", 1, 1, 122),
	LootItem("automat", 1, 0, 76),
	LootItem("mat_bombita", 1, 0, 27),
	LootItem("mat_incendiarybomb", 2, 4, 103),
	LootItem("mat_smallbomb", 4, 16, 247),
	LootItem("rocket", 1, 0, 468),
	LootItem("scoutchicken", 1, 1, 50),
	LootItem("mat_oil", 10, 50, 720),
	LootItem("mat_copperingot", 3, 25, 405),
	LootItem("mat_ironingot", 5, 25, 358),
	LootItem("mat_goldingot", 1, 25, 105),
	LootItem("mat_steelingot", 5, 25, 254),
	LootItem("artisancertificate", 1, 1, 574),
	LootItem("mat_mithrilingot", 5, 25, 61),
	LootItem("badgerden", 1, 1, 154),
	LootItem("card_pack", 1, 2, 404),
	LootItem("heart", 1, 5, 743),
	LootItem("food", 1, 2, 645),
	LootItem("ratburger", 1, 3, 740),
	LootItem("bucket", 1, 2, 242),
	LootItem("sponge", 1, 2, 227),
	LootItem("mat_rifleammo", 5, 20, 724),
	LootItem("mat_pistolammo", 10, 60, 754),
	LootItem("mat_smallrocket", 1, 10, 275),
	LootItem("bazooka", 1, 0, 164),
	LootItem("shotgun", 1, 0, 197),
	LootItem("flamethrower", 0, 1, 179),
	LootItem("mat_shotgunammo", 4, 16, 674),
	LootItem("steamtank", 1, 0, 42),
	LootItem("armoredbomber", 1, 0, 22),
	LootItem("phone", 1, 0, 21),
	LootItem("scyther", 1, 0, 5), // lolz
	LootItem("infernalstone", 1, 0, 23),
	LootItem("scubagear", 1, 0, 499),
	LootItem("ninjascroll", 1, 1, 250),
	LootItem("puntgun", 1, 1, 225),
	LootItem("juggernauthammer", 1, 1, 50),
	LootItem("gyromat", 1, 1, 500),
	LootItem("bp_chemistry", 1, 1, 175),
	LootItem("hobo", 1, 1, 122),
	LootItem("cube", 1, 0, 1) //poggers
};

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}