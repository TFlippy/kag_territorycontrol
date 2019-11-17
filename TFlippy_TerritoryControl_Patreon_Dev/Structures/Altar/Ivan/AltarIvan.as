#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "Knocked.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "DeityCommon.as";

const SColor[] colors = 
{
	SColor(255, 255, 30, 30),
	SColor(255, 30, 255, 30),
	SColor(255, 30, 30, 255)
};

void onInit(CBlob@ this)
{
	this.set_u8("deity_id", Deity::ivan);

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
	
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	
	AddIconToken("$icon_ivan_follower$", "InteractionIcons.png", Vec2f(32, 32), 11);
	{
		ShopItem@ s = addShopItem(this, "Rite of Ivan", "$icon_ivan_follower$", "follower", "Gain Ivan's goodwill by offering him a bottle of vodka.");
		AddRequirement(s.requirements, "blob", "vodka", "Vodka", 1);
		s.customButton = true;
		s.buttonwidth = 2;	
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
	
	AddIconToken("$icon_ivan_offering_0$", "AltarIvan_Icons.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Squat of Hoboness", "$icon_ivan_offering_0$", "offering_hobo", "Bring this corpse back from the dead as a filthy hobo.");
		AddRequirement(s.requirements, "blob", "bandit", "Bandit's Corpse", 1);
		AddRequirement(s.requirements, "blob", "vodka", "Vodka", 1);
		AddRequirement(s.requirements, "blob", "ratburger", "Rat Burger", 1);
		s.customButton = true;
		s.buttonwidth = 1;	
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	
	AddIconToken("$icon_ivan_offering_1$", "AltarIvan_Icons.png", Vec2f(24, 24), 1);
	{
		ShopItem@ s = addShopItem(this, "Squat of Kalashnikov", "$icon_ivan_offering_1$", "offering_ak47", "Build your own AK-47 and have it blessed by Ivan.");
		AddRequirement(s.requirements, "blob", "log", "Log", 1);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 4);
		AddRequirement(s.requirements, "blob", "vodka", "Vodka", 4);
		s.customButton = true;
		s.buttonwidth = 1;	
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
}

void onTick(CBlob@ this)
{
	SColor color = colors[XORRandom(colors.length)];
	
	const f32 power = this.get_f32("deity_power");
	const f32 radius = 64.00f + Maths::Sqrt(power);
	
	this.setInventoryName("Altar of Ivan\n\nIvanic Power: " + power + "\nRadius: " + int(radius / 8.00f));
	
	CBlob@ localBlob = getLocalPlayerBlob();
	if (localBlob !is null)
	{
		f32 diameter = radius * 2.00f;
	
		f32 dist = this.getDistanceTo(localBlob);
		f32 distMod = 1.00f - (dist / diameter);
		f32 sqrDistMod = 1.00f - Maths::Sqrt(dist / radius);
		
		if (dist < diameter) 
		{
			ShakeScreen(50.0f, 15, this.getPosition());

			if (getGameTime() % 8 == 0) 
			{
				SetScreenFlash(Maths::Min((power * 0.10f) * distMod, 50), color.getRed(), color.getGreen(), color.getBlue(), 0.2f);
			}
		}
	}
	
	if (getGameTime() % 8 == 0) 
	{
		this.SetLight(true);
		this.SetLightRadius(radius);
		this.SetLightColor(color);
		
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSoundVolume(Maths::Max(power * 0.002f, 0.50f));
		sprite.SetEmitSoundSpeed(0.70f + (power * 0.0002f));
	}
	
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
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
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer !is null)
				{
					if (data == "follower")
					{
						this.add_f32("deity_power", 50);
						if (isServer()) this.Sync("deity_power", false);
						
						if (isClient())
						{
							// if (callerBlob.get_u8("deity_id") != Deity::mithrios)
							// {
								// client_AddToChat(callerPlayer.getCharacterName() + " has become a follower of Ivan.", SColor(255, 255, 0, 0));
							// }
							
							CBlob@ localBlob = getLocalPlayerBlob();
							if (localBlob !is null)
							{
								if (this.getDistanceTo(localBlob) < 128)
								{
									this.getSprite().PlaySound("Ivan_Offering.ogg", 2.00f, 1.00f);
									SetScreenFlash(255, 255, 255, 255, 3.00f);
								}
							}
						}
						
						if (isServer())
						{
							callerPlayer.set_u8("deity_id", Deity::ivan);
							callerPlayer.Sync("deity_id", false);
							
							callerBlob.set_u8("deity_id", Deity::ivan);
							callerBlob.Sync("deity_id", false);
						}
					}
					else
					{
						if (data == "offering_hobo")
						{
							this.add_f32("deity_power", 25);
							if (isServer()) this.Sync("deity_power", false);
							
							if (isServer())
							{
								CBlob@ hobo = server_CreateBlob("hobo", this.getTeamNum(), this.getPosition());
							}
							
							if (isClient())
							{
								CBlob@ localBlob = getLocalPlayerBlob();
								if (localBlob !is null)
								{
									if (this.getDistanceTo(localBlob) < 128)
									{
										this.getSprite().PlaySound("Ivan_Offering.ogg", 2.00f, 1.00f);
										SetScreenFlash(255, 255, 255, 255, 3.00f);
									}
								}
							}
						}
						else if (data == "offering_ak47")
						{
							this.add_f32("deity_power", 100);
							if (isServer()) this.Sync("deity_power", false);
							
							if (isServer())
							{
								CBlob@ gun = server_CreateBlob("ak47", this.getTeamNum(), this.getPosition());
							}
							
							if (isClient())
							{
								CBlob@ localBlob = getLocalPlayerBlob();
								if (localBlob !is null)
								{
									if (this.getDistanceTo(localBlob) < 128)
									{
										this.getSprite().PlaySound("Ivan_Offering.ogg", 2.00f, 1.00f);
										SetScreenFlash(255, 255, 255, 255, 3.00f);
									}
								}
							}
						}
					}
				}				
			}
		}
	}
}

void Zap(CBlob@ this, CBlob@ target)
{
	if (target.get_u32("next zap") > getGameTime()) return;

	const f32 power = this.get_f32("deity_power");
	const f32 radius = 64.00f + Maths::Sqrt(power);
	
	Vec2f dir = target.getPosition() - this.getPosition();
	f32 dist = Maths::Abs(dir.Length());
	dir.Normalize();
	
	target.setVelocity(Vec2f(dir.x, dir.y) * (7.0f + (power * 0.001f)));
	SetKnocked(target, 90);
	target.set_u32("next zap", getGameTime() + 5);
	
	if (isServer())
	{
		f32 damage = 0.125f;
		this.server_Hit(target, target.getPosition(), dir, damage * (target.hasTag("explosive") ? 16.00f : 1.00f) , HittersTC::staff);
	}
	
	if (isClient())
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