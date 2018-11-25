#include "MaterialCommon.as";

void MakeMat(CBlob@ this, Vec2f worldPoint, const string& in name, int quantity)
{
	Material::createFor(this, name, quantity);
}