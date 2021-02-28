//knight HUD
//by The Sopranos

#include "/Entities/Common/GUI/nActorHUDStartPos.as";

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
	if (getHUD().hasButtons()) {
		getHUD().SetDefaultCursor();
	}
	else
	{		 	
		if (this.isAttached() && this.isAttachedToPoint("GUNNER")) {
			getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32,32));
			getHUD().SetCursorOffset( Vec2f(-32, -32) );
		}
		else {
			getHUD().SetCursorImage("Entities/Characters/Knight/KnightCursor.png", Vec2f(32,32));
			getHUD().SetCursorOffset( Vec2f(-22, -22) );
		}
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

	u8 type = blob.get_u8("bomb type");
	u8 frame = 1;
	if (type == 0){
		frame = 0;
	}
	else if (type < 255) {
		frame = 1 + type;
	}

	// draw coins

	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD( blob, coins, tl, slotsSize-2 );

	// draw class icon
	int team_num = blob.getTeamNum();
	if (team_num > 6) team_num = 7;
	GUI::DrawIcon( iconsFilename, 1, Vec2f(16, 16), Vec2f(10, 10), 1.0f, team_num);
}

