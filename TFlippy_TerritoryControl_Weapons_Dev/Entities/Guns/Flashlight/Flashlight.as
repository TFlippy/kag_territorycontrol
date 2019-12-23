#include "CommonGun.as";

const f32 max_distance = 256.0f;

void onInit(CBlob@ this)
{
	this.Tag("no shitty rotation reset");

	this.SetLight(true);
	this.SetLightRadius(96.0f);
	this.SetLightColor(SColor(255, 180, 230, 255));
	
	if (isServer())
	{		
		CBlob@ blob = server_CreateBlobNoInit("flashlight_light");
		blob.set_u16("remote_netid", this.getNetworkID());
		blob.setPosition(this.getPosition());
		
		blob.Init();

		this.set_u16("remote_netid", blob.getNetworkID());
	}
}

void onTick(CBlob@ this)
{
	if (isClient())
	{
		GunTick(this);
	
		Vec2f startPos = this.getPosition();
		Vec2f hitPos;
		f32 length;
		bool flip = this.isFacingLeft();	
		
		f32 angle =	this.getAngleDegrees();
		
		Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1),0.0f).RotateBy(angle);
		Vec2f endPos = startPos + dir * max_distance;

		HitInfo@[] hitInfos;
		bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
		length = (hitPos - startPos).Length();
		bool blobHit = getMap().getHitInfosFromRay(startPos, angle + (flip ? 180.0f : 0.0f), length, this, @hitInfos);
		
		CBlob@ light = getBlobByNetworkID(this.get_u16("remote_netid"));
		
		if (light !is null)
		{
			light.setPosition(hitPos);
		}
	}
}

void onDie(CBlob@ this)
{
	CBlob@ light = getBlobByNetworkID(this.get_u16("remote_netid"));
	
	if (light !is null)
	{
		light.server_Die();
	}
}