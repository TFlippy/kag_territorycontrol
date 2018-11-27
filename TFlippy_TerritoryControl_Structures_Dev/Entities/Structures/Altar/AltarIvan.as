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
	sprite.SetEmitSoundVolume(1.0f);
	sprite.SetEmitSoundSpeed(1.0f);
	sprite.SetEmitSoundPaused(false);
					
	CSpriteLayer@ shield = sprite.addSpriteLayer("shield", "Shield.png" , 16, 64, this.getTeamNum(), 0);

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
}

void onTick(CBlob@ this)
{
	f32 radius = 128.00f;

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
			
			if (team < 7 && b.hasTag("flesh"))
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

	f32 radius = 128.00f;
	
	Vec2f dir = target.getPosition() - this.getPosition();
	f32 dist = Maths::Abs(dir.Length());
	dir.Normalize();
	
	target.setVelocity(Vec2f(dir.x, dir.y) * 7.0f);
	SetKnocked(target, 90);
	target.set_u32("next zap", getGameTime() + 5);
	
	if (getNet().isServer())
	{
		f32 damage = target.getInitialHealth() * 0.75f;
		this.server_Hit(target, target.getPosition(), dir, damage * (target.hasTag("explosive") ? 16.00f : 1.00f) , HittersTC::forcefield);
	}
	
	if (getNet().isClient())
	{
		// this.getSprite().PlaySound("energy_disintegrate_" + XORRandom(2) + ".ogg");
		
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

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;
	
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	CInventory @inv = caller.getInventory();
	if(inv is null) return;

	if(inv.getItemsCount() > 0)
	{
		params.write_u16(caller.getNetworkID());
		CButton@ buttonOwner = caller.CreateGenericButton(28, Vec2f(0, 8), this, this.getCommandID("sv_store"), "Store", params);
	}
}

// void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
// {
	// if (getNet().isServer())
	// {
		// if (cmd == this.getCommandID("sv_store"))
		// {
			// CBlob@ caller = getBlobByNetworkID(params.read_u16());
			// if (caller !is null)
			// {
				// CInventory @inv = caller.getInventory();
				// if (caller.getConfig() == "builder")
				// {
					// CBlob@ carried = caller.getCarriedBlob();
					// if (carried !is null)
					// {
						// if (carried.hasTag("temp blob"))
						// {
							// carried.server_Die();
						// }
					// }
				// }
				// if (inv !is null)
				// {
					// while (inv.getItemsCount() > 0)
					// {
						// CBlob @item = inv.getItem(0);
						// caller.server_PutOutInventory(item);
						// this.server_PutInInventory(item);
					// }
				// }
			// }
		// }
	// }
// }

// bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
// {
	// return forBlob.isOverlapping(this);
// }