void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 15 + XORRandom(45);
}

void onTick(CBlob@ this){

	if (isServer())
	{
		CBlob@[] blobs;
		getMap().getBlobsInBox(this.getPosition() + Vec2f(48, -48), this.getPosition() + Vec2f(-48, 48), @blobs);
	
		int counter = 0;
	
		for (int i = 0; i < blobs.length; i++) if (blobs[i].getName() == "methane") counter++;

		if (counter < 4)
		{
			CBlob@ blob = server_CreateBlob("methane", this.getTeamNum(), this.getPosition() + getRandomVelocity(0, XORRandom(16), 360));
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