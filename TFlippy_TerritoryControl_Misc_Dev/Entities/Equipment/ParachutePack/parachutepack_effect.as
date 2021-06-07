#include "RunnerTextures.as"
//Script by Gingerbeard

void onInit(CBlob@ this)
{
	this.addCommandID("deploy_chute");

	if (this.get_string("reload_script") != "parachutepack")
	{
		UpdateScript(this);
	}
}

void UpdateScript(CBlob@ this)
{
	CSpriteLayer@ pack = this.getSprite().addSpriteLayer("pack", "parachutepack.png", 16, 16);
	if (pack !is null)
	{
		pack.SetVisible(true);
		pack.SetRelativeZ(-2);
		pack.SetOffset(Vec2f(0, 0));

		if (this.getSprite().isFacingLeft())
		{
			pack.SetFacingLeft(true);
		}
	}

	CSpriteLayer@ parachute = this.getSprite().addSpriteLayer("parachute", "parachutepack.png", 32, 32);
	if (parachute !is null)
	{
		Animation@ anim = parachute.addAnimation("default", 0, true);
		anim.AddFrame(1);
		parachute.SetOffset(Vec2f(0.0f, - 17.0f));
		parachute.SetVisible(false);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	CBlob@ carried = caller.getCarriedBlob();
	this.addCommandID("deploy_chute");

	bool candeploy = (this.isOnGround() || this.isInWater() || this.isAttached() || this.isOnLadder());
	bool deployavailable = getGameTime() >= this.get_u32("next use");

	if (caller is this && !candeploy && deployavailable && !this.hasTag("parachute"))
	{
		caller.CreateGenericButton(6, Vec2f(0.0f, 0.0f), this, this.getCommandID("deploy_chute"), "Deploy!", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("deploy_chute"))
	{
		this.Tag("parachute");
	}
}

void onTick(CBlob@ this)
{
	bool candeploy = (this.isOnGround() || this.isInWater() || this.isAttached() || this.isOnLadder());
	bool deployavailable = getGameTime() >= this.get_u32("next use");

	if (this.get_string("reload_script") == "parachutepack")
	{
		UpdateScript(this);
		this.set_string("reload_script", "");
	}

	if (isClient())
	{
		CSpriteLayer@ pack = this.getSprite().getSpriteLayer("pack");
		if (pack !is null)
		{
			Vec2f headoffset(this.getSprite().getFrameWidth() / 2, -this.getSprite().getFrameHeight() / 2);
			Vec2f head_offset = getHeadOffset(this, -1, 0);

			headoffset += this.getSprite().getOffset();
			headoffset += Vec2f(-head_offset.x, head_offset.y);
			headoffset += Vec2f(6, 4);
			pack.SetOffset(headoffset);

			if (deployavailable && candeploy && !pack.isVisible())
			{
				pack.SetVisible(true);
				this.getSprite().PlaySound("thud");
			}
		}
	}

	if (this.hasTag("parachute"))
	{
		//Slow down the player's fall speed
		Vec2f vel = this.getVelocity();
		this.setVelocity(Vec2f(vel.x, vel.y * 0.8f));

		ShowParachute(this);
		if (isClient())
		{
			CSpriteLayer@ pack = this.getSprite().getSpriteLayer("pack");
			if (pack !is null && pack.isVisible())
			{
				pack.SetVisible(false);
			}
		}
		if (candeploy)
		{
			HideParachute(this);

			//chicken parachute is temporary
			if (this.hasTag("chicken")) this.RemoveScript("parachutepack_effect.as");
		}
	}
}

void onDie(CBlob@ this)
{
	HideParachute(this);
}

void ShowParachute(CBlob@ this)
{
	if (isClient())
	{
		CSpriteLayer@ parachute = this.getSprite().getSpriteLayer("parachute");
		if (parachute !is null && !parachute.isVisible())
		{
			parachute.SetVisible(true);
			this.getSprite().PlaySound("GetInVehicle");
		}
	}
	this.set_u32("next use", getGameTime() + 70);
}

void HideParachute(CBlob@ this)
{
	if (isClient())
	{
		CSpriteLayer@ parachute = this.getSprite().getSpriteLayer("parachute");

		if (parachute !is null && parachute.isVisible())
		{
			parachute.SetVisible(false);
			ParticlesFromSprite(parachute);
			this.getSprite().PlaySound("join");
		}
	}
	this.Untag("parachute");
}
