﻿// Storage.as

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-60); //-60 instead of -50 so sprite layers are behind ladders

	// Stone
	CSpriteLayer@ stone = this.addSpriteLayer("mat_stone", "StorageLayers.png", 24, 16);
	if (stone !is null)
	{
		{
			stone.addAnimation("default", 0, false);
			int[] frames = { 0, 5, 10 };
			stone.animation.AddFrames(frames);
		}
		stone.SetOffset(Vec2f(10.0f, -3.0f));
		stone.SetRelativeZ(1);
		stone.SetVisible(false);
	}

	// Wood
	CSpriteLayer@ wood = this.addSpriteLayer("mat_wood", "StorageLayers.png", 24, 16);
	if (wood !is null)
	{
		{
			wood.addAnimation("default", 0, false);
			int[] frames = { 1, 6, 11 };
			wood.animation.AddFrames(frames);
		}
		wood.SetOffset(Vec2f(-7.0f, -2.0f));
		wood.SetRelativeZ(1);
		wood.SetVisible(false);
	}

	// Gold
	CSpriteLayer@ gold = this.addSpriteLayer("mat_gold", "StorageLayers.png", 24, 16);
	if (gold !is null)
	{
		{
			gold.addAnimation("default", 0, false);
			int[] frames = { 2, 7, 12 };
			gold.animation.AddFrames(frames);
		}
		gold.SetOffset(Vec2f(-7.0f, -10.0f));
		gold.SetRelativeZ(1);
		gold.SetVisible(false);
	}

	// Bombs
	CSpriteLayer@ bombs = this.addSpriteLayer("mat_bombs", "StorageLayers.png", 24, 16);
	if (bombs !is null)
	{
		{
			bombs.addAnimation("default", 0, false);
			int[] frames = { 3, 8 };
			bombs.animation.AddFrames(frames);
		}
		bombs.SetOffset(Vec2f(-7.0f, 5.0f));
		bombs.SetRelativeZ(2);
		bombs.SetVisible(false);
	}

	// Rope
	CSpriteLayer@ rope = this.addSpriteLayer("rope", "StorageLayers.png", 24, 16);
	if (rope !is null)
	{
		{
			rope.addAnimation("default", 0, false);
			int[] frames = { 4 };
			rope.animation.AddFrames(frames);
		}
		rope.SetOffset(Vec2f(5.0f, -8.0f));
		rope.SetRelativeZ(2);
	}
}

void onInit(CBlob@ this)
{
	this.Tag("remote_storage");

	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	AddIconToken("$store_inventory$", "InteractionIcons.png", Vec2f(32, 32), 28);
	this.inventoryButtonPos = Vec2f(12, 0);
	this.addCommandID("store inventory");
	this.getCurrentScript().tickFrequency = 60;
}

void onTick(CBlob@ this)
{
	if (this.getInventory().isFull()) return;
	PickupOverlap(this);
}

void PickupOverlap(CBlob@ this)
{
	if (isServer())
	{
		Vec2f tl, br;
		this.getShape().getBoundingRect(tl, br);
		CBlob@[] blobs;
		this.getMap().getBlobsInBox(tl, br, @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if (!blob.isAttached() && blob.isOnGround() && (blob.hasTag("material") || blob.hasTag("food")))
			{
				this.server_PutInInventory(blob);
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if ((this.getTeamNum() >= 100 ? true : caller.getTeamNum() == this.getTeamNum()) && caller.isOverlapping(this))
	{
		CInventory @inv = caller.getInventory();
		if(inv is null) return;

		if(inv.getItemsCount() > 0)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$store_inventory$", Vec2f(-6, 0), this, this.getCommandID("store inventory"), "Store", params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isServer())
	{
		if (cmd == this.getCommandID("store inventory"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null)
			{
				CInventory @inv = caller.getInventory();
				if (caller.getName() == "builder")
				{
					CBlob@ carried = caller.getCarriedBlob();
					if (carried !is null)
					{
						// TODO: find a better way to check and clear blocks + blob blocks || fix the fundamental problem, blob blocks not double checking requirement prior to placement.
						if (carried.hasTag("temp blob"))
						{
							carried.server_Die();
						}
					}
				}
				
				if (inv !is null)
				{
					while (inv.getItemsCount() > 0)
					{
						CBlob@ item = inv.getItem(0);
						if (!this.server_PutInInventory(item))
						{
							caller.server_PutInInventory(item);
							break;
						}
					}
				}
			}
		}
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	updateLayers(this, blob);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	updateLayers(this, blob);
}

void updateLayers(CBlob@ this, CBlob@ blob)
{
	const string blobName = blob.getName();
	if (!checkName(blobName))
	{
		return;
	}
	CSprite@ sprite = this.getSprite();
	CInventory@ inv = this.getInventory();
	int blobCount = inv.getCount(blobName);
	if (blobName == "mat_stone")
	{
		CSpriteLayer@ stone = sprite.getSpriteLayer("mat_stone");
		if (blobCount > 0)
		{
			if (blobCount >= 200)
			{
				stone.SetFrameIndex(2);
			}
			else if (blobCount >= 100)
			{
				stone.SetFrameIndex(1);
			}
			else
			{
				stone.SetFrameIndex(0);
			}
			stone.SetVisible(true);
		}
		else
		{
			stone.SetVisible(false);
		}
	}
	else if (blobName == "mat_wood")
	{
		CSpriteLayer@ wood = sprite.getSpriteLayer("mat_wood");
		if (blobCount > 0)
		{
			if (blobCount >= 200)
			{
				wood.SetFrameIndex(2);
			}
			else if (blobCount >= 100)
			{
				wood.SetFrameIndex(1);
			}
			else
			{
				wood.SetFrameIndex(0);
			}
			wood.SetVisible(true);
		}
		else
		{
			wood.SetVisible(false);
		}
	}
	else if (blobName == "mat_gold")
	{
		CSpriteLayer@ gold = sprite.getSpriteLayer("mat_gold");
		if (blobCount > 0)
		{
			if (blobCount >= 200)
			{
				gold.SetFrameIndex(2);
			}
			else if (blobCount >= 100)
			{
				gold.SetFrameIndex(1);
			}
			else
			{
				gold.SetFrameIndex(0);
			}
			gold.SetVisible(true);
		}
		else
		{
			gold.SetVisible(false);
		}
	}
	else if (blobName == "mat_bombs")
	{
		CSpriteLayer@ bombs = sprite.getSpriteLayer("mat_bombs");
		if (blobCount > 0)
		{
			if (blobCount >= 2)
			{
				bombs.SetFrameIndex(1);
			}
			else
			{
				bombs.SetFrameIndex(0);
			}
			bombs.SetVisible(true);
		}
		else
		{
			bombs.SetVisible(false);
		}
	}
	else if (blobName == "lantern")
	{
		if (blobCount > 0)
		{
			AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("LANTERN");
			if (isServer() && point.getOccupied() is null)
			{
				CBlob@ lantern = server_CreateBlob("lantern");
				if (lantern !is null)
				{
					lantern.server_setTeamNum(this.getTeamNum());
					lantern.getShape().getConsts().collidable = false;
					this.server_AttachTo(lantern, "LANTERN");
					blob.set_u16("lantern id", lantern.getNetworkID());
					Sound::Play("SparkleShort.ogg", lantern.getPosition());
				}
			}
		}
		else
		{
			if (blob.exists("lantern id"))
			{
				CBlob@ lantern = getBlobByNetworkID(blob.get_u16("lantern id"));
				if (lantern !is null)
				{
					lantern.server_Die();
				}
			}
		}
	}
}

void onDie(CBlob@ this)
{
	if (this.exists("lantern id"))
	{
		CBlob@ lantern = getBlobByNetworkID(this.get_u16("lantern id"));
		if (lantern !is null)
		{
			lantern.server_Die();
		}
	}
}

bool checkName(string blobName)
{
	return (blobName == "mat_stone" || blobName == "mat_wood" || blobName == "mat_gold" || blobName == "mat_bombs" || blobName == "lantern");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return ((this.getTeamNum() > 100 ? true : forBlob.getTeamNum() == this.getTeamNum()) && forBlob.isOverlapping(this));
}