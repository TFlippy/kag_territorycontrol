void onInit(CBlob@ this)
{
	this.addCommandID("use");

	if (isServer() && !this.exists("value")) this.set_u16("value", XORRandom(50000));
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(12, Vec2f(0, 0), this, this.getCommandID("use"), "Scratch!", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("use"))
	{
		if (this.hasTag("scratched")) return;

		// const int rand = XORRandom(30000);
		const int rand = this.get_u16("value");
		// const int log = (Maths::Log(rand) / 2) * 2000; // Dafuq is wrong with KAG's Log()
		// const int amount = Maths::Min(10000, Maths::Max(10000 - (log), 0));
		// print("a: " + amount + "; log: " + log + "; rand: " + rand);

		const int amount = int(Maths::Clamp((2500000.0f / (rand + 240.0f)) - 50, 0, 10000));
		//print("a: " + amount + "; rand: " + rand);

		if (isClient())
		{
			if (amount <= 0) this.getSprite().PlaySound("depleted.ogg", 0.80f, 0.80f);
			else if (amount <= 1000) this.getSprite().PlaySound("LotteryTicket_Kaching.ogg", 0.80f, 1.00f);
			else if (amount <= 7500) this.getSprite().PlaySound("AchievementUnlocked.ogg", 1.00f, 1.00f);
			else 
			{
				this.getSprite().PlaySound("FanfareWin.ogg", 1.50f, 1.00f);

				CBlob@ caller = getBlobByNetworkID(params.read_u16());
				if (caller !is null && caller.getPlayer() !is null) client_AddToChat("" + caller.getPlayer().getCharacterName() + " has won the Grand IPL Lottery Ticket prize worth " + amount + " coins!", SColor(255, 255, 100, 0));
			}
		}

		if (isServer())
		{
			server_DropCoins(this.getPosition(), amount);
			this.server_Die();
		}

		this.Tag("scratched");
	}
}

void onDie(CBlob@ this)
{
	this.getSprite().Gib();
}
