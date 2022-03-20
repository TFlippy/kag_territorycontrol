
#define SERVER_ONLY

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 35;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick(CBlob@ this)
{
	Vec2f topleft, botright;
	this.getShape().getBoundingRect(topleft, botright);
	//topleft.x += 1.0f;

	CMap@ map = getMap();
	const f32 tilesize = map.tilesize;

	Vec2f tpos = topleft;
	bool hasEmpty = false;
	while (tpos.y < botright.y+tilesize){
		while (tpos.x < botright.x){
			if (map.getTile(tpos).type > 0){
				return;

			}
			tpos.x += tilesize;
		}
		tpos.x = topleft.x;
		tpos.y += tilesize;
	}


	this.server_Die();
}

