void onInit(CBlob@ this)
{
	this.Tag("heavy weight");
	
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PILOT");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_up);
		ap.offsetZ = 50;
		ap.offset = Vec2f(-1, -5);
	}
	
	// CSprite@ sprite = this.getSprite();
	// CSpriteLayer@ foreground = sprite.addSpriteLayer("foreground", sprite.getFilename(), 16, 24);
	// if (foreground !is null)
	// {
		// foreground.setZ(50);
	// }
	
	this.getSprite().SetZ(50.0f);
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PILOT");
	if (ap !is null)
	{
		if (ap.isKeyJustPressed(key_up))
		{
			if (isServer())
			{
				CBlob@ pilot = ap.getOccupied();
				if (pilot !is null)  pilot.server_DetachFrom(this);
			}
		}
	}
}		

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("furniture");
}