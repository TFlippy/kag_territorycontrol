void onInit(CBlob@ this)
{
	this.Tag("heavy weight");
	
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PILOT");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_up);
	}
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

// Commented out just in case someone would want to have a jewish wedding in TC
// bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
// {
	// return !this.hasAttached();
// }

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("furniture");
}