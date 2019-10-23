void onTick(CBlob@ this){

	// if(isServer())
	// if (getGameTime() % 30 == 0){
	
		// if(this.getInventoryBlob() !is null)
		// this.getInventoryBlob().server_Heal(0.25f);
	
	// }

	if(this.getInventoryBlob() !is null)
	this.getInventoryBlob().Tag("bubblegem");
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	
	inv.doTickScripts = true;
}