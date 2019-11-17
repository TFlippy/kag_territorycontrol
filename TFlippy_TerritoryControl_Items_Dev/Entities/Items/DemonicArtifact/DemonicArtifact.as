// Princess brain

#include "Hitters.as";
#include "HittersTC.as";
#include "Knocked.as";
#include "DeityCommon.as";

const f32 radius = 128.0f;

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");

	this.set_f32("pickup_priority", 1337.00f);
	this.getShape().SetRotationsAllowed(false);
	
	this.getCurrentScript().tickFrequency = 1;
	// this.getCurrentScript().runFlags |= Script::tick_not_ininventory | Script::tick_not_attached;
	
	this.set_u16("soulbound_netid", 0);
}

void onInit(CSprite@ this)
{	
	CSpriteLayer@ shield = this.addSpriteLayer("shield", "DemonShield.png", 16, 64, this.getBlob().getTeamNum(), 0);

	this.SetEmitSound("DemonicLoop.ogg");
	this.RewindEmitSound();
	this.SetEmitSoundPaused(true);
	
	if (shield !is null)
	{
		Animation@ anim = shield.addAnimation("default", 3, false);
		
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		anim.AddFrame(5);
		anim.AddFrame(6);
		anim.AddFrame(7);
		
		shield.SetRelativeZ(-1.0f);
		shield.SetVisible(false);
		shield.setRenderStyle(RenderStyle::outline_front);
		shield.SetIgnoreParentFacing(true);
	}
	
	Animation@ hide = this.addAnimation("default", 0, false);
	hide.AddFrame(0);
	hide.AddFrame(1);
	this.SetAnimation("default");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	if (this.get_u16("soulbound_netid") == 0) return true;

	CPlayer@ ply = byBlob.getPlayer();
	if (ply !is null && ply.getNetworkID() == this.get_u16("soulbound_netid"))
	{
		return true;
	}
	else return false;
}

void onAttach(CBlob@ this, CBlob@ blob, AttachmentPoint@ point)
{
	CPlayer@ ply = blob.getPlayer();
	if (blob.get_u8("deity_id") != Deity::mithrios && this.get_u16("soulbound_netid") == 0)
	{
		this.set_u16("soulbound_netid", ply.getNetworkID());
		
		// Sound::Play("mysterious_perc_05.ogg");
		// SetScreenFlash(255, 0, 0, 0);
	}
}

void onTick(CBlob@ this)
{
	if (this.get_u16("soulbound_netid") == 0) return;

	CPlayer@ ply = getLocalPlayer();
	CBlob@ playerBlob = getLocalPlayerBlob();
	CSprite@ sprite = this.getSprite();
	
	if (playerBlob !is null && ply !is null && (ply.getNetworkID() == this.get_u16("soulbound_netid") || playerBlob.hasTag("mithrios")))
	{
		sprite.SetFrameIndex(0);
		sprite.SetEmitSoundPaused(false);
	
		Vec2f diff = playerBlob.getPosition() - this.getPosition();
		f32 dist = diff.getLength();
		
		if (dist < radius)
		{
			f32 invFactor = (dist / radius);
			f32 factor = 1.00f - invFactor;
			
			sprite.SetEmitSoundVolume(factor);
			sprite.SetEmitSoundSpeed(0.50f + (0.50f * invFactor));
			
			CCamera@ cam = getCamera();
			// cam.setRotation((XORRandom(1000) - 500) / 1000.00f * factor, (XORRandom(1000) - 500) / 1000.00f * factor, 0);
			// cam.setRotation(0, 1.00f * factor, 0);
			
			f32 angle = diff.Angle();
			cam.setRotation(diff.y * factor * 0.002f * (XORRandom(200) * 0.01f), diff.x * factor * 0.002f * (XORRandom(200) * 0.01f), XORRandom(200) * factor * 0.01f);
			
			SetScreenFlash((150 * factor) + XORRandom(10), 64, 0, 0);
			ShakeScreen(25 * factor, 30, this.getPosition());
			
			CControls@ controls = getControls();
			Driver@ driver = getDriver();
			if(isWindowActive() || isWindowFocused())
			{
				Vec2f spos = driver.getScreenPosFromWorldPos(this.getPosition());
				Vec2f dir = (controls.getMouseScreenPos() - spos);
				
				Vec2f move_to = dir * 0.75f * factor;
				if(move_to.x < 0) move_to.x--;
				if(move_to.y < 0) move_to.y--;
				
				controls.setMousePosition(controls.getMouseScreenPos() - move_to);
			}
			
			if (getGameTime() > this.get_u32("next_whisper"))
			{
				if (XORRandom(100 * (invFactor)) == 0)
				{
					// print("whisper");
				
					this.set_u32("next_whisper", getGameTime() + 30 * 5);
					this.getSprite().PlaySound("dem_whisper_" + XORRandom(6), 0.75f * factor, 0.75f);
				}
			}
		}
	}
	else
	{
		sprite.SetFrameIndex(1);
		sprite.SetEmitSoundPaused(true);
	}

	CBlob@[] blobs;
	if (getBlobsByTag("mithrios", @blobs))
	{
		int index = -1;
		f32 s_dist = radius * 0.50f;
		u8 myTeam = this.getTeamNum();
	
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			
			f32 dist = (b.getPosition() - this.getPosition()).Length();
			if (dist < s_dist)
			{
				s_dist = dist;
				index = i;
			}
		}
		
		if (index < 0) return;
		
		CBlob@ target = blobs[index];
		Smite(this, target);
	}
}

void Smite(CBlob@ this, CBlob@ target)
{
	if (target.get_u32("next smite") > getGameTime()) return;

	Vec2f dir = target.getPosition() - this.getPosition();
	f32 dist = Maths::Abs(dir.Length());
	dir.Normalize();
	
	target.setVelocity(Vec2f(dir.x, dir.y) * 7.0f);
	SetKnocked(target, 90);
	target.set_u32("next smite", getGameTime() + 30);
	
	if (isServer())
	{
		f32 damage = target.getInitialHealth() * 0.75f;
		this.server_Hit(target, target.getPosition(), dir, 1000.00f, Hitters::fire);
	}
	
	if (isClient())
	{
		this.getSprite().PlaySound("DemonicBoing");
		
		CSpriteLayer@ shield = this.getSprite().getSpriteLayer("shield");
		shield.SetVisible(true);
		shield.setRenderStyle(RenderStyle::outline_front);
		
		shield.SetFrameIndex(0);
		shield.SetAnimation("default");
		
		shield.ResetTransform();
		
		shield.RotateBy(dir.Angle() * -1.00f, Vec2f());
		shield.TranslateBy(dir * ((radius * 0.50f) - 8.0f));
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}