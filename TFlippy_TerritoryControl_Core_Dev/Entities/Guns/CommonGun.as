#include "Hitters.as";
#include "HittersTC.as";
#include "DeityCommon.as";

//huge bug with SetKeysToTake only disabling stuff CLIENTSIDE - you're still actually jabbing when using a weapon
	//looks like the only way to fix this is to add a check to all classes - do they have a tag "disableLMB", or custom tag to disable LMB stuff.
	//this fix isn't implemented, i only tagged weapons with "disableLMB" tag, nothing else.
	//this was a bug before i ever touched anything, btw.
	
//bug with weapons not aligning right, but that's not my problem

class SoundInfo
{
	string filename;
	f32 volume;
	f32 pitch;
	u32 range;
	
	SoundInfo()
	{
		filename=	"";
		volume=		1.0f;
		pitch=		1.0f;
		range=		0;
	}
	SoundInfo(string newFilename,u32 newRange,f32 newVolume,f32 newPitch)
	{
		filename=	newFilename;
		volume=		newVolume;
		pitch=		newPitch;
		range=		newRange;
	}
};

//Raycast Gun Init
void GunInitRaycast(CBlob@ this, bool isAutomatic, f32 fireDamage, f32 fireRange, u32 fireDelay, u32 clipSize, f32 ammoUsageFactor,u32 reloadTime,bool shotgunReload,u32 shotgunEndDelay, u8 bulletCount, f32 bulletJitter, string ammoItem, bool soundFireLoop, SoundInfo soundFire, SoundInfo soundReload, SoundInfo soundDelayed, u32 soundDelayedDelay, Vec2f lineOffset)
{
	AttachmentPoint@ ap=this.getAttachments().getAttachmentPointByName("PICKUP");
	if(ap !is null) {
		ap.SetKeysToTake(key_action1);
	}
	
	this.getShape().SetRotationsAllowed(true);
	this.Tag("no shitty rotation reset");
	this.Tag("isWeapon");
	this.Tag("hopperable");
	this.addCommandID("cmd_gunReload");
	
	//default
	this.set_bool	("gun_isAutomatic",			isAutomatic);
	this.set_string	("gun_fireProj",			"");
	this.set_f32	("gun_fireProjSpeed",		1.0f);
	this.set_f32	("gun_fireDamage",			fireDamage);
	this.set_f32	("gun_fireRange",			fireRange);
	this.set_u32	("gun_fireDelay",			fireDelay);
	this.set_u32	("gun_readyTime",			0);
	this.set_u32	("gun_clipSize",			clipSize);
	this.set_f32	("gun_ammoUsage",			ammoUsageFactor);
	this.set_u32	("gun_clip",				0);
	this.set_u32	("gun_ammoToGive",			0);
	this.set_bool	("gun_wasEmpty",			false);
	this.set_bool	("gun_doReload",			false);
	this.set_bool	("gun_reloadKeyPressed",	false);
	this.set_u32	("gun_reloadTime",			reloadTime);
	this.set_bool	("gun_shotgunReload",		shotgunReload);
	this.set_u32	("gun_shotgunEndDelay",		shotgunEndDelay);
	this.set_u8		("gun_bulletCount",			bulletCount);
	this.set_f32	("gun_bulletJitter",		bulletJitter);
	this.set_string	("gun_ammoItem",			ammoItem);
	
	this.set_bool	("gun_soundFireLoop",		soundFireLoop);
	this.set_bool	("gun_soundFireLoopStarted",false);
	this.set_string	("gun_soundFire",			soundFire.filename);
	this.set_f32	("gun_soundFireVolume",		soundFire.volume);
	this.set_f32	("gun_soundFirePitch",		soundFire.pitch);
	this.set_u32	("gun_soundFireRange",		soundFire.range);
	this.set_string	("gun_soundReload",			soundReload.filename);
	this.set_f32	("gun_soundReloadVolume",	soundReload.volume);
	this.set_f32	("gun_soundReloadPitch",	soundReload.pitch);
	this.set_u32	("gun_soundReloadRange",	soundReload.range);
	this.set_string	("gun_soundDelayed",		soundDelayed.filename);
	this.set_f32	("gun_soundDelayedVolume",	soundDelayed.volume);
	this.set_f32	("gun_soundDelayedPitch",	soundDelayed.pitch);
	this.set_u32	("gun_soundDelayedRange",	soundDelayed.range);
	this.set_u32	("gun_soundDelayedDelay",	soundDelayedDelay);
	
	if (!this.exists("gun_hitter")) this.set_u8("gun_hitter", HittersTC::bullet_low_cal);
	
	this.set_u32	("gun_soundDelayedTime",	0);
	this.set_Vec2f	("gun_projOffset",			Vec2f(0.0f,0.0f));
	this.set_Vec2f	("gun_lineOffset",			lineOffset);
	this.set_bool	("gun_needsRelease",		false);
}
//Projectile gun init
void GunInitProjectile(CBlob@ this,bool isAutomatic,string fireProj,f32 fireProjSpeed,u32 fireDelay,u32 clipSize,f32 ammoUsageFactor,u32 reloadTime,bool shotgunReload,u32 shotgunEndDelay,string ammoItem,bool soundFireLoop,SoundInfo soundFire,SoundInfo soundReload,SoundInfo soundDelayed,u32 soundDelayedDelay,Vec2f projOffset)
{
	AttachmentPoint@ ap=this.getAttachments().getAttachmentPointByName("PICKUP");
	if(ap !is null) {
		ap.SetKeysToTake(key_action1);
	}
	this.getShape().SetRotationsAllowed(true);
	this.Tag("no shitty rotation reset");
	this.Tag("isWeapon");
	this.Tag("hopperable");
	if(this.hasCommandID("cmd_gunReload")){
		return;
	}
	this.addCommandID("cmd_gunReload");
	
	//default
	this.set_bool	("gun_isAutomatic",			isAutomatic);
	this.set_string	("gun_fireProj",			fireProj);
	this.set_f32	("gun_fireProjSpeed",		fireProjSpeed);
	this.set_f32	("gun_fireDamage",			0.0f);	
	this.set_f32	("gun_fireRange",			0.0f);
	this.set_u32	("gun_fireDelay",			fireDelay);
	this.set_u32	("gun_readyTime",			0);
	this.set_u32	("gun_clipSize",			clipSize);
	this.set_f32	("gun_ammoUsage",			ammoUsageFactor);
	this.set_u32	("gun_clip",				0);
	this.set_u32	("gun_ammoToGive",			0);
	this.set_bool	("gun_wasEmpty",			false);
	this.set_bool	("gun_doReload",			false);
	this.set_bool	("gun_reloadKeyPressed",	false);
	this.set_u32	("gun_reloadTime",			reloadTime);
	this.set_bool	("gun_shotgunReload",		shotgunReload);
	this.set_u32	("gun_shotgunEndDelay",		shotgunEndDelay);
	this.set_u8		("gun_bulletCount",			1);
	this.set_f32	("gun_bulletJitter",		0.00f);
	this.set_string	("gun_ammoItem",			ammoItem);
	
	this.set_bool	("gun_soundFireLoop",		soundFireLoop);
	this.set_bool	("gun_soundFireLoopStarted",false);
	this.set_string	("gun_soundFire",			soundFire.filename);
	this.set_f32	("gun_soundFireVolume",		soundFire.volume);
	this.set_f32	("gun_soundFirePitch",		soundFire.pitch);
	this.set_u32	("gun_soundFireRange",		soundFire.range);
	this.set_string	("gun_soundReload",			soundReload.filename);
	this.set_f32	("gun_soundReloadVolume",	soundReload.volume);
	this.set_f32	("gun_soundReloadPitch",	soundReload.pitch);
	this.set_u32	("gun_soundReloadRange",	soundReload.range);
	this.set_string	("gun_soundDelayed",		soundDelayed.filename);
	this.set_f32	("gun_soundDelayedVolume",	soundDelayed.volume);
	this.set_f32	("gun_soundDelayedPitch",	soundDelayed.pitch);
	this.set_u32	("gun_soundDelayedRange",	soundDelayed.range);
	this.set_u32	("gun_soundDelayedDelay",	soundDelayedDelay);
	
	this.set_u32	("gun_soundDelayedTime",	0);
	this.set_Vec2f	("gun_projOffset",			projOffset);
	this.set_Vec2f	("gun_lineOffset",			Vec2f(0.0f,0.0f));
	this.set_bool	("gun_needsRelease",		false);
}
void GunTick(CBlob@ this)
{
	CSprite@ sprite=this.getSprite();
	if(sprite is null){
		return;
	}
	const bool soundFireLoop=	this.get_bool("gun_soundFireLoop");
	if(!this.isAttached()){
		if(soundFireLoop){
			sprite.SetEmitSoundPaused(true);
			this.set_bool("gun_soundFireLoopStarted",false);
		}
		return;
	}
	AttachmentPoint@ point=	this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null){return;}
		CBlob@ holder=			point.getOccupied();
		//point.SetKeysToTake(key_action1); //this..... doesn't work........ serverside......
	if(holder is null){
		if(soundFireLoop){
			sprite.SetEmitSoundPaused(true);
			this.set_bool("gun_soundFireLoopStarted",false);
		}
		return;
	}
	
	CInventory@ inv=	holder.getInventory();
	CPlayer@ player=	holder.getPlayer();
	UpdateAngle(this);
	
	holder.Tag("noLMB");
	holder.Tag("noShielding");
	
	const string ammoItem=		this.get_string("gun_ammoItem");
	const bool hasDelayedSound=	this.get_string("gun_soundDelayed")!="";
	if(hasDelayedSound){
		u32 delayedSoundTime=this.get_u32("gun_soundDelayedTime");
		if(delayedSoundTime!=0 && getGameTime()>delayedSoundTime){
			PlayWeaponSound(this,"gun_soundDelayed");
			this.set_u32("gun_soundDelayedTime",0);
		}
	}
	if(this.get_bool("gun_doReload")){
		if(getGameTime()>this.get_u32("gun_readyTime")){
			//end reload and fill the clip
			this.set_u32("gun_clip",this.get_u32("gun_clip")+this.get_u32("gun_ammoToGive"));
			if(!this.get_bool("gun_shotgunReload")){
				this.set_bool("gun_doReload",false);
			}else{
				if(isClient()) {
					PlayWeaponSound(this,"gun_soundReload");
				}
				if(this.get_u32("gun_clip")!=this.get_u32("gun_clipSize") && CountAmmo(inv,ammoItem)>0) {
					TakeAmmo(inv,ammoItem,1);
					this.set_u32("gun_readyTime",getGameTime()+this.get_u32("gun_reloadTime"));
					this.set_u32("gun_ammoToGive",1);
					this.set_bool("gun_doReload",true);
				}else{
					if(hasDelayedSound && this.get_bool("gun_wasEmpty")){
						this.set_u32("gun_readyTime",getGameTime()+this.get_u32("gun_shotgunEndDelay"));
						this.set_u32("gun_soundDelayedTime",getGameTime()+this.get_u32("gun_soundDelayedDelay"));
					}else{
						this.set_u32("gun_readyTime",getGameTime()+(this.get_u32("gun_shotgunEndDelay")/2));
					}
					this.set_bool("gun_doReload",false);
				}
			}
		}
	}

	u32 clip=		this.get_u32("gun_clip");
	u32 clipSize=	this.get_u32("gun_clipSize");
	
	f32	ammoUsage=	this.get_f32("gun_ammoUsage");
	CControls@ controls=	getControls();
	if(player !is null){
		if(isClient() && player.isMyPlayer()){
			if(controls.isKeyJustPressed(KEY_KEY_R) && this.hasCommandID("cmd_gunReload")) {
				CBitStream stream;
				this.SendCommand(this.getCommandID("cmd_gunReload"),stream);
			}
		}
	}
	if(this.get_bool("gun_reloadKeyPressed")){
		if(getGameTime()>this.get_u32("gun_readyTime")){
			u32 ammo=	CountAmmo(inv,ammoItem);
			if(ammo>0){
				if(clip!=clipSize){
					StartReload(this,inv,ammoItem,clip,clipSize);
				}
			}else{
				if(isClient() && holder.hasTag("flesh")) {
					this.getSprite().PlaySound("Entities/Characters/Sounds/NoAmmo.ogg",0.6f,1.0);
				}
			}
			this.set_bool("gun_reloadKeyPressed",false);
		}
	}
	
	
	bool isHolderAttached = holder.isAttached();
	// bool isHolderAttached = holder.isAttached() ? false : holder.
	
	// AttachmentPoint@ point = holder.getAttachments().getAttachmentPointByName("PICKUP");
	// if (point !is null) 
	// {
		// CBlob@ gun = point.getOccupied();
		// if(gun !is null) 
		// {
			// if (blob.get_u32("nextAttack") < getGameTime())
			// {							
				// blob.setKeyPressed(key_action1,true);
				// blob.set_u32("nextAttack", getGameTime() + blob.get_u8("attackDelay"));
			// }
		// }
	// }
	
	if((point.isKeyPressed(key_action1) || holder.isKeyPressed(key_action1)) && !isHolderAttached  && !(holder.get_u8("knocked") > 0 )&& !(holder.get_f32("babbyed") > 0)) {
		if(!this.get_bool("gun_needsRelease") && getGameTime()>this.get_u32("gun_readyTime")) {
			if(clip>=1){
				clip-=1;
				this.set_u32("gun_clip",clip);
				Shoot(this);
				this.set_u32("gun_readyTime",getGameTime()+this.get_u32("gun_fireDelay"));
				if(hasDelayedSound){
					this.set_u32("gun_soundDelayedTime",getGameTime()+this.get_u32("gun_soundDelayedDelay"));
				}
				if(!this.get_bool("gun_isAutomatic")){
					this.set_bool("gun_needsRelease",true);
				}
				if(isClient()) {
					if(!soundFireLoop){
						PlayWeaponSound(this,"gun_soundFire");
					}else{
						if(!this.get_bool("gun_soundFireLoopStarted")){
							sprite.RewindEmitSound();
							u32 range=	this.get_u32("gun_soundFireRange");
							sprite.SetEmitSound(this.get_string("gun_soundFire")+(range>1 ? formatFloat(XORRandom(range-1)+1,"")+".ogg" : ".ogg"));
							sprite.SetEmitSoundSpeed(this.get_f32("gun_soundFirePitch"));
							sprite.SetEmitSoundVolume(this.get_f32("gun_soundFireVolume"));
							sprite.SetEmitSoundPaused(false);
							this.set_bool("gun_soundFireLoopStarted",true);
						}
					}
				}
			}else{
				if(isClient()) {
					if(soundFireLoop){
						if(!sprite.getEmitSoundPaused()){
							sprite.SetEmitSoundPaused(true);
						}
						this.set_bool("gun_soundFireLoopStarted",false);
					}
				}
			
				u32 ammo=CountAmmo(inv,ammoItem);
				if(ammo>0){
					StartReload(this,inv,ammoItem,clip,clipSize);
				}else{
					this.set_bool("gun_needsRelease",true);
					if(isClient() && holder.hasTag("flesh")) 
					{
						sprite.PlaySound("Entities/Characters/Sounds/NoAmmo.ogg",0.6f,1.0);
						if(soundFireLoop){
							if(!sprite.getEmitSoundPaused()){
								sprite.SetEmitSoundPaused(true);
							}
							this.set_bool("gun_soundFireLoopStarted",false);
						}
					}
				}
			}
		}
	}else{
		if(this.get_bool("gun_needsRelease")){
			this.set_bool("gun_needsRelease",false);
		}
		if(isClient()) {
			if(soundFireLoop){
				if(!sprite.getEmitSoundPaused()){
					sprite.SetEmitSoundPaused(true);
				}
				this.set_bool("gun_soundFireLoopStarted",false);
			}
		}
	}
	holder.DisableKeys(key_action1);
}
void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	detached.Untag("noLMB");
	detached.Untag("noShielding");
}
void PlayWeaponSound(CBlob@ this,string sound)
{
	u32 range=	this.get_u32(sound+"Range");
	this.getSprite().PlaySound(this.get_string(sound)+(range>1 ? formatInt(XORRandom(range-1)+1,"")+".ogg" : ".ogg"),this.get_f32(sound+"Volume"),this.get_f32(sound+"Pitch"));
}
void Shoot(CBlob@ this)
{
	AttachmentPoint@ point=	this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) {return;}
	CBlob@ holder=			point.getOccupied();
	
	if(holder is null){
		return;
	}

	f32 damage=	this.get_f32("gun_fireDamage");
	f32 range=	this.get_f32("gun_fireRange");

	if (holder.get_u8("deity_id") == Deity::swaglag)
	{
		CBlob@ altar = getBlobByName("altar_swaglag");
		if (altar !is null)
		{
			damage *= 1.00f + Maths::Min(altar.get_f32("deity_power") * 0.01f, 2.00f);
		}
	}

	string fireProj=this.get_string("gun_fireProj");

	if(fireProj==""){
		//Fire raycast bullet
		Vec2f startPos=	this.getPosition();
		Vec2f hitPos;
		f32 length;
		
		bool flip=this.isFacingLeft();	

		u8 count = this.get_u8("gun_bulletCount");
		f32 baseJitter = this.get_f32("gun_bulletJitter");
		
		for (int i = 0; i < count; i++)
		{
			f32 jitter = ((100 - XORRandom(200)) / 100.0f) * baseJitter;
			f32 angle =	this.getAngleDegrees() + jitter;
			
			Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1),0.0f).RotateBy(angle);
			Vec2f endPos = startPos + dir * range;
		
			// print("Angle: " + angle + "; Jitter: " + jitter);
		
			HitInfo@[] hitInfos;
			bool mapHit=getMap().rayCastSolid(startPos,endPos, hitPos);
			hitPos += dir * 0.01f;
			
			length = (hitPos - startPos).Length();
			
			bool blobHit = getMap().getHitInfosFromRay(startPos, angle + (flip ? 180.0f : 0.0f),length,this,@hitInfos);
			if(isClient())
			{
				DrawLine(this.getSprite(), i, startPos,length / 32, jitter, this.isFacingLeft());
		
				// ParticleAnimated(CFileMatcher("SmallFire").getFirst(), startPos, Vec2f(0, 0), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
				
				ShakeScreen(Maths::Min(damage * count * 12, 150), 8, this.getPosition());	
				
				CPlayer@ ply = holder.getPlayer();
				
				if (ply !is null && ply.isMyPlayer())
				{
					DoRecoil(this, holder);
				}
			}
			
			if(isServer()) 
			{
				const bool force_nonsolid = this.exists("gun_force_nonsolid") && this.get_bool("gun_force_nonsolid");
			
				if(blobHit) 
				{
					f32 falloff=1;
					for(u32 i=0;i<hitInfos.length;i++) 
					{
						if(hitInfos[i].blob !is null)
						{	
							CBlob@ blob=hitInfos[i].blob;
							
							if((blob.isCollidable() || blob.hasTag("flesh") || force_nonsolid) && (!blob.hasTag("invincible") && blob.getTeamNum() != holder.getTeamNum()) && blob.getHealth() > 0.0f) 
							{
								if (!blob.hasTag("isWeapon"))
								{
									f32 dmg = damage*Maths::Max(0.1,falloff)*(blob.hasTag("door") ? 0.2f : 1.0f);
									Vec2f dir = blob.getPosition() - this.getPosition();
									dir.Normalize();
									
									holder.server_Hit(blob, hitInfos[i].hitpos, dir, dmg * 0.99f, this.get_u8("gun_hitter"), false);
									this.server_Hit(blob, hitInfos[i].hitpos, dir, dmg * 0.01f, this.get_u8("gun_hitter"), false); // Hack
									
									// string name = holder.getName();
									// if(name == "soldierchicken" || name == "scoutchicken"){blob.Tag("chickened");}
									
									falloff=falloff * 0.8f;
								}
							}
						}
					}
				}
				
				if(mapHit)
				{
					CMap@ map=		getMap();
					TileType tile=	map.getTile(hitPos).type;
					
					if((map.isTileWood(tile) || damage >= 0.60f) && !map.isTileBedrock(tile))
					{
						map.server_DestroyTile(hitPos, damage * 0.25f);
					}
				}
			}
		}
	}
	else
	{
		//Fire a projectile
		if(isServer()) 
		{
			f32 angle =	this.getAngleDegrees();
			Vec2f dir=		Vec2f((this.isFacingLeft() ? -1 : 1),0.0f).RotateBy(angle);
			Vec2f offset = this.get_Vec2f("gun_projOffset");
			offset.x *= (this.isFacingLeft() ? -1 : 1);
			
			Vec2f startPos=	this.getPosition() + offset.RotateBy(angle);
			
			
			// print("angle" + angle);
			
			// CBlob@ blob = server_CreateBlob(fireProj,holder.getTeamNum(),startPos);
			CBlob@ blob = server_CreateBlobNoInit(fireProj);
			blob.setVelocity(dir * this.get_f32("gun_fireProjSpeed"));
			// blob.setAngleDegrees(angle+90+(this.isFacingLeft() ? 180 : 0));
			blob.SetDamageOwnerPlayer(holder.getPlayer());
			blob.server_setTeamNum(holder.getTeamNum());
			blob.setPosition(startPos);
			blob.Init();
			
			blob.setAngleDegrees(angle + 90 + (this.isFacingLeft() ? 180 : 0));
			
			/*HitInfo@[] hitInfos;
			bool blobHit = getMap().getHitInfosFromRay(startPos, angle + (this.isFacingLeft() ? 0.0f : 180.0f), 20.0f, this, @hitInfos);
			if (blobHit) for (u32 i = 0; i < hitInfos.length; i++){
				this.server_Hit(hitInfos[i].blob, hitInfos[i].hitpos, Vec2f(0, 0), 1.0f, Hitters::fire, true);
			}*/
		}
	}
}

void DoRecoil(CBlob@ this, CBlob@ holder)
{
	// f32 rad2deg = 180.0f / 3.14f;	
	CControls@ controls = getControls();
	Driver@ driver = getDriver();

	const f32 deg2rad = 3.14f / 180.0f;
	const f32 modifier = this.get_f32("gun_fireDamage") ;
	const f32 dampener = ((holder.isKeyPressed(key_down) || this.isKeyPressed(key_down)) ? 0.05f : 1.00f);
	
	// print("" + dampener);
	
	Vec2f dir = (controls.getMouseScreenPos() - driver.getScreenCenterPos());
	f32 len = dir.Length();
	f32 angle = dir.Angle() - ((0.60f * Maths::Clamp(modifier * dampener, 0, 4) * (this.isFacingLeft() ? 1.0f : -1.0f)));

	// print("recoil dampener: " + dampener);
	
	Vec2f recoil = Vec2f(Maths::Cos(angle * deg2rad), -Maths::Sin(angle * deg2rad));
	controls.setMousePosition((driver.getScreenDimensions() / 2.0f) + (recoil * len));
}

u32 CountAmmo(CInventory@ inv,const string ammoType)
{
	u32 quantity=0;
	
	int size=inv.getItemsCount();
	for(int i=0;i<size;i++){
		CBlob@ item=inv.getItem(i);
		if(!(item is null)){
			string itemName=item.getName();
			if(itemName==ammoType){
				quantity+=item.getQuantity();
			}
		}
	}
	return quantity;
}

s32 TakeAmmo(CInventory@ inv,const string ammoType,s32 amount)
{
	s32 taken=	0;
	int size=	inv.getItemsCount();
	for(int i=0;i<size;i++){
		CBlob@ item=inv.getItem(i);
		if(!(item is null)){
			string itemName=item.getName();
			if(itemName==ammoType){
				s32 quantity=item.getQuantity();
				
				bool take = true;
				//Hack
				if (inv.getBlob() != null && inv.getBlob().hasTag("npc")) take = false;
				
				if (take)
				{
					if(quantity+1>(amount-taken)){
						item.server_SetQuantity(quantity-(amount-taken));
					}else{
						item.server_SetQuantity(0);
						item.server_Die();
					}
				}
				
				taken+=Maths::Min(quantity,(amount-taken));
				if(taken>=amount){
					return amount;
				}
			}
		}
	}
	return taken;
}


// s32 TakeAmmo(CInventory@ inv,const string ammoType,s32 amount)
// {
	// s32 taken=	0;
	// int size=	inv.getItemsCount();
	// for(int i=0;i<size;i++){
		// CBlob@ item=inv.getItem(i);
		// if(!(item is null)){
			// string itemName=item.getName();
			// if(itemName==ammoType){
				// s32 quantity=item.getQuantity();
				
				// bool take = true;
				// //Hack
				// if (inv.getBlob() != null && inv.getBlob().hasTag("npc")) take = false;
				
				// if (take)
				// {
					// if(quantity+1>(amount-taken)){
						// item.server_SetQuantity(Maths::Max(1, quantity - amount - taken));
					// }else{
						// item.server_SetQuantity(0);
						// item.server_Die();
					// }
				// }
				
				// taken+=Maths::Min(quantity,(amount-taken));
				// if(taken>=amount){
					// return amount;
				// }
			// }
		// }
	// }
	// return taken;
// }
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(this.hasCommandID("cmd_gunReload") && cmd == this.getCommandID("cmd_gunReload")) {
		AttachmentPoint@ point=	this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point is null){return;}
		CBlob@ holder= 			point.getOccupied();
		if(holder is null) {
			return;
		}
		this.set_bool("gun_reloadKeyPressed",true);
	}
}
CInventory@ GetInventory(CBlob@ this)
{
	AttachmentPoint@ point=this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) return null;
	
	CBlob@ holder=point.getOccupied();
	if(holder is null) return null;
	
	CInventory@ inv=holder.getInventory();
	if(inv is null) return null;
	else return inv;
}
void StartReload(CBlob@ this,CInventory@ inv,string ammoItem,u32 clip,u32 clipSize)
{
	this.set_bool("gun_wasEmpty",clip==0);
	if(!this.get_bool("gun_shotgunReload")){
		//clip-based reload
		if(isClient()) {
			PlayWeaponSound(this,"gun_soundReload");
		}
		this.set_u32("gun_readyTime",getGameTime()+this.get_u32("gun_reloadTime"));
		f32 takenAmmo=TakeAmmo(inv,ammoItem,clipSize-clip);
		this.set_u32("gun_ammoToGive",takenAmmo);
		this.set_bool("gun_doReload",true);
	}else{
		//clipless shotgun-like reload
		f32 takenAmmo=TakeAmmo(inv,ammoItem,this.get_f32("gun_ammoUsage"));
		if(takenAmmo>0) {
			this.set_u32("gun_readyTime",getGameTime()+this.get_u32("gun_reloadTime"));
			this.set_u32("gun_ammoToGive",1);
			this.set_bool("gun_doReload",true);
		}
	}
}


//Visual stuff
void onInit(CSprite@ this)
{
	u8 count = this.getBlob().get_u8("gun_bulletCount");

	for (int i = 0; i < count; i++)
	{
		this.RemoveSpriteLayer("tracer" + i);
		CSpriteLayer@ tracer=this.addSpriteLayer("tracer" + i, (this.getBlob().exists("gun_tracerName") ? this.getBlob().get_string("gun_tracerName") : "GatlingGun_Tracer.png"),32,1,this.getBlob().getTeamNum(),0);
		
		if(tracer !is null)
		{
			Animation@ anim = tracer.addAnimation("default",0,false);
			anim.AddFrame(0);
			tracer.SetRelativeZ(-1.0f);
			tracer.SetVisible(false);
			tracer.setRenderStyle(RenderStyle::additive);
			tracer.SetOffset(this.getBlob().get_Vec2f("gun_lineOffset"));
		}
	}
}
void onTick(CSprite@ this)
{
	CBlob@ self=this.getBlob();
	if((self.get_u32("gun_readyTime") -(self.get_u32("gun_fireDelay") - 1))<getGameTime()) 
	{
		for (int i = 0; i < this.getBlob().get_u8("gun_bulletCount"); i++)
		{
			this.getSpriteLayer("tracer" + i).SetVisible(false);
		}
	}
}
void UpdateAngle(CBlob@ this)
{
	AttachmentPoint@ point=this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) return;
	
	CBlob@ holder=point.getOccupied();
	
	if(holder is null) return;
	
	Vec2f aimpos=holder.getAimPos();
	Vec2f pos=holder.getPosition();
	
	Vec2f aim_vec =(pos - aimpos);
	aim_vec.Normalize();
	
	f32 mouseAngle=aim_vec.getAngleDegrees();
	if(!holder.isFacingLeft()) mouseAngle += 180;

	this.setAngleDegrees(-mouseAngle);
	
	// print("" + this.getAngleDegrees());
	
	// this.SetFacingLeft(holder.isFacingLeft());
	
	point.offset.x=0 +(aim_vec.x*2*(holder.isFacingLeft() ? 1.0f : -1.0f));
	point.offset.y=-(aim_vec.y);
}
void DrawLine(CSprite@ this, u8 index, Vec2f startPos, f32 length, f32 angleOffset, bool flip)
{
	CSpriteLayer@ tracer=this.getSpriteLayer("tracer" + index);
	
	tracer.SetVisible(true);
	
	tracer.ResetTransform();
	tracer.ScaleBy(Vec2f(length,1.0f));
	tracer.TranslateBy(Vec2f(length*16.0f,0.0f));
	tracer.RotateBy(angleOffset + (flip ? 180 : 0),Vec2f());
}