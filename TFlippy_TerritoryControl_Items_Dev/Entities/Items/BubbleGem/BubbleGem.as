void onTick(CBlob@ this){

	if (getGameTime() % 60 == 0)
	{
		if (this.getInventoryBlob() !is null) //Harder to use for automation since blob needs to be in water to heal
		{
			CBlob@ inv = this.getInventoryBlob();
			if (inv.isInWater() && inv.hasTag("flesh"))
			{
				if (isServer()) inv.server_Heal(0.5f); //Healing amount is doubled from 0.25 but it only ticks every 60 ticks
			}
			else //Hiccups
			{
				inv.AddForce(Vec2f(XORRandom(3)-1,-1) * inv.getMass()); //While you arent in water it will move you around a bit (with enough you will flop around like a fish on land)
			}
		}
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	
	inv.doTickScripts = true;
}