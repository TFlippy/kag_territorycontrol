// A script by TFlippy & Pirate-Rob

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";
#include "BuilderHittable.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	this.getCurrentScript().tickFrequency = 15;
	this.sendonlyvisible = false;
	
	this.addCommandID("mirror_adjust");
	
	this.set_u16("tower_netid", 0);
	this.set_f32("beam_scale", 1);
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ mirror = this.addSpriteLayer("mirror", "BeamTowerMirror.png", 16, 24);
	if (mirror !is null)
	{
		mirror.SetOffset(Vec2f(0.0f, -8.0f));
		mirror.SetRelativeZ(1.00f);
		mirror.SetFrameIndex(1);
	}
	
	CSpriteLayer@ beam = this.addSpriteLayer("beam", "BeamTower_Beam.png", 4, 4);
	if (beam !is null)
	{
		Animation@ anim = beam.addAnimation("default", 0, false);
		anim.AddFrame(0);
		beam.SetVisible(false);
		beam.setRenderStyle(RenderStyle::additive);
		beam.SetRelativeZ(2.0f);
		beam.SetLighting(false);
		// beam.SetOffset(headOffset);
	}
}

void onTick(CBlob@ this)
{
	f32 power = 0;

	CBlob@ tower = getBlobByNetworkID(this.get_u16("tower_netid"));
	if (tower !is null && !getRules().get_bool("raining") && !getMap().rayCastSolid(this.getPosition(), tower.getPosition() + Vec2f(0, -8)))
	{
		power = Maths::Pow(Maths::Sin(getMap().getDayTime() * Maths::Pi), 6);
	}
	
	this.set_f32("power", power);
	
	if (isClient())
	{
		CSpriteLayer@ beam = this.getSprite().getSpriteLayer("beam");
		if (beam !is null)
		{
			beam.SetVisible(power > 0);
			beam.SetColor(SColor(255, 200 * power, 200 * power, 200 * power));
		}
	}
}

void Adjust(CBlob@ this)
{
	Vec2f pos = this.getPosition();

	CBlob@[] blobs;
	getBlobsByName("beamtower", @blobs);
	
	int distance_sqr = 10000 * 10000;
	int nearest_index = -1;
	
	for (int i = 0; i < blobs.length; i++)
	{
		int blob_distance_sqr = (blobs[i].getPosition() - pos).LengthSquared();
		if (blob_distance_sqr < distance_sqr)
		{
			nearest_index = i;
			distance_sqr = blob_distance_sqr;
		}
	}

	if (nearest_index != -1)
	{
		CBlob@ tower = blobs[nearest_index];
		if (tower !is null)
		{
			this.set_u16("tower_netid", tower.getNetworkID());
			
			Vec2f dir = (tower.getPosition() - Vec2f(0, 8) - this.getPosition());
			f32 dist = dir.getLength();
			dir.Normalize();
			
			if (isClient())
			{
				f32 angle = dir.Angle();
			
				CSpriteLayer@ mirror = this.getSprite().getSpriteLayer("mirror");
				if (mirror !is null)
				{
					mirror.ResetTransform();
					mirror.RotateBy(-angle, Vec2f());
				}
				
				CSpriteLayer@ beam = this.getSprite().getSpriteLayer("beam");
				if (beam !is null)
				{
					f32 scale = 8;
					f32 initial_scale = this.get_f32("beam_scale");
					if (initial_scale == 0) initial_scale = 1;
				
					beam.ResetTransform();
					beam.ScaleBy(Vec2f((dist / 4.0f) / initial_scale, (1.00f / initial_scale) * scale));
					beam.TranslateBy(Vec2f((dist / 2), 0));
					beam.RotateBy(-angle, Vec2f());
					beam.SetOffset(Vec2f(0, -4) + (dir * 2));
						
					this.set_f32("beam_scale", scale);
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("mirror_adjust"))
	{
		Adjust(this);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!this.isOverlapping(caller)) return;
	
	CBitStream params;
	CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("mirror_adjust"), "Adjust", params);
}