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

void onRestart(CRules@ this)
{
	CMap@ map = getMap();

	if (map is null) return;

	//preliminary
	map.SetBorderFadeWidth(24.0f);
	map.SetBorderColourLeft(0xff000000);
	map.SetBorderColourRight(0xff000000);
	map.SetBorderColourTop(0xff000000);
	map.SetBorderColourBottom(0xff000000);

	this.AddScript("DefaultBorder.as");
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
