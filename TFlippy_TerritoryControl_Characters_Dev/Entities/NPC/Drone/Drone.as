// Princess brain

#include "BrainCommon.as"
#include "Hitters.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
//#include "LoaderUtilities.as";
#include "CustomBlocks.as";
#include "Knocked.as";

const f32 altitude_goal = 250.00f;

const string[] particles = 
{
	"LargeSmoke",
	"Explosion.png",
	"LargeFire.png",
	"FireFlash.png",
};

void onInit( CBrain@ this )
{
	if (isServer())
	{
		InitBrain( this );
		this.server_SetActive( true ); // always running
	}
}

void onInit(CBlob@ this)
{
	this.getSprite().addSpriteLayer("isOnScreen","NoTexture.png",1,1);
	this.set_u32("next sound", 0);

	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 20, 0));

	this.set_string("custom_explosion_sound", "bombita_explode.ogg");
	this.set_bool("map_damage_raycast", true);
	this.set_Vec2f("explosion_offset", Vec2f(0, 0));
	
	this.set_f32("bomb angle", 90);
	this.Tag("map_damage_dirt");
		
	this.set_u32("nextAttack", 0);

	this.set_f32("minDistance", 48);
	this.set_f32("chaseDistance", 256);
	this.set_f32("maxDistance", 512);
	
	this.set_f32("inaccuracy", 0.00f);
	this.set_u8("reactionTime", 0);
	this.set_u8("attackDelay", 0);
	
	this.SetDamageOwnerPlayer(null);
	
	this.Tag("npc");
	this.Tag("player");
	
	this.getCurrentScript().tickFrequency = 1;
	
	this.getShape().SetRotationsAllowed(true);
	
	CSprite@ sprite = this.getSprite();
	
	CSpriteLayer@ levitator = sprite.addSpriteLayer("levitator", sprite.getFilename(), 16, 16);
	if (levitator !is null)
	{
		levitator.SetRelativeZ(-1.0f);
		levitator.SetOffset(Vec2f(0, 0));
		levitator.SetFrameIndex(1);
	}
	
	CSpriteLayer@ zap = sprite.addSpriteLayer("zap", "ForceBolt.png", 128, 12);
	if (zap !is null)
	{
		Animation@ anim = zap.addAnimation("default", 1, false);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		anim.AddFrame(5);
		anim.AddFrame(6);
		anim.AddFrame(7);
		zap.SetRelativeZ(-1.0f);
		zap.SetVisible(false);
		zap.setRenderStyle(RenderStyle::light);
		zap.SetOffset(Vec2f(0, 0));
	}
	
	sprite.SetEmitSound("Drone_Levitator.ogg");
	sprite.SetEmitSoundVolume(1.25f);
	sprite.SetEmitSoundPaused(false);
}

void onTick(CBlob@ this)
{
	if(isClient()){
		if(!this.getSprite().getSpriteLayer("isOnScreen").isOnScreen()){
			return;
		}
	}

	CMap@ map = this.getMap();
	Vec2f pos = this.getPosition();
	Vec2f end;
	
	const bool isBot = this.getPlayer() is null;
	
	if (map.rayCastSolid(pos, pos + Vec2f(0, 256), end))
	{
		f32 dist = (end - pos).getLength();
		f32 mod = Maths::Clamp(1.00f - (dist / altitude_goal), 0.65f, 1.00f);
		f32 force = this.getMass() * mod * 0.50f;
		
		this.AddForce(Vec2f(0, -1) * force);
	}

	const bool left = this.isKeyPressed(key_left);
	const bool right = this.isKeyPressed(key_right);
	const bool up = this.isKeyPressed(key_up);
	const bool down = this.isKeyPressed(key_down);

	f32 h = (left ? -1 : 0) + (right ? 1 : 0); 
	f32 v = (up ? -1 : 0) + (down ? 1 : 0); 
	
	Vec2f vel = Vec2f(h, v);
	
	this.AddForce(vel * this.getMass() * 0.50f * (isBot ? 0.25f : 1.00f));
	this.setAngleDegrees(-(this.getAimPos() - this.getPosition()).Angle() + (this.isFacingLeft() ? 180 : 0));
	
	if (this.isKeyPressed(key_action1) && this.get_u32("nextShoot") <= getGameTime())
	{
		Shoot(this);
	}
}

void onTick(CSprite@ this)
{

	if(!this.getSpriteLayer("isOnScreen").isOnScreen()){
		return;
	}

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ levitator = this.getSpriteLayer("levitator");

	levitator.ResetTransform();
	levitator.RotateBy(-blob.getAngleDegrees(), Vec2f_zero);
	levitator.RotateBy(Maths::Sin((getGameTime() * 0.075f) % 180) * 5.0f, Vec2f_zero);
	levitator.SetFrameIndex(1);
	
	this.SetEmitSoundVolume(1.25f);
	this.SetEmitSoundSpeed(0.80f + (Maths::Clamp(blob.getVelocity().getLength() / 5, 0.00f, 1.00f) * 0.50f));
}

void Shoot(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();

	const f32 maxDistance = 256.00f;

	Vec2f dir = this.getAimPos() - this.getPosition();
	dir.Normalize();

	Vec2f hitPos;
	f32 length;
	bool flip = this.isFacingLeft();
	f32 angle = dir.Angle();
	Vec2f startPos = this.getPosition();
	Vec2f endPos = startPos + dir * maxDistance;
					
	bool hit = getMap().rayCastSolid(startPos, endPos, hitPos);
	
	length = (hitPos - startPos).Length() + 8;
	
	if (hit)
	{
		CMap@ map = getMap();
		
		f32 len = (startPos - hitPos).getLength();
		f32 mod = -Maths::Pow(len / maxDistance, 3) + 1;
		
		map.server_DestroyTile(hitPos, 8.00f * mod);	
	}
	
	// ShakeScreen(64, 32, startPos);
	Vec2f force = dir * 200.00f;
	this.AddForce(-force * 0.05f);
	
	HitInfo@[] blobs;
	if (getMap().getHitInfosFromRay(startPos, -angle, maxDistance, this, blobs))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i].blob;
			if (b !is null && b.getTeamNum() != this.getTeamNum() && b.isCollidable())
			{
				f32 len = (startPos - b.getPosition()).getLength();
				f32 mod = -Maths::Pow(len / maxDistance, 3) + 1;
			
				// print("mod: " + mod + "; len: " + len);
			
				if (isServer())
				{
					this.server_Hit(b, b.getPosition(), Vec2f(0, 0), 1.00f * mod, Hitters::crush, true);
				}
				
				b.AddForce(force * 1.50f * mod);
				ShakeScreen(80 * mod, 32 * mod, b.getPosition());
				SetKnocked(b, 30 * mod);
				length = blobs[i].distance + 8;
				
				break;
			}
		}
	}

	if (isClient())
	{
		CSpriteLayer@ zap = this.getSprite().getSpriteLayer("zap");
		if (zap !is null)
		{
			f32 len = length + 16;
		
			zap.ResetTransform();
			zap.SetFrameIndex(0);
			zap.ScaleBy(Vec2f(len / 128.0f, 1.0f));
			zap.TranslateBy(Vec2f(len / 2, 0));
			zap.RotateBy(-this.getAngleDegrees() - angle, Vec2f());
			zap.SetVisible(true);
			zap.SetFacingLeft(false);
			zap.setRenderStyle(RenderStyle::light);
		}

		if (this.isKeyJustPressed(key_action1))
		{
			sprite.PlaySound("/ForceRay_Shoot.ogg", 1.00f, 1.20f);
		}
		
		sprite.PlaySound("ForceRay_Shoot.ogg", 1.00f, 1.00f);
	}
	
	this.set_u32("nextShoot", getGameTime() + 6);
}

void onTick(CBrain@ this)
{
	if (isClient()){ return;}
	
	CBlob@ blob = this.getBlob();
	
	if (blob.getPlayer() !is null){ return;}
	
	const f32 chaseDistance = blob.get_f32("chaseDistance");

	{
		const Vec2f pos = blob.getPosition();
	
		CBlob@[] blobs;
		getBlobsByTag("flesh", @blobs);
		const u8 myTeam = blob.getTeamNum();
		
		f32 dist = 900000.00f;
		s32 closest_id = -1;
		
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			f32 d = Maths::Abs(b.getPosition().x - pos.x);
			
			if (d <= chaseDistance && d < dist && b.getTeamNum() != myTeam && !b.hasTag("dead") && !b.hasTag("invincible"))
			{
				closest_id = b.getNetworkID();
				dist = d;
				
				break;
			}
		}
		
		if (closest_id > 0)
		{
			this.SetTarget(getBlobByNetworkID(closest_id));
			blob.set_u32("nextAttack", getGameTime() + blob.get_u8("reactionTime"));
				
			this.getCurrentScript().tickFrequency = 1;
		}
		else
		{
			this.getCurrentScript().tickFrequency = 30;
		}
	}
	
	CBlob@ target = this.getTarget();
	if (target !is null && target !is blob)
	{			
		this.getCurrentScript().tickFrequency = 1;
		
		Vec2f tdir = target.getPosition() - blob.getPosition();
		const f32 distance = (tdir).Length();
		tdir.Normalize();
		
		const f32 minDistance = blob.get_f32("minDistance");
		const f32 maxDistance = blob.get_f32("maxDistance");
		
		const bool visibleTarget = isVisible(blob, target);
		const bool target_attackable = !(target.getTeamNum() == blob.getTeamNum() || target.hasTag("material"));
		const bool lose = distance > maxDistance;
		const bool chase = distance > minDistance && (distance > chaseDistance || !visibleTarget);
		const bool retreat = distance < minDistance && visibleTarget;
		
		// const bool left = tdir.x > 0;
		
		// blob.setAngleDegrees((left ? 0 : 180) - (tdir).Angle());
		// blob.SetFacingLeft(left);
		
		if (target_attackable)
		{
			if (visibleTarget) 
			{
				blob.setAimPos(target.getPosition());
				blob.setKeyPressed(key_action1, true);
			}
		}
		
		if (lose)
		{
			this.SetTarget(null);
			this.getCurrentScript().tickFrequency = 30;
			return;
		}
		
		if (chase)
		{
			if (getGameTime() % 30 == 0) 
			{
				this.SetPathTo(target.getPosition() + Vec2f(0, -48), true);
			}
			
			Vec2f dir = this.getNextPathPosition() - blob.getPosition();
			dir.Normalize();
			
			Move(this, blob, blob.getPosition() + dir * 16);
		}
		else if (retreat)
		{
			Move(this, blob, blob.getPosition() - tdir * minDistance);
		}

		if (target.hasTag("dead")) 
		{
			this.SetTarget(null);
			this.getCurrentScript().tickFrequency = 30;
			return;
		}
	}
} 

void Move(CBrain@ this, CBlob@ blob, Vec2f pos)
{
	Vec2f dir =  blob.getPosition() - pos;
	dir.Normalize();
	
	blob.setKeyPressed(key_left, dir.x > 0);
	blob.setKeyPressed(key_right, dir.x < 0);
	blob.setKeyPressed(key_up, dir.y > 0);
	blob.setKeyPressed(key_down, dir.y < 0);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") - 50)
		{
			this.getSprite().PlaySound("/scyther-screech" + XORRandom(7) + ".ogg");
			this.set_u32("next sound", getGameTime() + 100);
		}
	}
	
	if (isServer())
	{
		CBrain@ brain = this.getBrain();
		
		if (brain !is null && hitterBlob !is null)
		{
			if (hitterBlob !is this && hitterBlob.getTeamNum() != this.getTeamNum() && !hitterBlob.hasTag("material") && !hitterBlob.hasTag("dead") && !hitterBlob.hasTag("invincible") && hitterBlob.hasTag("flesh")) brain.SetTarget(hitterBlob);
		}
	}
	
	return damage;
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}

	this.Tag("exploded");

	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = -this.get_f32("bomb angle");
	f32 vellen = this.getVelocity().Length();
	
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (16.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.25f);
	
	Explode(this, 16.0f + random, 50.0f);

	for (int i = 0; i < 16 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 80);
		LinearExplosion(this, dir, (16.0f + XORRandom(32) + (modifier * 8)) * vellen, 12 + XORRandom(8), 20 + XORRandom(vellen * 2), 50.0f, Hitters::explosion);
	}
	
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	
	
	if (isServer())
	{
		for (int i = 0; i < 4; i++)
		{
			CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
			blob.server_SetQuantity(5 + XORRandom(25));
			blob.setVelocity(Vec2f(8 - XORRandom(16), -5 - XORRandom(10)) * (0.5f));
		}
		
		for (int i = 0; i < 256; i++)
		{
			Vec2f tpos = getRandomVelocity(angle, 1, 120) * XORRandom(64);
			if (map.isTileSolid(pos + tpos)) map.server_SetTile(pos + tpos, CMap::tile_matter);
		}
		
		CBlob@[] trees;
		this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @trees);
		
		for (int i = 0; i < trees.length; i++)
		{
			CBlob@ b = trees[i];
			
			if (b.getName() == "tree_bushy" || b.getName() == "tree_pine")
			{
				CBlob@ tree = server_CreateBlob("crystaltree", b.getTeamNum(), b.getPosition() + Vec2f(0, -32));
					
				b.Tag("no drop");
				b.server_Die();
			}
		}
	}
	
	if (isClient())
	{
		for (int i = 0; i < 16; i++)
		{
			MakeParticle(this, Vec2f( XORRandom(32) - 16, XORRandom(40) - 30), getRandomVelocity(-angle, XORRandom(250) * 0.01f, 25), particles[XORRandom(particles.length)]);
		}
		SetScreenFlash(50, 255, 255, 255);
		this.getSprite().Gib();
	}
	
	
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 1.8f + XORRandom(100) * 0.01f, 2 + XORRandom(6), XORRandom(100) * -0.00005f, true);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}