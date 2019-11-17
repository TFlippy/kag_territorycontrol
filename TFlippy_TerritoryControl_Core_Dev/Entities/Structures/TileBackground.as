// Blame Fuzzle.

#define SERVER_ONLY

void onSetStatic(CBlob@ this, const bool isStatic)
{

	if (!isStatic)
		return;

	if (this.exists("background tile"))
	{

		CMap@ map = getMap();
		Vec2f position = this.getPosition();
		const u16 type = this.get_TileType("background tile");

		if (map.getTile(position).type < type) //implies that higher type means harder material (and who ever sets broken tiles as background?)
			map.server_SetTile(position, type);

	}

	this.getCurrentScript().runFlags |= Script::remove_after_this;

}
