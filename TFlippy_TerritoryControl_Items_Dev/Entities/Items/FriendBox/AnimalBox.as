#include "LootSystem.as";
// Mysterybox.as
// name, amount, bonus, weight
LootItem@[] c_items =
{
	LootItem("chicken", 1, 2, 750),
	LootItem("piglet", 1, 1, 500),
	LootItem("kitten", 1, 1, 600),
	LootItem("shark", 1, 1, 200),
	LootItem("bison", 1, 1, 170),
	LootItem("badger", 1, 1, 400),
	LootItem("landfish", 1, 1, 300),
	LootItem("badgerbomb", 1, 1, 150),
	LootItem("pigger", 1, 2, 80),
	LootItem("cowo", 1, 1, 35),
	//LootItem("bagel", 1, 1, 130),
	LootItem("fishy", 1, 2, 650),
	LootItem("pus", 1, 1, 20),
	LootItem("trader", 1, 1, 75),
	LootItem("hobo", 1, 1, 40),
	LootItem("pirategull", 1, 1, 70),
	LootItem("princess", 1, 1, 30),
	LootItem("scoutchicken", 1, 1, 10),
	LootItem("mithrilman", 1, 1, 7)
	//LootItem("mithrilguy", 1, 1, 5)
};

void onInit(CBlob@ this)
{
	this.addCommandID("box_unpack");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	caller.CreateGenericButton(12, Vec2f(0, 0), this, this.getCommandID("box_unpack"), "Unpack");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("box_unpack"))
	{
		if (isServer())
		{
			if (this.hasTag("unpacked")) return;
			
			//print(c_items[0].blobname);
			server_SpawnRandomItem(this, @c_items);

			this.server_Die();
		}

		this.Tag("unpacked");
	}
}

void onDie(CBlob@ this)
{
	if(!isClient()){return;}
	this.getSprite().Gib();
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();

	string fname = "Crate.png";
	for (int i = 0; i < 4; i++)
	{
		makeGibParticle(fname, pos, vel + getRandomVelocity(90, 1 , 120), 9, 2 + i, Vec2f(16, 16), 2.0f, 20, "Sounds/material_drop.ogg", 0);
	}
}
