#include "Hitters.as";
#include "HittersTC.as";
#include "MakeMat.as";
#include "MaterialCommon.as";

// A script by TFlippy

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.Tag("change team on fort capture");

	this.getSprite().SetZ(-10.0f);
	this.set_u32("security_link_id", u32(this.getNetworkID()));

	if (isServer())
	{
		CBlob@ card = server_CreateBlobNoInit("securitycard");
		card.setPosition(this.getPosition());
		card.set_u32("security_link_id", this.get_u32("security_link_id"));
		card.server_setTeamNum(this.getTeamNum());
		card.Init();
	}

	this.setInventoryName("Security Station #" + this.get_u32("security_link_id"));
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller !is null && caller.isOverlapping(this))
	{
		CBlob@[] blobs;
		getBlobsByTag("security_linkable", @blobs);

		u32 link = this.get_u32("security_link_id");
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if (blob !is null)
			{
				// Vec2f deltaPos = (blob.getPosition() - this.getPosition()) * 0.50f;
				u32 blob_link = blob.get_u32("security_link_id");

				CBitStream params;
				params.write_bool(!blob.get_bool("security_state"));

				CButton@ button = caller.CreateGenericButton(11, Vec2f(0, -8), blob, blob.getCommandID("security_set_state"), "Toggle", params);
				button.enableRadius = 256;
				button.SetEnabled((blob_link == link || blob_link == 0) && blob.getTeamNum() != 250);
			}
		}
	}
}
