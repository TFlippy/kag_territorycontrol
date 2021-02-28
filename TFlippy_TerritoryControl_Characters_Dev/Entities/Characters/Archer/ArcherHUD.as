//archer HUD
//by The Sopranos (edited by Frikman)

#include "ArcherCommon.as";
#include "nActorHUDStartPos.as";

const string iconsFilename = "jclass.png";
const int slotsSize = 6;

void onInit( CSprite@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
	this.getBlob().set_u8("gui_HUD_slots_width", slotsSize);
}

void ManageCursors( CBlob@ this )
{
	// set cursor
	if (getHUD().hasButtons()) {
		getHUD().SetDefaultCursor();
	}
	else
	{
		// set cursor
		getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32,32));
		getHUD().SetCursorOffset( Vec2f(-32, -32) );
		// frame set in logic
	}
}

void onRender( CSprite@ this )
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();

	ManageCursors( blob );

	// draw inventory
	Vec2f tl = getActorHUDStartPosition(blob, slotsSize);
	DrawInventoryOnHUD( blob, tl );

	// draw coins
	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD( blob, coins, tl, slotsSize-2 );

	// class weapon icon
	int team_num = blob.getTeamNum();
	if (team_num > 6) team_num = 7;
	GUI::DrawIcon( iconsFilename, 2, Vec2f(16, 16), Vec2f(10, 10), 1.0f, team_num);
}
