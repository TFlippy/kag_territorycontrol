
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
	topleft.x += 1.0f;
	Vec2f botleft = Vec2f(topleft.x,botright.y);

	CMap@ map = getMap();
	const f32 tilesize = map.tilesize;

	Vec2f tpos = botleft;
	bool hasEmpty = false;
	while (tpos.x < botright.x){
		if (map.isTileSolid(tpos) || map.hasTileSolidBlobs(map.getTile(tpos))){
			return;

		}
		tpos.x += tilesize;
	}


	this.server_Die();
}

