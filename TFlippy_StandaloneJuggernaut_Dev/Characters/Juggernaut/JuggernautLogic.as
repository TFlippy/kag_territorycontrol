// Juggernaut logic

#include "ThrowCommon.as"
#include "JuggernautCommon.as";
#include "KnightCommon.as";
#include "RunnerCommon.as";
#include "HittersTC.as";
#include "ShieldCommon.as";
#include "Help.as";
#include "Knocked.as";
#include "Requirements.as";
#include "SplashWater.as"
#include "ParticleSparks.as";
#include "FireCommon.as";
#include "MakeDustParticle.as";

//attacks limited to the one time per-actor before reset.
void juggernaut_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors",networkIDs);
}

bool juggernaut_has_hit_actor(CBlob@ this,CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors",@networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 juggernaut_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors",@networkIDs);
	return networkIDs.length;
}

void juggernaut_add_actor_limit(CBlob@ this,CBlob@ actor)
{
	this.push("LimitedActors",actor.getNetworkID());
}

void juggernaut_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

void onInit(CBlob@ this)
{
	this.Tag("juggernaut");
	this.Tag("human");
	this.Tag("dangerous");
	this.Tag("heavy weight");
	
	JuggernautInfo juggernaut;

	juggernaut.state=		JuggernautStates::normal;
	juggernaut.prevState=	JuggernautStates::normal;
	juggernaut.actionTimer=	0;
	juggernaut.attackDelay=	0;
	juggernaut.goFatality=	false;
	juggernaut.normalSprite=true;
	juggernaut.tileDestructionLimiter=0;
	juggernaut.dontHitMore=false;

	this.set("JuggernautInfo",@juggernaut);

	this.set_f32("gib health",0.0f);
	this.set_s16(burn_duration,360);
	addShieldVars(this,SHIELD_BLOCK_ANGLE,2.0f,5.0f);
	juggernaut_actorlimit_setup(this);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier=	0.5f;
	this.Tag("player");
	this.Tag("flesh");

	this.set_Vec2f("inventory offset",Vec2f(0.0f,0.0f));

	SetHelp(this,"help self action","juggernaut","$Slash$ Slash!    $KEY_HOLD$$LMB$","",13);
	SetHelp(this,"help self action2","juggernaut","$Shield$Shield    $KEY_HOLD$$RMB$","",13);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	// this.getCurrentScript().removeIfTag=	"dead";
		
	this.addCommandID("grabbedSomeone");
	this.addCommandID("throw");
	this.addCommandID("goFatality");
	this.addCommandID("goFatalityReal");
		
	this.set_string("grabbedEnemy","knight");
	
	Random@ rand = Random(this.getNetworkID());
	
	CSprite@ sprite = this.getSprite();
	sprite.RewindEmitSound();
	sprite.SetEmitSound("Juggernaut_Music_" + rand.NextRanged(3));
	sprite.SetEmitSoundSpeed(1);
	sprite.SetEmitSoundVolume(2);
	sprite.SetEmitSoundPaused(false);
	
	// int playerCount=getPlayerCount();
	// int heroCount=	0;
	// int juggCount=	0;
	// for(int i=0;i<playerCount;i++) {
		// CPlayer@ player=	getPlayer(i);
		// if(player.getTeamNum()==0) {
			// heroCount++;
		// }else if(player.getTeamNum()==1) { //new players are usually moved to red team so bugs may happen.. but this is happening at the start at the round so that'll be really uncommon
			// juggCount++;
		// }
	// }
	// printFloat("juggcount ",f32(juggCount));
	
	// float scalePerPlayer=	1.0f/Lerp(8.0f,6.0f,f32(heroCount)/15.0f); //0.166
	// float healthScale=	Maths::Min(1.0,(scalePerPlayer*Maths::Max(1.0f,f32(heroCount-(juggCount-1))))/Maths::Max(1.0f,f32(juggCount)))-((juggCount-1)*(scalePerPlayer/2.0f));
	// this.set_f32("healthScale",healthScale);
	// this.set_f32("realInitialHealth",this.getInitialHealth()*healthScale);
	// this.server_SetHealth(this.getInitialHealth()*healthScale);
}


f32 Lerp(f32 a,f32 b,f32 time)
{
	return a+(b-a)*Maths::Min(1.0,Maths::Max(0.0,time));
}

void onSetPlayer(CBlob@ this,CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png",3,Vec2f(16,16));
	}
}


void onTick(CBlob@ this)
{
	// print("tick");

	RunnerMoveVars@ moveVars;
	if(!this.get("moveVars",@moveVars)) {
		return;
	}
	JuggernautInfo@ juggernaut;
	if(!this.get("JuggernautInfo",@juggernaut)) {
		return;
	}
	juggernaut.prevState=	juggernaut.state;
	
	Vec2f vec;
	Vec2f aimPos=		this.getAimPos();
	const int direction=this.getAimDirection(vec);
	const f32 side=		(this.isFacingLeft() ? 1.0f : -1.0f);
	
	Vec2f pos=			this.getPosition();
	Vec2f vel=			this.getVelocity();
	bool isInAir=		(!this.isOnGround() && !this.isOnLadder());
	const bool isMyPlayer=	this.isMyPlayer();
	
	bool pressed_lmb=	this.isKeyPressed(key_action1) && !this.hasTag("noLMB");
	bool pressed_rmb=	this.isKeyPressed(key_action2) && !this.hasTag("noLMB");
	
	float attackJumpFactor=	0.375f;
	float attackWalkFactor=	0.4f;
	bool extraSync=	false;
	
	if(isMyPlayer) {
		getHUD().SetCursorFrame(0);
	}
	
	if(juggernaut.state==JuggernautStates::stun)
	{
		moveVars.jumpFactor=		0.0f;
		moveVars.walkFactor=		0.0f;
		juggernaut.actionTimer=		0;
		juggernaut.actionTimer=		0;
		juggernaut.goFatality=		false;
		juggernaut.forceFatality=	false;
		juggernaut.dontHitMore=		false;
		juggernaut.stun--;
		if(juggernaut.stun<=0){
			juggernaut.state=JuggernautStates::normal;
		}
	}
	else if(juggernaut.state==JuggernautStates::normal)
	{
		//Normal
		if(juggernaut.attackDelay>0){
			juggernaut.attackDelay--;
		}else if(pressed_lmb){
			juggernaut.state=			JuggernautStates::charging;
			juggernaut.actionTimer=		0;
			juggernaut.goFatality=		false;
			juggernaut.forceFatality=	false;
			juggernaut.dontHitMore=		false;
		}
		if(pressed_rmb){
			f32 angle=	   -((this.getAimPos()-pos).getAngleDegrees());
			if(angle<0.0f)	{angle+=360.0f;}
			Vec2f dir=		Vec2f(1.0f,0.0f).RotateBy(angle);
			juggernaut.attackDirection=	dir;
			juggernaut.attackAimPos=	this.getAimPos();
			juggernaut.attackRot=		angle;
			angle=			(this.getAimPos()-pos).Angle();
			juggernaut.attackTrueRot=	angle;
			
			juggernaut.wasFacingLeft=	this.isFacingLeft();
			juggernaut.state=			JuggernautStates::grabbing;
			juggernaut.actionTimer=		0;
			juggernaut.goFatality=		false;
			juggernaut.forceFatality=	false;
			juggernaut.dontHitMore=		false;
			
			if(isClient()){
				Sound::Play("/ArgLong",this.getPosition());
			}
		}
	}
	else if(juggernaut.state==JuggernautStates::charging)
	{
		//Charging hammer attack
		moveVars.jumpFactor*=	attackJumpFactor;
		moveVars.walkFactor*=	attackWalkFactor;
		juggernaut.actionTimer+=1;
		
		f32 angle=	   -((this.getAimPos()-pos).getAngleDegrees());
		if(angle<0.0f)	{angle+=360.0f;}
		Vec2f dir=		Vec2f(1.0f,0.0f).RotateBy(angle);
		juggernaut.attackDirection=	dir;
		juggernaut.attackAimPos=	this.getAimPos();
		juggernaut.attackRot=		angle;
		angle=						(this.getAimPos()-pos).Angle();
		juggernaut.attackTrueRot=	angle;
		
		juggernaut.wasFacingLeft=	this.isFacingLeft();
		
		if(juggernaut.actionTimer>=JuggernautVars::chargeTime){
			juggernaut.state=			JuggernautStates::chargedAttack;
			juggernaut.actionTimer=		0;
			juggernaut.goFatality=		false;
			juggernaut.forceFatality=	false;
			juggernaut.dontHitMore=		false;
			
			if(isClient()){
				Sound::Play("/ArgLong",this.getPosition());
				PlaySoundRanged(this,"SwingHeavy",4,1.0f,1.0f);
			}
			Vec2f force=juggernaut.attackDirection*this.getMass()*3.0f;
			this.AddForce(force);
		}
	}
	else if(juggernaut.state==JuggernautStates::chargedAttack)
	{
		//Attacking with the hammer
		moveVars.jumpFactor*=	attackJumpFactor;
		moveVars.walkFactor*=	attackWalkFactor;
		this.SetFacingLeft(juggernaut.wasFacingLeft);
		
		if(juggernaut.actionTimer>=JuggernautVars::attackTime){
			juggernaut.state=			JuggernautStates::normal;
			juggernaut.actionTimer=		0;
			juggernaut.goFatality=		false;
			juggernaut.forceFatality=	false;
			juggernaut.dontHitMore=		false;
			juggernaut.attackDelay=JuggernautVars::attackDelay;
		}else{
			if(juggernaut.actionTimer<12){
				DoAttack(this,8.0f,juggernaut,120.0f,HittersTC::hammer,juggernaut.actionTimer);
			}
		}
		juggernaut.actionTimer+=1;
	}
	else if(juggernaut.state==JuggernautStates::grabbing)
	{
		//Trying to grab a stunned enemy
		moveVars.jumpFactor*=	attackJumpFactor;
		moveVars.walkFactor*=	attackWalkFactor;
		this.SetFacingLeft(juggernaut.wasFacingLeft);
		
		if(juggernaut.actionTimer>=JuggernautVars::grabTime){
			juggernaut.state=			JuggernautStates::normal;
			juggernaut.actionTimer=		0;
			juggernaut.goFatality=		false;
			juggernaut.forceFatality=	false;
			juggernaut.dontHitMore=		false;
			juggernaut.attackDelay=		JuggernautVars::attackDelay*2;
		}else{
			if(isServer() && juggernaut.actionTimer<=(JuggernautVars::grabTime/4)*3 && juggernaut.dontHitMore==false){
				//Grab
				const float range=	26.0f; //36.0f originally
				f32 angle=	juggernaut.attackRot;
				Vec2f dir=	juggernaut.attackDirection;
				
				Vec2f startPos=	this.getPosition()+Vec2f(0.0f,5.0f);
				Vec2f endPos=	startPos+(dir*range);
			
				HitInfo@[] hitInfos;
				Vec2f hitPos;
				bool mapHit=getMap().rayCastSolid(startPos,endPos,hitPos);
				f32 length=	(hitPos-startPos).Length();
				
				bool blobHit=	getMap().getHitInfosFromRay(startPos,angle,length,this,@hitInfos);
				
				if(blobHit) {
					for(u32 i=0;i<hitInfos.length;i++) {
						if(hitInfos[i].blob !is null) {	
							CBlob@ blob=	hitInfos[i].blob;
							if(blob.hasTag("player") && blob.getTeamNum()!=this.getTeamNum() && !blob.hasTag("dead")) {
								if(blob.getName()=="knight"){
									if(blockAttack(blob,dir,0.0f)){
										Sound::Play("Entities/Characters/Knight/ShieldHit.ogg",pos);
										sparks(pos,-dir.Angle(),Maths::Max(10.0f*0.05f,1.0f));
										juggernaut.dontHitMore=true;
										break;
									}else{
										KnightInfo@ knight;
										if(this.get("KnightInfo",@knight)) {
											if(inMiddleOfAttack(knight.state)){
												juggernaut.dontHitMore=true;
												break;
											}
										}
									}
								}
								if(blob.getHealth()<=1.0f || IsKnocked(blob) || blob.getName()=="archer" || blob.getName()=="trader"){
									CPlayer@ player=blob.getPlayer();
									if(player !is null){
										CBlob@ newBlob=	server_CreateBlob("playercontainer",0,this.getPosition());
										if(newBlob !is null){
											newBlob.server_SetPlayer(player);
											AttachmentPoint@ point=	this.getAttachments().getAttachmentPointByName("PICKUP");
											if(point !is null)
											{
												this.server_AttachTo(newBlob,point);
												newBlob.server_setTeamNum(blob.getTeamNum());
												player.server_setTeamNum(blob.getTeamNum());	
											}
										}
									}
									blob.server_Die();
									
									CBitStream stream;
										stream.write_string(blob.getName());
									this.SendCommand(this.getCommandID("grabbedSomeone"),stream);
									juggernaut.state=JuggernautStates::grabbed;
								}else{
									this.server_Hit(blob,this.getPosition(),dir,1.0f,Hitters::flying,false);
								}
								juggernaut.dontHitMore=true;
								break;
							}
						}
					}
				}
				juggernaut.goFatality=		false;
				juggernaut.forceFatality=	false;
			}
		}
		juggernaut.actionTimer+=1;
	}else if(juggernaut.state==JuggernautStates::grabbed) {
		//Holding someone by the neck
		if(juggernaut.attackDelay>0){
			juggernaut.attackDelay--;
		}else if(pressed_lmb && !juggernaut.goFatality && !juggernaut.forceFatality){
			f32 angle=					(this.getAimPos()-pos).Angle();
			juggernaut.attackTrueRot=	angle;
			
			juggernaut.state=		JuggernautStates::throwing;
			juggernaut.actionTimer=	0;
			juggernaut.dontHitMore=	false;
			if(isClient()){
				Sound::Play("/ArgLong",this.getPosition());
			}
			if(isServer()){
				f32 angle=	-((this.getAimPos()-pos).getAngleDegrees());
				if(angle<0.0f){
					angle+=360.0f;
				}
				string config =	this.get_string("grabbedEnemy");
				Vec2f dir=Vec2f(1.0f,0.0f).RotateBy(angle);
				CBlob@ blob;
				switch(stringToInt(config))
				{
					case -1232701324:
					{
						@blob = server_CreateBlob("corpseknight",this.getTeamNum(),pos);
					}
					break;

					case -1772739846:
					{
						@blob = server_CreateBlob("corpsearcher",this.getTeamNum(),pos);
					}
					break;

					case 1475757562:
					{
						@blob = server_CreateBlob("corpsetrader",this.getTeamNum(),pos);
					}
					break;

					case 729018236:
					{
						@blob = server_CreateBlob("corpsehazmat",this.getTeamNum(),pos);
					}
					break;

					case -2083399780:
					{
						@blob = server_CreateBlob("corpsebandit",this.getTeamNum(),pos);
					}
					break;

					case 1217761244:
					{
						@blob = server_CreateBlob("corpseexo",this.getTeamNum(),pos);
					}
					break;

					case -1785136247:
					{
						@blob = server_CreateBlob("corpsninja",this.getTeamNum(),pos);
					}
					break;

					case -728220:
					{
						@blob = server_CreateBlob("corpsepeasent",this.getTeamNum(),pos);		
					}
					break;

					case -1203370764:
					{
						@blob = server_CreateBlob("corpseroyalguard",this.getTeamNum(),pos);	
					}
					break;

					case 384764821:
					{
						@blob = server_CreateBlob("corpseslave",this.getTeamNum(),pos); //todo		
					}
					break;


					default:
					{
						@blob = server_CreateBlob("corpseknight",this.getTeamNum(),pos);
					}
					break;
				}
				
				
				AttachmentPoint@ point=	this.getAttachments().getAttachmentPointByName("PICKUP");
				if(point !is null)
				{
					CBlob@ attachedBlob=	point.getOccupied();
					if(attachedBlob !is null){
						CPlayer@ attachedPlayer=	attachedBlob.getPlayer();
						if(attachedPlayer !is null){
							blob.server_SetPlayer(attachedPlayer);
						}
						attachedBlob.server_Die();
					}
				}
				if(blob !is null){
					blob.setVelocity(dir*12.0f);
					if(this.getPlayer() !is null){
						blob.SetDamageOwnerPlayer(this.getPlayer());
					}
				}
				extraSync=	true;
				//this.SendCommand(this.getCommandID("throw"));
			}
		}else if(pressed_rmb && this.isKeyJustPressed(key_action2) && !juggernaut.goFatality && this.get_string("grabbedEnemy")!="trader"){
			/*if(isClient() && isMyPlayer){
				CBitStream stream;
				this.SendCommandOnlyServer(this.getCommandID("goFatality"),stream);
			}*/
			juggernaut.goFatality=true;
		}
		if(juggernaut.goFatality || juggernaut.forceFatality){
			juggernaut.state=			JuggernautStates::fatality;
			juggernaut.actionTimer=		0;
			juggernaut.goFatality=		false;
			juggernaut.forceFatality=	false;
			juggernaut.wasFacingLeft=	this.isFacingLeft();
			if(isServer()) {
				this.SendCommand(this.getCommandID("goFatalityReal"));
			}
		}
	}
	else if(juggernaut.state==JuggernautStates::throwing)
	{
		if(juggernaut.actionTimer>=JuggernautVars::throwTime){
			juggernaut.state=			JuggernautStates::normal;
			juggernaut.actionTimer=		0;
			juggernaut.dontHitMore=		false;
			juggernaut.goFatality=		false;
			juggernaut.forceFatality=	false;
			juggernaut.attackDelay=		JuggernautVars::attackDelay;
		}
		juggernaut.actionTimer+=1;
	}
	else if(juggernaut.state==JuggernautStates::fatality)
	{
		moveVars.jumpFactor=	0.0f;
		moveVars.walkFactor=	0.0f;
		this.getShape().SetVelocity(Vec2f());
		if(!this.hasTag("invincible")){
			this.Tag("invincible");
		}
		this.SetFacingLeft(juggernaut.wasFacingLeft);
		if(juggernaut.actionTimer==46){ //62
			// this.server_SetHealth(Maths::Min(this.getHealth()+3.75f,this.get_f32("realInitialHealth")));
			
			if(isServer()){
				AttachmentPoint@ point=	this.getAttachments().getAttachmentPointByName("PICKUP");
				if(point !is null){
					CBlob@ attachedBlob=	point.getOccupied();
					if(attachedBlob !is null){
						CPlayer@ attachedPlayer=attachedBlob.getPlayer();
						if(attachedPlayer !is null){
							CPlayer@ player=this.getPlayer();
							if(player !is null){
								getRules().server_PlayerDie(attachedPlayer,player,Hitters::stomp);
							}else{
								attachedBlob.server_Die();
							}
						}else{
							attachedBlob.server_Die();
						}
					}
				}
			}
		}
		if(isClient()) {
			if(juggernaut.actionTimer==3){ //4
				Sound::Play("ArgShort.ogg",pos,1.0f);
			}else if(juggernaut.actionTimer==20){ //27
				Sound::Play("ArgLong.ogg",pos,1.0f);
			}else if(juggernaut.actionTimer==29){ //39
				ShakeScreen(6.0f,5,this.getPosition());
				Sound::Play("FallOnGround.ogg",pos,0.4f);
			}else if(juggernaut.actionTimer==45){ //60
				ShakeScreen(25.0f,6,this.getPosition());
			}else if(juggernaut.actionTimer==46){ //62
				Vec2f posOffset=pos+Vec2f(this.isFacingLeft() ? -8 : 8,3);
				ParticleBloodSplat(posOffset,true);
				for(int i=0;i<12;i++) {
					Vec2f vel=getRandomVelocity(float(XORRandom(360)),1.0f+float(XORRandom(2)),60.0f);
					makeGibParticle("mini_gibs.png",posOffset,vel,0,4+XORRandom(4),Vec2f(8,8),2.0f,20,"/BodyGibFall",0);
				}
			}else if(juggernaut.actionTimer==48){	 //64
				Sound::Play("Gore.ogg",pos,1.0f);
				Vec2f offset=Vec2f(0,0);
			}
		}
		if(juggernaut.actionTimer>=JuggernautVars::fatalityTime){
			juggernaut.state=			JuggernautStates::normal;
			juggernaut.actionTimer=		0;
			juggernaut.goFatality=		false;
			juggernaut.forceFatality=	false;
			this.Untag("invincible");
			if(isServer()){
				CBlob@ blob=	server_CreateBlob(this.get_string("grabbedEnemy")=="archer" ? "corpsestillarcher" : "corpsestill",0,this.getPosition());
				blob.getSprite().SetFacingLeft(this.isFacingLeft());
			}
		}
		juggernaut.actionTimer+=1;
	}

	if(juggernaut.state!=JuggernautStates::charging && juggernaut.state!=JuggernautStates::chargedAttack && isServer()) {
		juggernaut_clear_actor_limits(this);
	}
	if(extraSync) {
		this.Sync("extraSync",false);
	}
}
bool IsKnocked(CBlob@ blob)
{
	if(!blob.exists("knocked")){
		return false;
	}
	return getKnocked(blob) > 0;
}
/*void DrawLine(CSprite@ this, u8 index, Vec2f startPos, f32 length, f32 angleOffset, bool flip)
{
	CSpriteLayer@ tracer=this.getSpriteLayer("tracer");
	
	tracer.SetVisible(true);
	
	tracer.ResetTransform();
	tracer.ScaleBy(Vec2f(length,1.0f));
	tracer.TranslateBy(Vec2f(length*16.0f,0.0f));
	tracer.RotateBy(angleOffset + (flip ? 180 : 0),Vec2f());
}*/
void PlaySoundRanged(CBlob@ this,string sound,int range,float volume,float pitch)
{
	this.getSprite().PlaySound(sound+(range>1 ? formatInt(XORRandom(range-1)+1,"")+".ogg" : ".ogg"),volume,pitch);
}
void onCommand(CBlob@ this,u8 cmd,CBitStream @stream)
{
	JuggernautInfo@ juggernaut;
	if(!this.get("JuggernautInfo",@juggernaut)) {
		return;
	}
	if(cmd==this.getCommandID("throw")){
		if(isServer() || juggernaut.state==JuggernautStates::throwing){
			return;
		}
		juggernaut.state=		JuggernautStates::throwing;
		juggernaut.actionTimer=	0;
		juggernaut.dontHitMore=	false;
	}else if(cmd==this.getCommandID("goFatality")){
		juggernaut.goFatality=true;
	}else if(cmd==this.getCommandID("goFatalityReal")){
		juggernaut.forceFatality=true;
	}else if(cmd==this.getCommandID("grabbedSomeone")){
		this.set_string("grabbedEnemy",stream.read_string());
		juggernaut.state=JuggernautStates::grabbed;
		juggernaut.attackDelay=15;
		juggernaut.forceFatality=false;
		juggernaut.goFatality=false;
		if(isClient()){
			
			CSpriteLayer@ victim=this.getSprite().getSpriteLayer("victim");
			if(victim !is null){
				if(this.get_string("grabbedEnemy")=="archer"){
					victim.ReloadSprite("ArcherVictim.png",64,64,0,0);
					this.getSprite().PlaySound("Agh.ogg");
				}else if(this.get_string("grabbedEnemy")=="trader"){
					victim.ReloadSprite("TraderVictim.png",64,64,0,0);
					this.getSprite().PlaySound("trader_scream_" + XORRandom(3));
				}else{
					victim.ReloadSprite("KnightVictim.png",64,64,0,0);
					this.getSprite().PlaySound("Agh.ogg");
				}
			}
		}
	}
}


f32 onHit(CBlob@ this,Vec2f worldPoint,Vec2f velocity,f32 damage,CBlob@ hitterBlob,u8 customData)
{
	if(this.hasTag("invincible")){
		return 0.0f;
	}
	//if(customData==Hitters::arrow) {
	//	return damage*1.5f;
	//}
	return damage;
}

void onDie(CBlob@ this)
{
	// print("onDie");

	if (isClient())
	{
		this.getSprite().PlaySound("Juggernaut_Death.ogg", 1.00f, this.getSexNum() == 0 ? 1.0f : 2.0f);
	}
	
	if (isServer())
	{
		server_CreateBlob("juggernauthammer", this.getTeamNum(), this.getPosition());
	}
	
	// if (isServer())
	// {
		// server_CreateBlob("royalarmor", this.getTeamNum(), this.getPosition());
	
		// CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		// boom.setPosition(this.getPosition());
		// boom.set_u8("boom_start", 0);
		// boom.set_u8("boom_end", 4);
		// // boom.set_f32("mithril_amount", 5);
		// boom.set_f32("flash_distance", 64);
		// boom.Tag("no mithril");
		// boom.Tag("no fallout");
		// // boom.Tag("no flash");
		// boom.Init();
	// }

	if(!isServer())
	{
		return;
	}
	JuggernautInfo@ juggernaut;
	if(!this.get("JuggernautInfo",@juggernaut)) {
		return;
	}
	if(juggernaut.state==JuggernautStates::grabbed){
		CBlob@ blob= server_CreateBlob(this.get_string("grabbedEnemy"),this.getTeamNum(),this.getPosition());
		if(blob !is null){
			AttachmentPoint@ point=	this.getAttachments().getAttachmentPointByName("PICKUP");
			if(point !is null){
				CBlob@ attachedBlob=	point.getOccupied();
				if(attachedBlob !is null){
					CPlayer@ attachedPlayer=attachedBlob.getPlayer();
					if(attachedPlayer !is null){
						blob.server_SetPlayer(attachedPlayer);
						
						CBitStream params;
						params.write_u16(2);
						params.write_string(attachedPlayer.getUsername()+" was saved by the heroes!");
						params.write_string("Good fuckin' job! Don't forget to attach a screenshot of this to your wall.");
						getRules().SendCommand(getRules().getCommandID("broadcastMessage"),params);
					}else{
						CBitStream params;
						params.write_u16(2);
						params.write_string(this.get_string("grabbedEnemy")+" was saved by the heroes!");
						params.write_string("Good fuckin' job! Don't forget to attach a screenshot of this to your wall.");
						getRules().SendCommand(getRules().getCommandID("broadcastMessage"),params);
					}
				}
			}
		}
	}
}

/////////////////////////////////////////////////

void DoAttack(CBlob@ this,f32 damage,JuggernautInfo@ info,f32 arcDegrees,u8 type,int deltaInt)
{
	f32 aimangle=-(info.attackDirection.Angle());
	if(aimangle<0.0f) {
		aimangle+=360.0f;
	}
	f32 exact_aimangle=	info.attackTrueRot;
	Vec2f aimPos=		info.attackAimPos;
	//get the actual aim angle

	Vec2f blobPos=	this.getPosition();
	Vec2f vel=	this.getVelocity();
	Vec2f thinghy(1,0);
	thinghy.RotateBy(aimangle);
	Vec2f pos=	blobPos - thinghy * 6.0f + vel + Vec2f(0,-2);
	vel.Normalize();

	f32 attack_distance=	Maths::Min(DEFAULT_ATTACK_DISTANCE + Maths::Max(0.0f,1.75f * this.getShape().vellen *(vel * thinghy)),MAX_ATTACK_DISTANCE);

	f32 radius=	this.getRadius();
	CMap@ map=	this.getMap();
	bool dontHitMore=	false;
	bool dontHitMoreMap=false;
	bool hasHitBlob=	false;
	bool hasHitMap=		false;
	
	bool client = isClient();
	bool server = isServer();
	
	if(isServer() && (blobPos-aimPos).Length()<=attack_distance*1.5f){
		DamageWall(this,map,aimPos);
	}

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if(map.getHitInfosFromArc(pos,aimangle,arcDegrees,radius + attack_distance,this,@hitInfos))
	{
		//HitInfo objects are sorted,first come closest hits
		for(uint i=	0; i < hitInfos.length; i++) {
			HitInfo@ hi=hitInfos[i];
			CBlob@ b=	hi.blob;

			if(b !is null && !dontHitMore && deltaInt<=JuggernautVars::attackTime-9) // blob
			{
				//big things block attacks
				const bool large=	b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();

				if(!canHit(this,b)) {
					// no TK
					if(large){
						dontHitMore=	true;
					}
					continue;
				}

				if(juggernaut_has_hit_actor(this,b))
				{
					if(large){
						dontHitMore=	true;
					}
					continue;
				}

				juggernaut_add_actor_limit(this,b);
				if(!dontHitMore)
				{
					if(isServer()) {
						Vec2f velocity=	b.getPosition() - pos;
						this.server_Hit(b,hi.hitpos,velocity,damage,type,true);  // server_Hit() is server-side only
					}

					// end hitting if we hit something solid,don't if its flesh
					if(large)
					{
						dontHitMore=	true;
					}
				}
				hasHitBlob=	true;
			}else if(!dontHitMoreMap &&(deltaInt == DELTA_BEGIN_ATTACK + 1)) { // hitmap
				Vec2f tpos=	map.getTileWorldPosition(hi.tileOffset) + Vec2f(4,4);
				Vec2f offset=	(tpos - blobPos);
				f32 tileangle=	offset.Angle();
				f32 dif=	Maths::Abs(exact_aimangle - tileangle);
				if(dif > 180){
					dif -= 360;
				}
				if(dif < -180){
					dif += 360;
				}

				dif=	Maths::Abs(dif);
				//print("dif: "+dif);

				if(dif < 30.0f) {
					hasHitMap=	true;
					
					
					if(!isServer()) {
						MakeDustParticle(tpos, "dust2.png");
						continue;
					}
					if(map.getSectorAtPosition(tpos,"no build") !is null){
						continue;
					}
					TileType tile=map.getTile(hi.hitpos).type;
					if(!map.isTileBedrock(tile)){
						map.server_DestroyTile(hi.hitpos,1000.0f,this);
					}
					
					for (int i = 0; i < 5; i++)
					{
						Vec2f pos = hi.hitpos + getRandomVelocity(0, 24, 360);	

						if (client && XORRandom(100) < 50)
						{
							MakeDustParticle(pos, "dust2.png");
						}
						
						if (server)
						{
							getMap().server_DestroyTile(pos, 0.005f);
						}
					}
					
					// DamageWall(this,map,hi.hitpos+Vec2f(-8, 0));
					// DamageWall(this,map,hi.hitpos+Vec2f( 8, 0));
					// DamageWall(this,map,hi.hitpos+Vec2f( 0,-8));
					// DamageWall(this,map,hi.hitpos+Vec2f( 0, 8));
					
					
					//this.server_HitMap(hi.hitpos,offset,1.0f,Hitters::builder);
				}
			}
		}
		if (hasHitBlob || hasHitMap) 
		{
			ShakeScreen(48.0f, 15.0f, this.getPosition());
			this.getSprite().PlaySound("FallBig" + (1 + XORRandom(5)), 1.00f, 1.00f);
		
			if(!hasHitBlob) 
			{
				PlaySoundRanged(this,"HammerHit",3,1.0f,1.0f);
			}
		}
	}

	// destroy grass

	if(((aimangle >= 0.0f && aimangle <= 180.0f) || damage > 1.0f) &&    // aiming down or slash
	(deltaInt == DELTA_BEGIN_ATTACK + 1)) // hit only once
	{
		f32 tilesize=	map.tilesize;
		int steps=	Maths::Ceil(2 * radius / tilesize);
		int sign=	this.isFacingLeft() ? -1 : 1;

		for(int y=	0; y < steps; y++)
			for(int x=	0; x < steps; x++)
			{
				Vec2f tilepos=	blobPos + Vec2f(x * tilesize * sign,y * tilesize);
				TileType tile=	map.getTile(tilepos).type;

				if(map.isTileGrass(tile))
				{
					map.server_DestroyTile(tilepos,damage,this);

					if(damage <= 1.0f)
					{
						return;
					}
				}
			}
	}
}
void DamageWall(CBlob@ this,CMap@ map,Vec2f pos)
{
	if(pos.x<0.0f || pos.x>=map.tilemapwidth*8.0f || pos.y<0.0f || pos.y>=map.tilemapheight*8.0f){
		print("returned from "+pos.x+","+pos.y);
		return;
	}
	Tile tile=map.getTile(pos);
	if(map.isTileBackground(tile) && !map.isTileGroundBack(tile.type)){
		tile.type=CMap::TileEnum::tile_empty;
		map.server_SetTile(pos,tile);
		//map.server_DestroyTile(pos,1000.0f,this);
	}
}
void DoGrab(CBlob@ this,f32 aimangle,f32 arcDegrees,JuggernautInfo@ info)
{
	if(!isServer()) {
		return;
	}
	if(aimangle<0.0f) {
		aimangle+=360.0f;
	}
	Vec2f blobPos=	this.getPosition();
	Vec2f vel=		this.getVelocity();
	Vec2f thinghy(1,0);
	thinghy.RotateBy(aimangle);
	Vec2f pos=	blobPos-thinghy*6.0f+vel+Vec2f(0,-2);
	vel.Normalize();

	f32 attack_distance=Maths::Min(DEFAULT_ATTACK_DISTANCE+Maths::Max(0.0f,1.75f*this.getShape().vellen*(vel*thinghy)),MAX_ATTACK_DISTANCE);

	f32 radius=			this.getRadius();
	CMap@ map=			this.getMap();

	f32 exact_aimangle=	(this.getAimPos()-blobPos).Angle(); //get the actual aim angle

	HitInfo@[] hitInfos; // this gathers HitInfo objects which contain blob or tile hit information
	if(map.getHitInfosFromArc(pos,aimangle,arcDegrees,radius+attack_distance,this,@hitInfos))
	{
		for(uint i=0;i<hitInfos.length;i++) { //HitInfo objects are sorted,first come closest hits
			HitInfo@ hi=	hitInfos[i];
			CBlob@ b=	hi.blob;
			if(b !is null) { //blob 
				if(b.getName()!="knight" || b.hasTag("ignore sword") || !canHit(this,b) || juggernaut_has_hit_actor(this,b)){
					continue;
				}
				juggernaut_add_actor_limit(this,b);
				Vec2f velocity=	b.getPosition()-pos;
				//this.server_Hit(b,hi.hitpos,velocity,damage,type,true);  // server_Hit() is server-side only
				CBitStream stream;
				stream.write_u16(b.getNetworkID()); //victim's blob id
				stream.write_u8(0); //fatality id
				stream.write_bool(this.isFacingLeft());
				//stream.write_f32(100.0f); fatality length
				uint8 commandId=this.getCommandID("fatality");
				/*int playerCount=getPlayerCount();
				for(uint j=0;j<playerCount;j++){
					CPlayer@ player=getPlayer(j);
					this.server_SendCommandToPlayer(commandId,stream,player);
				}*/
				this.SendCommand(commandId,stream);
				//b.Damage(b.getInitialHealth()*2,this);
				this.server_Hit(b,hi.hitpos,velocity,b.getInitialHealth()*2,Hitters::suicide,false);
				break;
			}
		}
	}
}

//a little push forward

void pushForward(CBlob@ this,f32 normalForce,f32 pushingForce,f32 verticalForce)
{
	f32 facing_sign=	this.isFacingLeft() ? -1.0f : 1.0f ;
	bool pushing_in_facing_direction =
	(facing_sign < 0.0f && this.isKeyPressed(key_left)) ||
	(facing_sign > 0.0f && this.isKeyPressed(key_right));
	f32 force=	normalForce;

	if(pushing_in_facing_direction)
	{
		force=	pushingForce;
	}

	this.AddForce(Vec2f(force * facing_sign ,verticalForce));
}

// Blame Fuzzle.
bool canHit(CBlob@ this,CBlob@ b)
{
	if(b.hasTag("invincible")){
		return false;
	}

	// Don't hit temp blobs and items carried by teammates.
	if(b.isAttached())
	{
		CBlob@ carrier=	b.getCarriedBlob();

		if(carrier !is null){
			if(carrier.hasTag("player") && (this.getTeamNum()==carrier.getTeamNum() || b.hasTag("temp blob"))) {
				return false;
			}
		}
	}

	if(b.hasTag("dead"))
		return true;

	return b.getTeamNum() != this.getTeamNum();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	f32 vellen = this.getOldVelocity().Length();
	bool client = isClient();
	bool server = isServer();
	
	if (solid && vellen > 5.00f)
	{
		int count = vellen * 2.00f;
		for (int i = 0; i < count; i++)
		{
			Vec2f pos = point1 + getRandomVelocity(-normal.Angle(), 2.00f * i, Maths::Min(15 * i, 80));	

			if (client && XORRandom(100) < 50)
			{
				MakeDustParticle(pos, "dust2.png");
			}
			
			if (server)
			{
				getMap().server_DestroyTile(pos, 0.005f * vellen);
			}
		}
		
		if (client)
		{
			this.getSprite().PlaySound("FallBig" + (XORRandom(5) + 1), vellen / 8.0f + 0.2f, 1.1f - vellen / 45.0f);
			ShakeScreen(vellen * 15.0f, vellen * 4.0f, this.getPosition());
		}
	}
}



int stringToInt(string inputString)
{
	string temp = "";
	for(int a = 0; a < inputString.size(); a++)
	{
		temp += inputString[a];
	}
	return parseInt(temp);
}