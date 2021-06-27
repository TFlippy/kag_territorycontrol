// Standard menu player controls
// add to blob and sprite

#include "StandardControlsCommon.as"
#include "ThrowCommon.as"
#include "Knocked.as"

const u32 PICKUP_ERASE_TICKS = 80;

void onInit(CBlob@ this)
{
	CBlob@[] blobs;
	this.set("pickup blobs", blobs);
	CBlob@[] closestblobs;
	this.set("closest blobs", closestblobs);

	string[] recent;
	this.set("recent pickups", recent);
	this.set_u32("last pickup time", 0);

//	this.addCommandID("detach"); in StandardControls

	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	if (this.isInInventory() || getKnocked(this) > 0)
	{
		this.clear("pickup blobs");
		this.clear("closest blobs");
		return;
	}

	// drop / pickup / throw
	if (this.isKeyJustPressed(key_pickup))
	{
		CBlob@ carryBlob = this.getCarriedBlob();

		if (this.isAttached()) // default drop from attachment
		{
			int count = this.getAttachmentPointCount();

			for (int i = 0; i < count; i++)
			{
				AttachmentPoint @ap = this.getAttachmentPoint(i);

				if (ap.getOccupied() !is null && ap.name != "PICKUP")
				{
					CBitStream params;
					params.write_netid(ap.getOccupied().getNetworkID());
					this.SendCommand(this.getCommandID("detach"), params);
					this.set_bool("release click", false);
					break;
				}
			}
		}
		else if (carryBlob !is null && !carryBlob.hasTag("custom drop") && (!carryBlob.hasTag("temp blob") || carryBlob.getName() == "ladder"))
		{
			ClearPickupBlobs(this);
			client_SendThrowCommand(this);
			this.set_bool("release click", false);

		}
		else
		{
			this.set_bool("release click", true);
		}
	}
	else
	{
		if (this.isKeyPressed(key_pickup))
		{
			GatherPickupBlobs(this);

			CBlob@[]@ closestBlobs;
			this.get("closest blobs", @closestBlobs);
			closestBlobs.clear();
			CBlob@ closest = getClosestBlob(this);
			if (closest !is null && this !is null)
			{
				closestBlobs.push_back(closest);
				if (this.isKeyJustPressed(key_action1))	// pickup
				{
					server_Pickup(this, this, closest);
				}
			}

		}

		if (this.isKeyJustReleased(key_pickup))
		{
			if (this.get_bool("release click"))
			{
				CBlob@[]@ closestBlobs;
				this.get("closest blobs", @closestBlobs);
				if (closestBlobs.length > 0)
				{
					if(closestBlobs[0] !is null)
					{
						server_Pickup(this, this, closestBlobs[0]);
					}
				}
			}
			ClearPickupBlobs(this);
		}
	}

	// erase recent pickups list

	if (this.get_u32("last pickup time") + PICKUP_ERASE_TICKS < getGameTime())
	{
		RemoveLastRecentPickup(this);
	}
}

bool isDangerous(CBlob@ blob)
{
	return blob.hasTag("explosive") || blob.hasTag("weapon") || blob.hasTag("dangerous");
}

void GatherPickupBlobs(CBlob@ this)
{
	CBlob@[]@ pickupBlobs;
	this.get("pickup blobs", @pickupBlobs);
	pickupBlobs.clear();
	CBlob@[] blobsInRadius;

	bool isBabbyed = this.get_f32("babbyed") > 0;
	
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() + 50.0f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];

			if (b.canBePickedUp(this) && (isBabbyed ? !isDangerous(b) : true))
			{
				pickupBlobs.push_back(b);
			}
		}
	}
}

void ClearPickupBlobs(CBlob@ this)
{
	this.clear("pickup blobs");
}

void RemoveLastRecentPickup(CBlob@ this)
{
	string[]@ recentPickups;
	if (this.get("recent pickups", @recentPickups))
	{
		if (recentPickups.length > 0)
		{
			recentPickups.removeAt(0);
			this.set_u32("last pickup time", getGameTime());
		}
	}
}

void FillAvailable(CBlob@ this, CBlob@[]@ available, CBlob@[]@ pickupBlobs)
{
	for (uint i = 0; i < pickupBlobs.length; i++)
	{
		CBlob @b = pickupBlobs[i];

		if (b !is this && canBlobBePickedUp(this, b) && !isInRecentPickups(this, b))
		{
			available.push_back(b);
		}
	}
}

f32 getPriorityPickupScale(CBlob@ this, CBlob@ b, f32 scale)
{
	u32 gameTime = getGameTime();
	const string name = b.getName();
	// 0
	// exploding stuff + crates unpacking + blueprints
	{
		u32 unpackTime = b.get_u32("unpack time");
		if (b.hasTag("exploding") || b.hasTag("blueprint") || name == "fraggrenade" || name == "dynamite" || unpackTime > gameTime)
		{
			scale *= 0.1f;
		}

		//special stuff - flags etc
		if (b.hasTag("special") || name == "cube" || name == "shito" || name == "rekt" || name == "juggernauthammer")
		{
			scale *= 0.01f;
		}
	}

	// 1
	// combat items, class changers, equipment, important
	{
		if (name == "drill" || name == "powerdrill" || name == "crate" || name == "mine" || name == "fragmine" || name == "phone" ||
		    name == "engineertools" || name == "ninjascroll" || name == "hazmatitem" || 
		    name == "artisancertificate" || name == "royalarmor" || name == "exosuititem" ||
		    b.hasTag("explosive") || b.hasTag("weapon") || b.hasTag("equipment support"))
		{
			scale *= 0.41f;
		}
	}

	//low priority
	if (name == "log" || name == "mat_meat" || name == "mat_dirt"|| 
	    name == "piglet" || name == "kitten" || b.hasTag("player"))
	{
		scale *= 5.0f;
	}

	// super low priority
	// dead stuff, sick of picking up corpses
	{
		if (b.hasTag("dead") || b.hasTag("furniture") || name == "pigger" || name == "badgerbomb")
		{
			scale *= 10.0f;
		}
	}

	const string thisname = this.getName();

	//per class material scaling - done last for perf reasons
	if (b.hasTag("material"))
	{
		if (name == "mat_gold" || name == "mat_goldingot" || name == "mat_mithril" || name == "mat_mithrilenriched" || 
		    name == "seed" ||  name == "gyromat" || name == "gasextractor")
		{
			if (thisname == "builder" || thisname == "peasant" || thisname == "engineer" || thisname == "hazmat")
			{
				scale *= 0.25f;
			}
			else
			{
				scale *= 4.0f;
				scale += 20.0f;
			}
		}
		else if (name == "mat_bombs" || name == "mat_waterbombs" || b.hasTag("ammo"))
		{
			if (thisname == "knight" || thisname == "royalguard" || thisname == "bandit")
			{
				scale *= 0.25f;
			}
			else
			{
				scale *= 4.0f;
				scale += 20.0f;
			}
		}
		else if (name == "mat_arrows" || name == "mat_waterarrows" ||
		         name == "mat_firearrows" || name == "mat_bombarrows")
		{
			if (thisname == "archer")
			{
				if (name == "mat_arrows")
					scale *= 0.3f; //pick special arrows first
				else
					scale *= 0.25f;
			}
			else
			{
				scale *= 4.0f;
				scale += 20.0f;
			}
		}
	}

	if (b.exists("pickup_priority"))
	{
		scale *= b.get_f32("pickup_priority");
	}

	return scale;
}

CBlob@ getClosestBlob(CBlob@ this)
{
	CBlob@[]@ pickupBlobs;
	if (this.get("pickup blobs", @pickupBlobs))
	{
		Vec2f pos = this.getPosition();
		Vec2f aimpos = this.getAimPos();
		bool facingLeft = this.isFacingLeft();
		pos += Vec2f(facingLeft ? -this.getRadius() : this.getRadius(), 0);

		CBlob@[] available;
		FillAvailable(this, available, pickupBlobs);

		if (available.length == 0)
		{
			RemoveLastRecentPickup(this);
			FillAvailable(this, available, pickupBlobs);
		}

		// sort by closest

		CBlob@[] closest;
		while (available.size() > 0)
		{
			f32 closestDist = 999999.9f;
			uint closestIndex = 999;

			for (uint i = 0; i < available.length; i++)
			{
				CBlob @b = available[i];
				Vec2f bpos = b.getPosition();
				f32 dist = (bpos - pos).getLength();
				dist = getPriorityPickupScale(this, b, dist);

				if (dist < closestDist)
				{
					closestDist = dist;
					closestIndex = i;
				}
			}

			if (closestIndex >= 999)
			{
				break;
			}

			closest.push_back(available[closestIndex]);
			available.erase(closestIndex);
		}

		if (closest.length > 0)
		{
			return closest[0];
		}
	}

	return null;
}

bool canBlobBePickedUp(CBlob@ this, CBlob@ blob)
{
	Vec2f pos = this.getPosition() + Vec2f(0.0f, -this.getRadius() * 0.9f);
	Vec2f pos2 = blob.getPosition();
	return (((pos2 - pos).getLength() < (this.getRadius() + blob.getRadius()) + 20.0f)
	        && !blob.isAttached()
	        && (!this.getMap().rayCastSolid(pos, pos2) || this.isOverlapping(blob)) //overlapping fixes "in platform" issue
	       );
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attachedPoint.name == "PICKUP")
	{
		this.push("recent pickups", attached.getName());
	}
}

bool isInRecentPickups(CBlob@ this, CBlob@ blob)
{
	string[]@ recentPickups;
	const string name = blob.getName();
	this.get("recent pickups", @recentPickups);
	for (uint i = 0; i < recentPickups.length; i++)
	{
		if (recentPickups[i] == name)
			return true;
	}
	return false;
}

// SPRITE

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	// render item held when in inventory

	if (blob.isKeyPressed(key_inventory))
	{
		CBlob @pickBlob = blob.getCarriedBlob();

		if (pickBlob !is null)
		{
			pickBlob.RenderForHUD((blob.getAimPos() + Vec2f(0.0f, 8.0f)) - blob.getPosition() , RenderStyle::normal);
		}
	}

	if (blob.isKeyPressed(key_pickup))
	{
		// pickup render
		bool tickPlayed = false;
		bool hover = false;
		CBlob@[]@ pickupBlobs;
		CBlob@[]@ closestBlobs;
		blob.get("closest blobs", @closestBlobs);

		if (closestBlobs is null) return;

		CBlob@ closestBlob = null;
		if (closestBlobs.length > 0)
		{
			@closestBlob = closestBlobs[0];
		}

		if (blob.get("pickup blobs", @pickupBlobs))
		{
			// render outline only if hovering
			for (uint i = 0; i < pickupBlobs.length; i++)
			{
				CBlob @b = pickupBlobs[i];

				bool canBePicked = canBlobBePickedUp(blob, b);

				if (canBePicked)
				{
					b.RenderForHUD(RenderStyle::outline_front);
				}

				if (b is closestBlob)
				{
					hover = true;
					Vec2f dimensions;
					GUI::SetFont("menu");
					GUI::GetTextDimensions(b.getInventoryName(), dimensions);
					GUI::DrawText(b.getInventoryName(), getDriver().getScreenPosFromWorldPos(b.getPosition() - Vec2f(0, -b.getHeight() / 2)) - Vec2f(dimensions.x / 2, -8.0f), color_white);

					// draw mouse hover effect
					//if (canBePicked)
					{
						b.RenderForHUD(RenderStyle::additive);

						if (!tickPlayed)
						{
							if (blob.get_u16("hover netid") != b.getNetworkID())
							{
								Sound::Play("/select.ogg");
							}

							blob.set_u16("hover netid", b.getNetworkID());
							tickPlayed = true;
						}

						//break;
					}
				}

			}

			// no hover
			if (!hover)
			{
				blob.set_u16("hover netid", 0);
			}

			// render outlines

			//for (uint i = 0; i < pickupBlobs.length; i++)
			//{
			//    pickupBlobs[i].RenderForHUD( RenderStyle::outline_front );
			//}
		}
	}
}
