#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "Knocked.as";
#include "Hitters.as";
#include "HittersTC.as";


// A script by TFlippy

// Mithrios
	// Bonuses: Mithrios head for followers, +5% running speed with each follower, 20% damage resistance
	// Offering: Meat
	
// Ivan
	// Bonuses: Drunken speech for followers, shrine plays old tavern music, slaving immunity, ???
	// Offering: Vodka
	
// Gregor Builder
	// Bonuses: 
	// Offering: 

// Barsuk
	// Bonuses: 
	// Offering: 
	
// Barlth
	// Bonuses: 
	// Offering: 

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	
	sprite.SetEmitSound("Ivan_Music.ogg");
	sprite.SetEmitSoundVolume(0.4f);
	sprite.SetEmitSoundSpeed(1.0f);
	sprite.SetEmitSoundPaused(false);
					
	CSpriteLayer@ shield = sprite.addSpriteLayer("shield", "Ivan_Shield.png" , 16, 64, this.getTeamNum(), 0);

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
	
	this.set_Vec2f("shop menu size", Vec2f(2, 2));
	this.set_string("shop description", "Make an offering");
	this.set_u8("shop icon", 15);
	// this.Tag(SHOP_AUTOCLOSE);
	
	AddIconToken("$icon_ivan_follower$", "InteractionIcons.png", Vec2f(32, 32), 11);
	
	{
		ShopItem@ s = addShopItem(this, "Become a follower of Ivan", "$icon_ivan_follower$", "follower", "Gain Ivan's goodwill by offering him a bottle of vodka.");
		AddRequirement(s.requirements, "blob", "vodka", "Vodka", 1);
		s.customButton = true;
		s.buttonwidth = 2;	
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		u16 caller, item;
		if (params.saferead_netid(caller) && params.saferead_netid(item))
		{
			string data = params.read_string();
			
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob !is null)
			{
				this.getSprite().PlaySound("Ivan_Offering.ogg", 2.00f, 1.00f);
			
				CBlob@ localBlob = getLocalPlayerBlob();
				if (localBlob !is null)
				{
					if (this.getDistanceTo(localBlob) < 128)
					{
						SetScreenFlash(255, 255, 255, 255, 3.00f);
					}
				}
			
				// CPlayer@ callerPlayer = callerBlob.getPlayer();
				// if (callerPlayer !is null)
				// {
					// callerPlayer.Tag("ivan");
					// callerPlayer.Sync("ivan", true);
				// }
			}
		}
	}
}

const SColor[] colors = 
{
	SColor(255, 255, 30, 30),
	SColor(255, 30, 255, 30),
	SColor(255, 30, 30, 255)
};

void onTick(CBlob@ this)
{
	f32 radius = 128.00f;

	SColor color = colors[XORRandom(colors.length)];
	
	CBlob@ localBlob = getLocalPlayerBlob();
	if (localBlob !is null)
	{
		f32 dist = this.getDistanceTo(localBlob);
		f32 distMod = 1.00f - dist / radius;
		f32 sqrDistMod = 1.00f - Maths::Sqrt(dist / radius);
		
		if (dist < radius * 2.00f) 
		{
			ShakeScreen(50.0f, 15, this.getPosition());
		}
		
		if (dist < radius)
		{
			if (getGameTime() % 8 == 0) 
			{
				SetScreenFlash(100 * distMod, color.getRed(), color.getGreen(), color.getBlue(), 0.2f);
			}
		}
	}
	
	if (getGameTime() % 8 == 0) 
	{
		this.SetLight(true);
		this.SetLightRadius(radius);
		this.SetLightColor(color);
	}
	
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), radius * 0.50f, @blobsInRadius))
	{
		int index = -1;
		f32 s_dist = 1337;
		u8 myTeam = this.getTeamNum();
	
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			u8 team = b.getTeamNum();
			
			if (team < 7 && team <= 200 && b.hasTag("flesh"))
			{
				f32 dist = (b.getPosition() - this.getPosition()).Length();
				if (dist < s_dist)
				{
					s_dist = dist;
					index = i;
				}
			}
		}
		
		if (index < 0) return;
		
		CBlob@ target = blobsInRadius[index];
		Zap(this, target);
		
		// print("" + target.getName());	
	}
}

void Zap(CBlob@ this, CBlob@ target)
{
	if (target.get_u32("next zap") > getGameTime()) return;

	f32 radius = 128.00f * 0.50f;
	
	Vec2f dir = target.getPosition() - this.getPosition();
	f32 dist = Maths::Abs(dir.Length());
	dir.Normalize();
	
	target.setVelocity(Vec2f(dir.x, dir.y) * 7.0f);
	SetKnocked(target, 90);
	target.set_u32("next zap", getGameTime() + 5);
	
	if (isServer())
	{
		f32 damage = 0.125f;
		this.server_Hit(target, target.getPosition(), dir, damage * (target.hasTag("explosive") ? 16.00f : 1.00f) , HittersTC::staff);
	}
	
	if (getNet().isClient())
	{
		this.getSprite().PlaySound("Ivan_Zap.ogg");
		
		CSpriteLayer@ shield = this.getSprite().getSpriteLayer("shield");
		if (shield !is null)
		{
			shield.SetVisible(true);
			shield.setRenderStyle(RenderStyle::outline_front);
			
			shield.SetFrameIndex(0);
			shield.SetAnimation("default");
			shield.ResetTransform();
			shield.RotateBy(dir.Angle() * -1.00f, Vec2f());
			shield.TranslateBy(dir * (radius - 8.0f));
		}
	}
}