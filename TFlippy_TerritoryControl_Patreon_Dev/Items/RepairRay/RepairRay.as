#include "Hitters.as";
#include "Knocked.as";
#include "DeityCommon.as"

f32 maxDistance = 80;

void onInit(CBlob@ this)
{
	this.Tag("no shitty rotation reset");

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}
	
	this.getCurrentScript().tickFrequency = 1;
	this.getCurrentScript().runFlags |= Script::tick_attached;
}

void onTick(CBlob@ this)
{	
	if (this.isAttached()) 
	{
		UpdateAngle(this);
	
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point is null) {return;}
		CBlob@ holder = point.getOccupied();
		
		if (holder is null) {return;}

		if (getKnocked(holder) <= 0 && getGameTime() % 3 == 0) //works a bit slower since checking map tiles is quite the lag maker
		{
			CSprite@ sprite = this.getSprite();
		
			bool lmb = point.isKeyPressed(key_action1);
		
			if (lmb) //Needs at least 10 stone in inventory to work
			{
				CInventory@ inv = holder.getInventory();
				if (CountAmmo(inv) > 10)
				{
					Vec2f aimDir = holder.getAimPos() - this.getPosition();
					aimDir.Normalize();
					aimDir = aimDir;
				
					Vec2f point = holder.getPosition();

					CMap@ map = getMap();

					u32 range = 6;
					u8 deity_id = this.get_u8("deity_id");
					if (deity_id == Deity::mason)
					{
						CBlob@ altar = getBlobByName("altar_mason");
						if (altar !is null)
						{
							range = range + Maths::Floor(Maths::Sqrt(altar.get_f32("deity_power") * 0.01f));	
						}
					}

					for (int i = 0; i < range; i++)
					{
						point += aimDir * 8; //Move the point forward
						int x = Maths::Round(point.x);
						int y = Maths::Round(point.y);
						Vec2f pos = Vec2f(x, y);
						Tile tile = map.getTile(pos);
						//print(" " + x + " " + y + " " + tile.type);
						u16 type = tile.type;

						if (type == CMap::tile_castle_moss)  //should use stone to do this
						{
							tile.type = CMap::tile_castle;
							map.server_SetTile(pos, tile);
							makeSteamParticle(this, pos, aimDir);
							TakeAmmo(inv, 3);
						}
						else if (type == CMap::tile_castle_back_moss)
						{
							tile.type = CMap::tile_castle_back;
							map.server_SetTile(pos, tile);
							makeSteamParticle(this, pos, aimDir);
							TakeAmmo(inv, 3);
						}
						else if (type >= CMap::tile_castle_d1 && type <= CMap::tile_castle_d0)
						{
							tile.type = CMap::tile_castle;
							map.server_SetTile(pos, tile);
							makeSteamParticle(this, pos, aimDir);
							TakeAmmo(inv, 3);
						}
						else if (type >= 76 && type <= 79)
						{
							tile.type = CMap::tile_castle_back;
							map.server_SetTile(pos, tile);
							makeSteamParticle(this, pos, aimDir);
							TakeAmmo(inv, 3);
						}
					}
				}
			}
		}
	}
}

void UpdateAngle(CBlob@ this)
{
	AttachmentPoint@ point=this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) {return;}
	
	CBlob@ holder=point.getOccupied();
	
	if(holder is null) {return;}
	
	Vec2f aimpos=holder.getAimPos();
	Vec2f pos=holder.getPosition();
	
	Vec2f aim_vec =(pos - aimpos);
	aim_vec.Normalize();
	
	f32 mouseAngle=aim_vec.getAngleDegrees();
	if(!holder.isFacingLeft()) mouseAngle += 180;

	this.setAngleDegrees(-mouseAngle);
	
	point.offset.x=0 +(aim_vec.x*2*(holder.isFacingLeft() ? 1.0f : -1.0f));
	point.offset.y=-(aim_vec.y);
}

void makeSteamParticle(CBlob@ this, Vec2f pos, const Vec2f vel)
{
	if (!isClient()){ return;}

	CParticle@ p = ParticleAnimated("SmallSteam", pos + Vec2f(4, 4), vel, float(XORRandom(360)), 1.0f, 2, 0, false);
	if (p != null)
	{
		p.colour = SColor(255, 120, 120, 120);
		p.Z = 300;
	}
}

void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	detached.Untag("noLMB");
	detached.Untag("noShielding");
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	attached.Tag("noLMB");
	attached.Tag("noShielding");
}

u32 CountAmmo(CInventory@ inv)
{
	u32 quantity = 0;

	int size = inv.getItemsCount();
	for (int i = 0; i < size; i++)
	{
		CBlob@ item = inv.getItem(i);
		if (item !is null)
		{
			string itemName = item.getName();
			if (itemName == "mat_stone")
			{
				quantity += item.getQuantity();
			}
		}
	}
	return quantity;
}

s32 TakeAmmo(CInventory@ inv, s32 amount)
{
	s32 taken = 0;
	int size = inv.getItemsCount();
	for (int i = 0; i < size; i++)
	{
		CBlob@ item = inv.getItem(i);
		if (item !is null)
		{
			string itemName = item.getName();
			if (itemName == "mat_stone")
			{
				s32 quantity = item.getQuantity();

				bool take = true;
				//Hack
				//if (inv.getBlob() != null) take = false; //Doesnt seem to do anything so weird

				if (take)
				{
					if (quantity + 1 > (amount - taken))
					{
						item.server_SetQuantity(quantity - (amount - taken));
					}
					else
					{
						item.server_SetQuantity(0);
						item.server_Die();
					}
				}

				taken += Maths::Min(quantity, (amount - taken));
				if (taken >= amount)
				{
					return amount;
				}
			}
		}
	}
	return taken;
}