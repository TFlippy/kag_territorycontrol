#include "Default/DefaultGUI.as"
#include "Default/DefaultLoaders.as"
#include "PrecacheTextures.as"
#include "EmotesCommon.as"

void onInit(CRules@ this)
{
	LoadDefaultMapLoaders();
	LoadDefaultGUI();

	sv_gravity = 9.81f;
	particles_gravity.y = 0.25f;
	sv_visiblity_scale = 1.25f;
	cc_halign = 2;
	cc_valign = 2;

	s_effects = false;

	sv_max_localplayers = 1;

	PrecacheTextures();

	//reset var if you came from another gamemode that edits it
	SetGridMenusSize(24,2.0f,32);

	//also restart stuff
	onRestart(this);
}

//border stuff!

bool tileOnRow(CMap@ map, const int[]@ row)
{
	//looks for tiles along an X axis of a maps width
	const int mapTileWidth = map.tilemapwidth;

	for (int x = 0; x < mapTileWidth; x++)
	{
		for (int i = 0; i < row.length; i++)
		{
			const int y = row[i];
			if (map.getTileFromTileSpace(Vec2f(x, y)).type != CMap::tile_empty) return true;
		}
	}
	return false;
}

bool tileOnColumn(CMap@ map, const int[]@ column)
{
	//looks for tiles along a Y axis of a maps height
	const int mapTileHeight = map.tilemapheight;

	for (int y = 0; y < mapTileHeight; y++)
	{
		for (int i = 0; i < column.length; i++)
		{
			const int x = column[i];
			if (map.getTileFromTileSpace(Vec2f(x, y)).type != CMap::tile_empty || map.isInWater(map.getTileWorldPosition(Vec2f(x, y)))) return true;
		}
	}
	return false;
}

void onRestart(CRules@ this)
{
	CMap@ map = getMap();

	if (map is null) return;

	map.SetBorderFadeWidth(24.0f);

	const int[] sideBorders = {0, map.tilemapwidth - 1}; //check both sides
	const int[] topBorder = {0};
	const int[] bottomBorder = {map.tilemapheight - 1};

	map.SetBorderColourLeft(tileOnColumn(@map, @sideBorders) ? 0xff000000 : 0x000000);
	map.SetBorderColourRight(tileOnColumn(@map, @sideBorders) ? 0xff000000 : 0x000000);
	map.SetBorderColourTop(tileOnRow(@map, @topBorder) ? 0xff000000 : 0x000000);
	map.SetBorderColourBottom(tileOnRow(@map, @bottomBorder) ? 0xff000000 : 0x000000);

	//remove background on sky maps
	//if (!tileOnRow(@map, @bottomRow)) map.CreateSky(color_white, Vec2f(1.0f, 1.0f), 200, "Sprites/Back/cloud", 0);
}

//chat stuff!

void onEnterChat(CRules@ this)
{
	if (getChatChannel() != 0) return; //no dots for team chat

	CBlob@ localblob = getLocalPlayerBlob();
	if (localblob !is null) set_emote(localblob, Emotes::dots, 100000);
}

void onExitChat(CRules@ this)
{
	CBlob@ localblob = getLocalPlayerBlob();
	if (localblob !is null) set_emote(localblob, Emotes::off);
}
