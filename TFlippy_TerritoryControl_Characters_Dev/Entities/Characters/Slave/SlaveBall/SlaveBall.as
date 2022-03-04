//Slave ball logic

#include "Hitters.as";

f32 maxDistance = 64.0f;

void onInit(CBlob@ this)
{
	this.Tag("heavy weight");
	this.Tag("ignore fall");
	
	CSprite@ sprite = this.getSprite();
	
	sprite.RemoveSpriteLayer("chain");
	CSpriteLayer@ chain = sprite.addSpriteLayer("chain", "SlaveBall_Chain.png", 32, 2, this.getTeamNum(), 0);

	if (chain !is null)
	{
		Animation@ anim = chain.addAnimation("default", 0, false);
		anim.AddFrame(0);
		chain.SetRelativeZ(-10.0f);
		chain.SetVisible(false);
	}
}

void onTick(CBlob@ this)
{
	CBlob@ slave = getBlobByNetworkID(this.get_u16("slave_id"));
	this.setInventoryName("Slave's Iron Ball: "+(Maths::Round(this.getHealth()/this.getInitialHealth()*1000.0f)/10.0f)+"% HP");
	
	if (slave !is null && slave.getName() == "slave")
	{		
		Vec2f dir = (this.getPosition() - slave.getPosition());
		f32 distance = dir.Length();
		dir.Normalize();
		
		if (distance > maxDistance) 
		{
			slave.setPosition(this.getPosition() - dir * maxDistance * 0.999f);
			
			slave.setVelocity(dir*3.0f);
			this.setVelocity(-dir);
			
			if(isServer()){
				this.server_Hit(this, this.getPosition(), -dir, 0.025f, 0, true);
			}
		} else {
			if(isServer())
			if(getGameTime() % 15 == 0){
				if(getMap().rayCastSolid(this.getPosition(), slave.getPosition())){
					this.server_Hit(this, this.getPosition(), -dir, 0.025f, 0, true);
				}
			}
		}
		
		if (isClient()) DrawLine(this.getSprite(), this.getPosition(), distance / 32, -dir.Angle(), true);
	}
	else
	{
		if (isServer()) this.server_Die();
		if (isClient()) this.getSprite().getSpriteLayer("chain").SetVisible(false);
	}
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getName() != "slave";// || this.isOverlapping(byBlob);
}

void DrawLine(CSprite@ this, Vec2f startPos, f32 length, f32 angle, bool flip)
{
	CSpriteLayer@ chain = this.getSpriteLayer("chain");
	
	chain.SetVisible(true);
	
	chain.ResetTransform();
	chain.ScaleBy(Vec2f(length, 1.0f));
	chain.TranslateBy(Vec2f(length * 16.0f, 0.0f));
	chain.RotateBy(angle + (flip ? 180 : 0), Vec2f());
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case Hitters::builder:
			damage *= 0.2f;
			break;
	}
	
	return damage;

}

void onDie( CBlob@ this ){
	if (isServer()){
		CBlob@ slave = getBlobByNetworkID(this.get_u16("slave_id"));
		
		if (slave !is null && slave.getName() == "slave"){
			CBlob@ peasant = server_CreateBlob("peasant", slave.getTeamNum(), slave.getPosition());

			if (peasant !is null){
				if (slave.getPlayer() !is null) peasant.server_SetPlayer(slave.getPlayer());
				slave.server_Die();
			}
		}
	}
}