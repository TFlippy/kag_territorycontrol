// include file for blobs that use tunnel travel capabilities
// apply "travel tunnel" tag to use

#include "TunnelCommon.as";
#include "KnockedCommon.as"

const string icon_path = "TunnelIcons.png";
const Vec2f frame_dims(32, 32);

//tags
const string reinforcements = "reinforcements allowed";
const string raid = "under raid"; 

string generate_token(int id, bool fortress, bool raid) {
	const string prefix = "TRAVEL_";
	const string fortress_token = "FORTRESS_";
	const string token_raid_suffix = "RAIDED_";
	string ret = "$"+prefix+(fortress ? fortress_token : "")+(raid ? token_raid_suffix : "")+id+"$";
	// print("requested to generate token id: "+id+"; token: "+ret);
	return ret;
}

void onInit(CBlob@ this)
{
	this.addCommandID("travel");
	this.addCommandID("travel none");
	this.addCommandID("travel to");
	this.addCommandID("server travel to");
	this.Tag("travel tunnel");

	if (!this.exists("travel button pos"))
	{
		this.set_Vec2f("travel button pos", Vec2f_zero);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	int team_num = caller.getTeamNum();
	if (team_num > 6) team_num = 0; // icon coloration
	for (int i = 0; i < 8 * 4; ++i) AddIconToken(generate_token(i / 4, i / 2 % 2 == 1, i % 2 == 1), icon_path, frame_dims, i, team_num);
	// if (this.isOverlapping(caller) && this.getTeamNum() < getRules().getTeamsNum() && this.hasTag("travel tunnel") && (this.hasTag("teamlocked tunnel") ? this.getTeamNum() == caller.getTeamNum() : true))
	if (this.isOverlapping(caller) && this.hasTag("travel tunnel") && (this.getTeamNum() >= 100 ? (caller.getTeamNum() >= 100) : (caller.getTeamNum() == this.getTeamNum())))
	{
		MakeTravelButton(this, caller, this.get_Vec2f("travel button pos"), "Travel", "Travel (requires Transport Tunnels)");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	onTunnelCommand(this, cmd, params);
}

// get all team tunnels sorted by team distance

bool getTunnelsForButtons(CBlob@ this, CBlob@[]@ tunnels)
{
	CBlob@[] list;
	getBlobsByTag("travel tunnel", @list);
	Vec2f thisPos = this.getPosition();

	// add left tunnels
	for (uint i = 0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if (blob !is this && (this.getTeamNum() >= 100 ? (blob.getTeamNum() >= 100) : (blob.getTeamNum() == this.getTeamNum())) && blob.getPosition().x < thisPos.x)
		{
			bool added = false;
			const f32 distToBlob = (blob.getPosition() - thisPos).getLength();
			for (uint tunnelInd = 0; tunnelInd < tunnels.length; tunnelInd++)
			{
				CBlob@ tunnel = tunnels[tunnelInd];
				if ((tunnel.getPosition() - thisPos).getLength() < distToBlob)
				{
					tunnels.insert(tunnelInd, blob);
					added = true;
					break;
				}
			}
			if (!added)
				tunnels.push_back(blob);
		}
	}

	tunnels.push_back(null);	// add you are here

	// add right tunnels
	const uint tunnelIndStart = tunnels.length;

	for (uint i = 0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if (blob !is this && (this.getTeamNum() >= 100 ? (blob.getTeamNum() >= 100) : (blob.getTeamNum() == this.getTeamNum())) && blob.getPosition().x >= thisPos.x)
		{
			bool added = false;
			const f32 distToBlob = (blob.getPosition() - thisPos).getLength();
			for (uint tunnelInd = tunnelIndStart; tunnelInd < tunnels.length; tunnelInd++)
			{
				CBlob@ tunnel = tunnels[tunnelInd];
				if ((tunnel.getPosition() - thisPos).getLength() > distToBlob)
				{
					tunnels.insert(tunnelInd, blob);
					added = true;
					break;
				}
			}
			if (!added)
				tunnels.push_back(blob);
		}
	}
	return tunnels.length > 0;
}

bool isInRadius(CBlob@ this, CBlob @caller)
{
	return ((this.getPosition() - caller.getPosition()).Length() < this.getRadius() * 1.01f + caller.getRadius());
}

CButton@ MakeTravelButton(CBlob@ this, CBlob@ caller, Vec2f buttonPos, const string &in label, const string &in cantTravelLabel)
{
	CBlob@[] tunnels;
	const bool gotTunnels = getTunnels(this, @tunnels);
	const bool travelAvailable = gotTunnels && isInRadius(this, caller);
	if (!travelAvailable)
		return null;
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	CButton@ button = caller.CreateGenericButton(8, buttonPos, this, this.getCommandID("travel"), gotTunnels ? label : cantTravelLabel, params);
	if (button !is null)
	{
		button.SetEnabled(travelAvailable);
	}
	return button;
}

bool doesFitAtTunnel(CBlob@ this, CBlob@ caller, CBlob@ tunnel)
{
	return true;
}

void Travel(CBlob@ this, CBlob@ caller, Vec2f position, bool vulnerable)
{
	if (caller !is null)
	{
		if (caller.isAttached())   // attached - like sitting in cata? move whole cata
		{
			const int count = caller.getAttachmentPointCount();
			for (int i = 0; i < count; i++)
			{
				AttachmentPoint @ap = caller.getAttachmentPoint(i);
				CBlob@ occBlob = ap.getOccupied();
				if (occBlob !is null)
				{
					occBlob.setPosition(position);
					occBlob.setVelocity(Vec2f_zero);
					//occBlob.getShape().PutOnGround();
				}
			}
		}
		// move caller
		caller.setPosition(position);
		caller.setVelocity(Vec2f_zero);
		//caller.getShape().PutOnGround();

		if (caller.isMyPlayer())
		{
			Sound::Play("Travel.ogg");
		}
		else
		{
			Sound::Play("Travel.ogg", this.getPosition());
			Sound::Play("Travel.ogg", caller.getPosition());
		}
		//invuln strip
		if (vulnerable && isKnockable(caller))
		{
			//if you travel, you lose invincible
			caller.Untag("invincible");
			caller.Sync("invincible", true);

			// //actually do the knocking
			// setKnocked(caller, 30, true); //idk seas of salt are extra deep with this one
		}
	}
}

void onTunnelCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("travel"))
	{
		const u16 callerID = params.read_u16();
		CBlob@ caller = getBlobByNetworkID(callerID);

		CBlob@[] tunnels;
		if (caller !is null && getTunnels(this, @tunnels))
		{
			// instant travel cause there is just one place to go
			if (tunnels.length == 1)
			{
				Travel(this, caller, tunnels[0].getPosition(), !tunnels[0].hasTag(reinforcements));
			}
			else
			{
				if (caller.isMyPlayer())
					BuildTunnelsMenu(this, callerID);
			}
		}
	}
	else if (cmd == this.getCommandID("travel to"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		CBlob@ tunnel = getBlobByNetworkID(params.read_u16());
		if (caller !is null && tunnel !is null
		        && (this.getPosition() - caller.getPosition()).getLength() < (this.getRadius() + caller.getRadius()) * 2.0f &&
		        doesFitAtTunnel(this, caller, tunnel))
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			//params.write_u16(tunnel.getNetworkID());
			params.write_Vec2f(tunnel.getPosition());
			params.write_bool(!tunnel.hasTag(reinforcements));

			if (tunnel.hasTag(reinforcements))
			{
				if (isServer() && tunnel.getTeamNum() == this.getTeamNum())
				{
					this.SendCommand(this.getCommandID("server travel to"), params);
				}
			}
			else if (tunnel.hasTag(raid) && caller.isMyPlayer()) Sound::Play("MigrantSayNo.ogg");
		}
		else if (!doesFitAtTunnel(this, caller, tunnel) && caller !is null && caller.isMyPlayer())
			Sound::Play("NoAmmo.ogg");
	}
	else if (cmd == this.getCommandID("server travel to"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		Vec2f pos = params.read_Vec2f();
		bool vulnerable = params.read_bool();
		Travel(this, caller, pos, vulnerable);
	}
	else if (cmd == this.getCommandID("travel none"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null && caller.isMyPlayer())
			getHUD().ClearMenus();
	}
}

const int BUTTON_SIZE = 2;

void BuildTunnelsMenu(CBlob@ this, const u16 callerID)
{
	CBlob@[] tunnels;
	getTunnelsForButtons(this, @tunnels);

	CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f((tunnels.length) * BUTTON_SIZE, BUTTON_SIZE), "Pick tunnel to travel");
	if (menu !is null)
	{
		CBitStream exitParams;
		exitParams.write_netid(callerID);
		menu.AddKeyCommand(KEY_ESCAPE, this.getCommandID("travel none"), exitParams);
		menu.SetDefaultCommand(this.getCommandID("travel none"), exitParams);

		for (uint i = 0; i < tunnels.length; i++)
		{
			CBlob@ tunnel = tunnels[i];
			if (tunnel is null)
			{
				menu.AddButton("$CANCEL$", "You are here", Vec2f(BUTTON_SIZE, BUTTON_SIZE));
			}
			else
			{
				CBitStream params;
				params.write_u16(callerID);
				params.write_u16(tunnel.getNetworkID());
				menu.AddButton(getTravelIcon(this, tunnel), getTravelDescription(this, tunnel), this.getCommandID("travel to"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
			}
		}
	}
}

string getTravelIcon(CBlob@ this, CBlob@ tunnel)
{
	float angle = (tunnel.getPosition() - this.getPosition()).AngleRadians();
	angle += Maths::Pi / 8; //offset for proper rounding
	angle += 2 * Maths::Pi; //offset to ensure positiveness
	int index = angle / (Maths::Pi * 2 / 8);
	index = index % 8; //ensure index is in bounds
	return generate_token(index, tunnel.hasTag("faction_base"), tunnel.hasTag(raid));

}

string getTravelDescription(CBlob@ this, CBlob@ tunnel)
{
	string tunnelStatus = (tunnel.hasTag(reinforcements) && tunnel.hasTag(raid) ? " - Contested" : (tunnel.hasTag(raid) ? " - Under attack" : ""));

	return "Travel to " + tunnel.getInventoryName() + " (" + int((tunnel.getPosition() - this.getPosition()).Length() / 8) + "m)" + tunnelStatus;
}
