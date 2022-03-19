// A script by TFlippy & Pirate-Rob

#include "Requirements.as";
#include "MakeMat.as";
#include "BuilderHittable.as";

const u8 inventory_size = 2 * 3;

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	this.Tag("builder always hit");
	this.Tag("change team on fort capture");
	this.Tag("extractable");
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	UpdateFrame(this);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	UpdateFrame(this);
}

void UpdateFrame(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	
	Animation@ animation = sprite.getAnimation("default");
	if (animation is null) return;
	
	CInventory@ inv = this.getInventory();
	if (inv is null) return;
	
	sprite.animation.frame = u8((sprite.animation.getFramesCount() - 1) * (f32(inv.getItemsCount()) / f32(inventory_size)));
}