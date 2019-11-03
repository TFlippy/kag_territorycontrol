#include "Hitters.as";
#include "HittersTC.as";
#include "LimitedAttacks.as";
#include "Knocked.as"

const int pierce_amount = 8;

const f32 hit_amount_ground = 0.5f;
const f32 hit_amount_air = 1.0f;
const f32 hit_amount_air_fast = 3.0f;
const f32 hit_amount_cata = 10.0f;

void onInit(CBlob @ this)
{
	this.Tag("medium weight");

	LimitedAttack_setup(this);

	this.set_u8("blocks_pierced", 0);
	u32[] tileOffsets;
	this.set("tileOffsets", tileOffsets);

	// damage
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 3;
	
	if (isClient())
	{
		if (this.getName() == "corpsetrader")
		{
			this.getSprite().PlaySound("trader_death.ogg");
		}
		else
		{
			this.getSprite().PlaySound("Wilhelm.ogg");
		}
	}
}


bool BoulderHitMap(CBlob@ this, Vec2f worldPoint, int tileOffset, Vec2f velocity, f32 damage, u8 customData)
{
	//check if we've already hit this tile
	u32[]@ offsets;
	this.get("tileOffsets", @offsets);

	if (offsets.find(tileOffset) >= 0) { return false; }

	this.getSprite().PlaySound("ArrowHitGroundFast.ogg");
	f32 angle = velocity.Angle();
	CMap@ map = getMap();
	TileType t = map.getTile(tileOffset).type;
	u8 blocks_pierced = this.get_u8("blocks_pierced");
	bool stuck = false;

	if (map.isTileCastle(t) || map.isTileWood(t))
	{
		Vec2f tpos = this.getMap().getTileWorldPosition(tileOffset);
		if (map.getSectorAtPosition(tpos, "no build") !is null)
		{
			return false;
		}

		//make a shower of gibs here

		map.server_DestroyTile(tpos, 100.0f, this);
		Vec2f vel = this.getVelocity();
		this.setVelocity(vel * 0.8f); //damp
		this.push("tileOffsets", tileOffset);

		if (blocks_pierced < pierce_amount)
		{
			blocks_pierced++;
			this.set_u8("blocks_pierced", blocks_pierced);
		}
		else
		{
			stuck = true;
		}
	}
	else
	{
		stuck = true;
	}

	if (velocity.LengthSquared() < 5)
	{
		stuck = true;
	}

	if (stuck)
	{
		KillThis(this,worldPoint);
	}

	return stuck;
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (solid && blob !is null)
	{
		Vec2f hitvel = this.getOldVelocity();
		Vec2f hitvec = point1 - this.getPosition();

		f32 vellen = hitvel.Length();

		if(blob.getTeamNum()==this.getTeamNum())
		{
			return;
		}

		//get the dmg required
		hitvel.Normalize();
		f32 dmg = 2.5f;
		//hurt
		blob.AddForce(hitvel*400.0f);
		this.server_Hit(blob, point1, hitvel, dmg, Hitters::fall, true);
		SetKnocked(blob,90);
		KillThis(this,point1);
	}
	if(blob is null){
		KillThis(this,point1);
	}
}

void KillThis(CBlob@ this,Vec2f worldPoint){
	if(isServer()){
		CPlayer@ player=	this.getPlayer();
		if(player !is null){
			CPlayer@ owner=		this.getDamageOwnerPlayer();
			if(owner !is null){
				getRules().server_PlayerDie(player,owner,Hitters::crush);
			}else{
				getRules().server_PlayerDie(player);
			}
		}else{
			this.server_Die();
		}
	}
}

void onDie(CBlob@ this)
{
	this.getShape().SetVelocity(Vec2f(0.0f,-1.5f));
	this.getSprite().Gib();
	if(isClient()){
		for(int i=0;i<5;i++){
			Vec2f pos=Vec2f(XORRandom(16)-8,XORRandom(16)-8);
			if(pos.Length()>=8.0f){
				pos.Normalize();
				pos*=8.0f;
			}
			ParticleBloodSplat(this.getPosition()+pos,true);
		}
		for(int i=0;i<16;i++){
			Vec2f pos=Vec2f(XORRandom(40)-20,XORRandom(40)-20);
			if(pos.Length()>=20.0f){
				pos.Normalize();
				pos*=20.0f;
			}
			ParticleBloodSplat(this.getPosition()+pos,false);
		}
		Sound::Play("Gore.ogg",this.getPosition(),1.0f);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::sword || customData == Hitters::arrow)
	{
		return damage *= 0.5f;
	}

	return damage;
}


//sprite

void onInit(CSprite@ this)
{
	
}

void onTick(CBlob@ this)
{
	//stuck fix

	if(this.isAttached()){
		return;
	}

	if(this.getVelocity() == Vec2f(0,0))
	{
		if(isServer())
		{
			print("time to die");
			this.server_Die();
		}
	}
	else
	{
		CSprite@ sprite = this.getSprite();
		if(sprite !is null)
		{
			sprite.SetFacingLeft(this.getVelocity().x<0.0f);
			sprite.RotateBy(10.0f,Vec2f());
		}
	}
}