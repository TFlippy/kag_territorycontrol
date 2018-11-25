void onRender(CSprite@ this)
{
	//make sure this script is last in order
	CBlob@ blob=	this.getBlob();			if(blob is null){return;}
	CBlob@ item=	blob.getCarriedBlob();	if(item is null){return;}
	CPlayer@ player=blob.getPlayer();		if(player is null){return;}
	
	if(!player.isLocal() || !getNet().isClient()){
		return;
	}
	
	if(item.hasTag("isWeapon")){
		u32 clip=		item.get_u32("gun_clip");
		u32 clipSize=	item.get_u32("gun_clipSize");
		CHUD@ hud=getHUD();
		hud.SetCursorImage("WeaponCursor.png",Vec2f(32,32));
		hud.SetCursorOffset(Vec2f(-32,-32));
		u32 gameTime=	getGameTime();
		u32 endTime=	item.get_u32("gun_readyTime");
		if(!item.get_bool("gun_doReload") || item.get_bool("gun_shotgunReload")){
			hud.SetCursorFrame(Maths::Clamp((clip==0 ? 0.0f : 1.0f)+Maths::Round((f32(clip)/f32(clipSize))*7.0f),0,8));
		}else{
			u32 reloadTime=	item.get_u32("gun_reloadTime");
			u32 startTime=	endTime-reloadTime;
			u32 relative=	gameTime-startTime;
			hud.SetCursorFrame(Maths::Clamp(1.0f+Maths::Floor((f32(relative)/f32(reloadTime))*7.0f),0,8));
		}
		hud.ShowCursor();
	}
}