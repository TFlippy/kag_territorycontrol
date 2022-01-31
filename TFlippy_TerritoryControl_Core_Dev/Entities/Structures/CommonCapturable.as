#include "Survival_Structs.as";
#include "Survival_Icons.as";
#include "uncap_team.as"

/*
 * convertible if enemy outnumbers friends in radius
 */

const string counter_prop = "capture ticks";
const string raid_tag = "under raid";
const string chicken_tag = "chicken raid";
const string reinforcements_tag = "reinforcements allowed";

// const u16 capture_seconds = 10;
const u16 capture_radius = 44;

const string friendly_prop = "capture friendly count";
const string enemy_prop = "capture enemy count";



void onInit(CBlob@ this)
{
	this.addCommandID("convert");
	this.addCommandID("abandon");
	this.getCurrentScript().tickFrequency = 30;

	// f32 capture_modifier = this.exists("capture_speed_modifier") ? this.get_f32("capture_speed_modifier") : 1.00f;
	// u32 capture_seconds = this.getInitialHealth() * capture_modifier;

	this.set_s16(counter_prop, getCaptureSeconds(this));
	this.set_s16(friendly_prop, 0);
	this.set_s16(enemy_prop, 0);

	this.set_u16("last_friendly_visit",getGameTime());

	this.Tag("capturable");
}

u32 getCaptureSeconds(CBlob@ this)
{
	f32 capture_modifier = this.exists("capture_speed_modifier") ? this.get_f32("capture_speed_modifier") : 1.00f;
	return 15.00f * (this.getHealth() / this.getInitialHealth()) * capture_modifier;
}

//add
// void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
// {
	// if (!this.hasTag("convert on sit")) return;

	// if (attachedPoint.socket && attached.getTeamNum() != this.getTeamNum() && attached.hasTag("player"))
	// {
		// this.server_setTeamNum(attached.getTeamNum());
	// }
// }

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	bool reset_timer = true;
	bool sync = false;

	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), capture_radius, @blobsInRadius))
	{
		// count friendlies and enemies
		int attackersCount = 0;
		int friendlyCount = 0;

		int attackerTeam = 255;
		Vec2f pos = this.getPosition();
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is this && b.hasTag("player") && !b.hasTag("dead") && !b.hasTag("ignore_flags") && !b.hasTag("noCapturing"))
			{
				// if (b.getTeamNum() != this.getTeamNum() && (this.getTeamNum() == 255 ? (this.hasTag("can be captured by neutral") ? this.getTeamNum() < 8 : b.getTeamNum() < 8)))
				// && (this.getTeamNum() == 255 && this.hasTag("can be captured by neutral") ? true : b.getTeamNum() < 8)
				if ((b.getTeamNum() != this.getTeamNum()) && ((this.getTeamNum() == 255 && this.hasTag("can be captured by neutral")) || ((!b.hasTag("neutral") && b.getTeamNum() < 7) || (b.getTeamNum() == 250 && this.hasTag("faction_base")))))
				{
					Vec2f bpos = b.getPosition();
					if (bpos.x > pos.x - this.getWidth() / 1.0f && bpos.x < pos.x + this.getWidth() / 1.0f && bpos.y < pos.y + this.getHeight() / 1.0f && bpos.y > pos.y - this.getHeight() / 1.0f)
					{
						attackersCount++;
						attackerTeam = b.getTeamNum();

						if (b.hasTag("combat chicken")) this.Tag(chicken_tag);
					}
				}
				else if((b.getTeamNum()>=0 && b.getTeamNum()<7) || this.hasTag("can be captured by neutral")) 
				{
					friendlyCount++;
				}
			}
		}

		u32 capture_seconds = getCaptureSeconds(this);
		
		int ticks = capture_seconds;
		if (this.hasTag(raid_tag))
		{
			ticks = this.get_s16(counter_prop);
		}

		if (attackersCount > 0 || ticks < capture_seconds)
		{
			//convert
			if (attackersCount > friendlyCount)
			{
				ticks = Maths::Max(ticks - 1, 0);
			}
			//un-convert gradually
			else if (attackersCount < friendlyCount || attackersCount == 0)
			{
				ticks = Maths::Min(ticks + 1, capture_seconds);
			}

			this.set_s16(counter_prop, ticks);
			this.Tag(raid_tag);
			if (attackersCount > friendlyCount) {
				this.Untag(reinforcements_tag);
			} else {
				this.Tag(reinforcements_tag);
			}

			if (ticks <= 0 && friendlyCount == 0)
			{
				if (this.hasTag(chicken_tag) && (this.getName() == "convent" || this.getName() == "citadel" || this.getName() == "fortress" || this.getName() == "stronghold" || this.getName() == "camp"))
				{
					if (isServer())
					{
						CBlob@ base = server_CreateBlob("chicken" + this.getName(), 250, this.getPosition());
						base.server_SetHealth(this.getHealth());

						this.server_Die();
					}
				}
				else
				{
					this.server_setTeamNum(attackerTeam < 8 ? attackerTeam : -1);
				}

				reset_timer = true;
			}
			else
			{
				this.set_s16(friendly_prop, friendlyCount);
				this.set_s16(enemy_prop, attackersCount);
				reset_timer = false;
			}

			sync = true;
		}
	}
	else
	{
		this.Untag(raid_tag);
		this.Untag(chicken_tag);
		this.Tag(reinforcements_tag);
	}

	if (reset_timer)
	{
		this.set_s16(friendly_prop, 0);
		this.set_s16(enemy_prop, 0);

		u32 capture_seconds = getCaptureSeconds(this);

		this.set_s16(counter_prop, capture_seconds);
		this.Untag(raid_tag);
		this.Untag(chicken_tag);
		this.Tag(reinforcements_tag);

		sync = true;
	}

	if (sync)
	{
		this.Sync(friendly_prop, true);
		this.Sync(enemy_prop, true);

		this.Sync(counter_prop, true);
		this.Sync(raid_tag, true);
		this.Sync(reinforcements_tag, true);
	}

	// if(!this.hasTag("faction_base"))
	// if(this.get_u16("last_friendly_visit")+30*60*3 < getGameTime()){
		// if(isServer()){
			// this.server_setTeamNum(-1);
		// }
	// }
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.isOverlapping(this) && !this.hasTag("faction_base"))
	{
		if (this.getName() != "merchant" && this.getName() != "witchshack")
		{
			if (caller.getTeamNum() == this.getTeamNum() && this.getTeamNum() < 100)
			{
				CPlayer@ myPly = caller.getPlayer();
				if (myPly !is null && caller.isMyPlayer())
				{
					TeamData@ team_data;
					GetTeamData(this.getTeamNum(), @team_data);
					if (team_data !is null)
					{
						const bool isLeader = team_data.leader_name == myPly.getUsername();
						if (isLeader)
						{
							CBitStream no_params;
							CButton@ butt = caller.CreateGenericButton(33, Vec2f(-0, -15), this, this.getCommandID("abandon"), "Abandon this building", no_params);
							//abandon the building
						}
					}
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ inParams)
{
	if (cmd == this.getCommandID("abandon"))
	{
		this.server_setTeamNum(pure_neutral_team);
	}
}

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	if (this.getTeamNum() >= 0 && this.getTeamNum() < 8)
	{
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			sprite.PlaySound("/VehicleCapture");
		}
		// this.set_u16("last_friendly_visit",getGameTime());
	}
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	if (blob is null || !blob.hasTag(raid_tag))
		return;

	Vec2f pos2d = getDriver().getScreenPosFromWorldPos(blob.getPosition() + Vec2f(0.0f, -blob.getHeight()));

	s16 friendlyCount = blob.get_s16(friendly_prop);
	s16 enemyCount = blob.get_s16(enemy_prop);

	// draw background pane
	f32 hwidth = 45 + Maths::Max(0, Maths::Max(friendlyCount, enemyCount) - 3) * 8;
	f32 hheight = 30;

	// sit it above the rest of everything
	pos2d.y -= hheight;

	GUI::DrawPane(pos2d - Vec2f(hwidth, hheight), pos2d + Vec2f(hwidth, hheight));

	//draw balance of power
	for (int i = 1; i <= friendlyCount; i++)
		GUI::DrawIcon("VehicleConvertIcon.png", 0, Vec2f(8, 16), pos2d + Vec2f(i * 8 - 8, -24), 1.0f, blob.getTeamNum());
	for (int i = 1; i <= enemyCount; i++)
		GUI::DrawIcon("VehicleConvertIcon.png", 1, Vec2f(8, 16), pos2d + Vec2f(i * -8 - 8, -24), 1.0f);

	u32 capture_seconds = getCaptureSeconds(blob);
	if (capture_seconds <= 0) capture_seconds = 1; // ugly hackfix

	//draw capture bar
	f32 padding = 4.0f;
	s32 captureTime = blob.get_s16(counter_prop);
	GUI::DrawProgressBar(Vec2f(pos2d.x - hwidth + padding, pos2d.y + hheight - 18 - padding), Vec2f(pos2d.x + hwidth - padding, pos2d.y + hheight - padding), 1.0f - float(captureTime) / float(capture_seconds));
}
