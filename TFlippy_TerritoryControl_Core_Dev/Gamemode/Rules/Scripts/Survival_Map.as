#include "CustomBlocks.as";

void onInit(CRules@ this)
{
	Reset(this, getMap());
}

void onRestart(CRules@ this)
{
	Reset(this, getMap());
}

void onRulesRestart(CMap@ this, CRules@ rules)
{
	Reset(rules, this);
}

void Reset(CRules@ this, CMap@ map)
{
	if (map !is null)
	{
		map.SetBorderFadeWidth(16);	
		
		map.SetBorderColourTop(SColor(255, 0, 0, 0));
		map.SetBorderColourLeft(SColor(255, 0, 0, 0));
		map.SetBorderColourRight(SColor(255, 0, 0, 0));
		map.SetBorderColourBottom(SColor(255, 0, 0, 0));
		
		if (!this.exists("map_type")) this.set_u8("map_type", MapType::normal);
	}
}

// Vec2f[] cloud_pos;
// Vec2f[] cloud_uv;
// SColor[] cloud_colors;

// void onRender(CRules@ this)
// {
	
	// CBlob@ blob = getLocalPlayerBlob();
	// Vec2f pos = blob.getPosition();
	
	// Vec2f[] positions = 
	// {
		// pos + Vec2f(0, 0),
		// pos + Vec2f(200, 0),
		// pos + Vec2f(200, 100),
		// pos + Vec2f(0, 100)
	// };
	
	// Vec2f[] uv = 
	// {
		// Vec2f(0, 0),
		// Vec2f(1, 0),
		// Vec2f(1, 1),
		// Vec2f(0, 1)
	// };
	
	// SColor[] colors = 
	// {
		// SColor(200, 255, 255, 255),
		// SColor(200, 255, 255, 255),
		// SColor(0, 255, 255, 255),
		// SColor(0, 255, 255, 255)
	// };
	
	// Render::QuadsColored("cloud2.png", 0, positions, uv, colors);

	// // print("r");

	// // void Render::Quads(const string&in texture, float z, const Vec2f[]&in pos, const Vec2f[]&in uv)
// }

void onTick(CRules@ this)
{
	// if (getGameTime() % (60 * 30) == 0) Reset(this, getMap()); // Damn hack
	
	// CMap@ map = getMap();
	// map.SetBorderFadeWidth(16);
	
	// map.SetBorderColourTop(SColor(0, 0, 0, 0));
	// map.SetBorderColourLeft(SColor(255, 0, 0, 0));
	// map.SetBorderColourRight(SColor(255, 0, 0, 0));
	// map.SetBorderColourBottom(SColor(255, 0, 0, 0));
	
	// map.SetBorderColourTop(SColor(255, 0, 0, 0));
	// map.SetBorderColourLeft(SColor(255, 0, 0, 0));
	// map.SetBorderColourRight(SColor(255, 0, 0, 0));
	// map.SetBorderColourBottom(SColor(255, 0, 0, 0));
}
