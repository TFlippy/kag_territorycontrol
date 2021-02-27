#define SERVER_ONLY

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 12;
	this.getCurrentScript().removeIfTag = "dead";
}

void Take(CBlob@ this, CBlob@ blob)
{
	const string blobName = blob.getName();
	
	if (!this.isAttached() && blob.hasTag("builder pickup") && !blob.hasTag("no pickup"))
	{
		if ((this.getDamageOwnerPlayer() is blob.getPlayer()) || getGameTime() > blob.get_u32("autopick time"))
		{
			bool add = true;
			if (blob.hasTag("ammo")) //only add ammo if we have something that can use it.
			{
				CBlob@[] items;
				if (this.getCarriedBlob() != null)
				{
					items.push_back(this.getCarriedBlob());
				}
				CInventory@ inv = this.getInventory();
				for (int i = 0; i < inv.getItemsCount(); i++)
				{
					CBlob@ item = inv.getItem(i);
					items.push_back(item);
				}
				for(int i = 0; i < items.size(); i++)
				{
					CBlob@ item = items[i];
					string ammoType = item.get_string("gun_ammoItem");
					if(ammoType == blob.getName())
					{
						add = true;
						break;
					}
					add = false;
				}
			}
			if(!add){return;}
			if (!this.server_PutInInventory(blob))
			{
				// we couldn't fit it in
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.getShape().vellen > 1.0f)
	{
		return;
	}

	Take(this, blob);
}

void onTick(CBlob@ this)
{
	CBlob@[] overlapping;

	if (this.getOverlapping(@overlapping))
	{
		for (uint i = 0; i < overlapping.length; i++)
		{
			CBlob@ blob = overlapping[i];
			{
				if (blob.getShape().vellen > 1.0f)
				{
					continue;
				}

				Take(this, blob);
			}
		}
	}
}

// make ignore collision time a lot longer for auto-pickup stuff
void IgnoreCollisionLonger(CBlob@ this, CBlob@ blob)
{
	if (this.hasTag("dead"))
	{
		return;
	}

	const string blobName = blob.getName();

	if (blobName == "mat_gold" || blobName == "mat_stone" ||
		blobName == "mat_coal" || blobName == "mat_sand" ||
		blobName == "mat_metal" || blobName == "mat_metalbars" ||
		blobName == "mat_gunpowder" || blobName == "mat_hemp" ||
	        blobName == "mat_wood" || blobName == "grain" || blobName == "steak")
	{
		blob.set_u32("autopick time", getGameTime() +  getTicksASecond() * 7);
		blob.SetDamageOwnerPlayer(blob.getPlayer());
	}
}


void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	IgnoreCollisionLonger(this, detached);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	IgnoreCollisionLonger(this, blob);
}
