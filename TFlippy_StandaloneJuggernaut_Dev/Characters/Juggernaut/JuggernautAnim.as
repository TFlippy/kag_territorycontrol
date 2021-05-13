// Jjuggernaut animations

#include "JuggernautCommon.as";
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";
#include "PixelOffsets.as"
#include "RunnerTextures.as"

void onInit(CSprite@ this)
{
	addRunnerTextures(this, "juggernaut", "Juggernaut");

	CBlob@ blob = this.getBlob();
	blob.set_u16("teamOnSpawn", blob.getTeamNum());
}

void onPlayerInfoChanged(CSprite@ this)
{
	ensureCorrectRunnerTexture(this, "juggernaut", "Juggernaut");
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob.get_u16("teamOnSpawn") != blob.getTeamNum()) onInit(this);

	// store some vars for ease and speed
	Vec2f pos = blob.getPosition();
	Vec2f aimpos;

	JuggernautInfo@ juggernaut;
	if (!blob.get("JuggernautInfo", @juggernaut)) return;

	const u8 knocked = getKnocked(blob);

	bool pressed_a1 = blob.isKeyPressed(key_action1);
	bool pressed_a2 = blob.isKeyPressed(key_action2);

	bool walking = (blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right));

	aimpos = blob.getAimPos();

	Vec2f vel = blob.getVelocity();

	if (blob.hasTag("dead"))
	{
		blob.Untag("attack head");
		blob.Tag("dead head");
		if (this.animation.name != "dead") this.SetAnimation("dead");

		//TODO: trigger frame one the first time we server_Die()()
		if (vel.y < -1.0f) this.SetFrameIndex(1);
		else if (vel.y > 1.0f) this.SetFrameIndex(3);
		else this.SetFrameIndex(2);

		return;
	}

	// get the angle of aiming with mouse
	Vec2f vec;

	// animations
	bool grabbed = juggernaut.state == JuggernautStates::grabbed;

	blob.Untag("attack head");
	blob.Untag("dead head");

	if (juggernaut.state != JuggernautStates::fatality) this.SetOffset(Vec2f());

	if (juggernaut.state == JuggernautStates::fatality)
	{
		if (juggernaut.prevState != juggernaut.state) this.SetFacingLeft(false);
		this.SetAnimation("fatality");

		this.SetFacingLeft(false);
		this.SetOffset(Vec2f(-3.0f, -7.0f));
	}
	else if (isKnocked(blob) || blob.hasTag("seated"))
	{
		if (isKnocked(blob)) blob.Tag("dead head");
		else blob.Untag("dead head");
		this.SetAnimation("crouch");
	}
	else if (juggernaut.state == JuggernautStates::charging)
	{
		blob.Tag("attack head");

		this.SetAnimation("charging");
	}
	else if (juggernaut.state == JuggernautStates::chargedAttack)
	{
		blob.Tag("attack head");

		//this.SetFacingLeft(juggernaut.wasFacingLeft);
		this.SetAnimation("chargedAttack");
	}
	else if (juggernaut.state == JuggernautStates::grabbing)
	{
		blob.Tag("attack head");

		f32 angle = juggernaut.attackTrueRot;
		if (angle >= 35.0f && angle <= 145.0f) this.SetAnimation("grabbingUp");
		else if (angle <= 325.0f && angle >= 215.0f) this.SetAnimation("grabbingDown");
		else this.SetAnimation("grabbing");

		//this.SetFacingLeft(juggernaut.wasFacingLeft);
	}
	else if (juggernaut.state == JuggernautStates::throwing)
	{
		blob.Tag("attack head");

		f32 angle = juggernaut.attackTrueRot;
		if (angle >= 35.0f && angle <= 145.0f) this.SetAnimation("throwingUp");
		else if (angle <= 325.0f && angle >= 215.0f) this.SetAnimation("throwingDown");
		else this.SetAnimation("throwing");
	}
	else if (!blob.isOnGround() && !blob.isOnLadder())
	{
		RunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars)) return;

		f32 vy = vel.y;
		if (vy < -0.0f && moveVars.walljumped) this.SetAnimation(grabbed ? "grabbedRun" : "run");
		else
		{
			this.SetAnimation(grabbed ? "grabbedFall" : "fall");
			this.animation.timer = 0;

			if (vy < -1.5) this.animation.frame = 0;
			else if (vy > 1.5) this.animation.frame = 2;
			else this.animation.frame = 1;
		}
	}
	else if (walking || (blob.isOnLadder() && (blob.isKeyPressed(key_up) || blob.isKeyPressed(key_down))))
	{
		this.SetAnimation(grabbed ? "grabbedRun" : "run");
	}
	else if (grabbed) this.SetAnimation("grabbedIdle");
	else defaultIdleAnim(this, blob, blob.getAimDirection(vec));
}

// render cursors
void DrawCursorAt(Vec2f position, string& in filename)
{
	position = getMap().getAlignedWorldPos(position);
	if (position == Vec2f_zero) return;

	position = getDriver().getScreenPosFromWorldPos(position - Vec2f(1, 1));
	GUI::DrawIcon(filename, position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer() || getHUD().hasButtons()) return;

	// draw tile cursor
	if (blob.isKeyPressed(key_action1))
	{
		CMap@ map = blob.getMap();
		Vec2f position = blob.getPosition();
		Vec2f cursor_position = blob.getAimPos();
		Vec2f surface_position;
		map.rayCastSolid(position, cursor_position, surface_position);
		Vec2f vector = surface_position - position;
		f32 distance = vector.getLength();
		Tile tile = map.getTile(surface_position);

		if ((map.isTileSolid(tile) || map.isTileGrass(tile.type)) && map.getSectorAtPosition(surface_position, "no build") is null && distance < 16.0f)
		{
			DrawCursorAt(surface_position, "TileCursor");
		}
	}
}
