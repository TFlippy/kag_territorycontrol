//////////////////////////////////////////////////////
//
//  Bullet.as - Vamist
//
//  Handles bullet activities
//

#include "BulletModule.as";
#include "CustomBlocks.as";

class Bullet
{
    CBlob@ hoomanShooter;
    CBlob@ gunBlob;
	BulletFade@ Fade;

	string Texture = "";

    // Pointer to BulletModules
    BulletModule@[] modules;

    Vec2f CurrentVelocity;
    Vec2f LastLerpedPos;
    Vec2f CurrentPos;
    Vec2f BulletGrav;
    Vec2f OldPos;
    Vec2f Gravity;
	s8 Hits;
    bool FacingLeft;

    f32 StartingAimAngle;
    f32 Angle;

    u8 Speed;
    s8 TimeLeft;

    Bullet(CBlob@ humanBlob, CBlob@ gun, f32 angle, Vec2f pos, BulletModule@[] pointer)
    {
        @hoomanShooter = humanBlob;
        @gunBlob = gun;
        modules = pointer;

		Hits = 1;
		if(gunBlob.exists("CustomPierce"))Hits = gunBlob.get_u8("CustomPierce");

        GunSettings@ settings;
        gun.get("gun_settings", @settings);
		
		if(gunBlob.exists("CustomFade") && !v_fastrender){
			string fadeTexture = gunBlob.get_string("CustomFade");
			if(!fadeTexture.empty()){ //No point even giving ourselves a fade if it doesn't have a texture
				@Fade = BulletFade(pos);
				Fade.Texture = fadeTexture;
				BulletGrouped.addFade(Fade);
			}
		}
		
		Texture = gunBlob.get_string("CustomBullet");

		TimeLeft = settings.B_TTL*0.9f;

        StartingAimAngle = angle;
        CurrentPos = pos;

		Speed = settings.B_SPEED;
        BulletGrav = settings.B_GRAV;
        FacingLeft = gun.isFacingLeft();

        OldPos = CurrentPos;
        LastLerpedPos = CurrentPos;

        for (int a = 0; a < modules.length(); a++)
        {
            modules[a].onModuleInit(this);
        }
    }

    bool onTick(CMap@ map)
    {
        TimeLeft = Maths::Max(0, TimeLeft - 1);

        // Kill bullet at start of new tick (we don't instantly remove it so client can render it going splat)
        if (TimeLeft <= 0) return true;

        OldPos = CurrentPos;

        bool customGravity = false;
        for (int a = 0; a < modules.length(); a++)
        {
            if (modules[a].onGravityStep(this))
            {
                customGravity = true;
            }
        }

        Vec2f dir;
        if (!customGravity)
        {
            Gravity -= BulletGrav;

            // Direction shittery
            dir = Vec2f((FacingLeft ? -1 : 1), 0.0f).RotateBy(StartingAimAngle);
            CurrentPos += ((dir * Speed) - (Gravity * Speed));
            CurrentVelocity = CurrentPos - OldPos;
            Angle = -CurrentVelocity.getAngleDegrees();
        }

        for (int m = 0; m < modules.length(); m++)
        {
            modules[m].onTick(this);
        }
		
		GunSettings@ settings;
		gunBlob.get("gun_settings", @settings);

		f32 ammotype = settings.B_TYPE;
		f32 damage = settings.B_DAMAGE;

		//Increase damage if hooman blob is a follower of the swaggy laggy
		if (hoomanShooter.get_u8("deity_id") == Deity::swaglag)
		{
			CBlob@ altar = getBlobByName("altar_swaglag");
			if (altar !is null)
			{
				damage *= 1.00f + Maths::Min(altar.get_f32("deity_power") * 0.01f, 2.00f);
			}
		}
		
		const string S_FLESH_HIT  = gunBlob.exists("CustomSoundFlesh")  ? gunBlob.get_string("CustomSoundFlesh")  : "BulletImpact.ogg";
		const string S_OBJECT_HIT = gunBlob.exists("CustomSoundObject") ? gunBlob.get_string("CustomSoundObject") : "BulletImpact.ogg";

		Vec2f newPos = CurrentPos;
		bool continueRaycasting = true;
		int safety = Hits*3;
		while(continueRaycasting && safety > 0){
			safety--;
			if(safety <= 0)warn("Gun pierce safety limit was reached!! Gunlob:"+gunBlob.getName()+", Hits:"+Hits);
			continueRaycasting = false;
			newPos = CurrentPos;

			HitInfo@[] list;
			if (map.getHitInfosFromRay(OldPos, Angle, (CurrentPos - OldPos).Length(), hoomanShooter, @list))
			{
				for (int a = 0; a < list.length(); a++)
				{
					if(Hits <= 0)break;
					
					HitInfo@ hit = list[a];
					Vec2f hitpos = hit.hitpos;
					CBlob@ blob = @hit.blob;
					if (blob !is null)
					{
						if(safety <= 0)print("Hitting blob: "+blob.getName());
					
						int hash = blob.getName().getHash();
						bool breakOut = false;
						switch (hash)
						{
							case 804095823: // platform
							case 377147311: // iron platform
							{
								if (CollidesWithPlatform(blob, CurrentVelocity))
								{
									Hits -= 1;
									if(Hits <= 0){
										newPos = hitpos;
										breakOut = true;
									}

									if (isClient())
									{
										Sound::Play(S_OBJECT_HIT, hitpos, 1.5f);
									}
									if (isServer())
									{
										hoomanShooter.server_Hit(blob, hitpos, CurrentVelocity, damage, ammotype); 
									}
								}
							}
							break;

							default:
							{
								//print(blob.getName() + '\n'+blob.getName().getHash()); //useful for debugging new tiles to hit

								if (blob.hasTag("flesh") || blob.isCollidable() || blob.hasTag("vehicle"))
								{

									if (blob.getTeamNum() == gunBlob.getTeamNum() && !blob.getShape().isStatic()) continue;
									else if (blob.hasTag("weapon") || blob.hasTag("dead") || blob.hasTag("invincible") || 
											 blob.hasTag("food")   || blob.hasTag("gas")  || blob.isAttachedTo(hoomanShooter)) continue;
									else if (blob.getName() == "iron_halfblock" || blob.getName() == "stone_halfblock") continue;

									Hits -= 1;
									if(Hits <= 0){
										newPos = hitpos;
										breakOut = true;
									}

									if (isServer())
									{
										if (blob.hasTag("door")) damage *= 1.5f;
										hoomanShooter.server_Hit(blob, hitpos, dir, damage, ammotype);
										gunBlob.server_Hit(blob, hitpos, dir, 0.0f, ammotype, false); //For calling onHitBlob

										if (blob.hasTag("flesh") && gunBlob.exists("CustomKnock"))
										{
											SetKnocked(blob, gunBlob.get_u8("CustomKnock"));
										}

										CPlayer@ p = hoomanShooter.getPlayer();
										if (p !is null)
										{
											if (gunBlob.exists("CustomCoinFlesh"))
											{
												if (blob.hasTag("player")) p.server_setCoins(p.getCoins() + gunBlob.get_u32("CustomCoinFlesh"));
											}
											if (gunBlob.exists("CustomCoinObject"))
											{
												if (blob.hasTag("vehicle")) p.server_setCoins(p.getCoins() + gunBlob.get_u32("CustomCoinObject"));
											}
										}
									}
									if (isClient())
									{
										Sound::Play(S_FLESH_HIT, newPos, 1.5f);
									}
								}
							}
						}

						for (int m = 0; m < modules.length(); m++)
						{
							modules[m].onHitBlob(this, blob, hash, hitpos, damage);
						}
						if(breakOut)break;
					}
					else
					{ 
						Tile tile = map.getTile(hitpos);
						if(safety <= 0)print("Hitting tile: "+tile.type+" at pos: "+hitpos);
						
						if(!map.isTileBackground(tile) && tile.type != 0){
							if (isServer()){
								if(gunBlob.exists("CustomPierce") && gunBlob.get_u8("CustomPierce") > 1){
									for (int i = 0; i < 20; i++)
									map.server_DestroyTile(hitpos, damage*100.0f);
								} else {
									
									int blockDamageRepeat = gunBlob.exists("CustomBlockDamage") ? gunBlob.get_u8("CustomBlockDamage") : 1;
									for (int i = 0; i < blockDamageRepeat; i++)
									{
										if(isTilePlasteel(tile.type)){ ///Plasteel does not take bullet damage
										} else
										if(isTileGlass(tile.type)){ ///Glass is instantly destroyed when shot
											for (int i = 0; i < 2; i++)map.server_DestroyTile(hitpos, damage * 0.25f);
										} else
										if (map.isTileWood(tile.type)){ ///Wood takes damage every shot
											map.server_DestroyTile(hitpos, damage * 0.25f);
										} else
										if (map.isTileGroundStuff(tile.type) || isTileReinforcedConcrete(tile.type)){ ///Earth and reinforced concrete are very resistant to bullet fire
											if (XORRandom(8) < 1)map.server_DestroyTile(hitpos, damage * 0.25f);
										} else
										if (isTileKudzu(tile.type) || isTileConcrete(tile.type) || isTileMossyConcrete(tile.type)){ ///Concrete and leaves are somewhat resistant to bullet fire
											if (XORRandom(4) < 1)map.server_DestroyTile(hitpos, damage * 0.25f);
										} else {
											if (XORRandom(2) < 1)map.server_DestroyTile(hitpos, damage * 0.25f); ///Everything else takes about 2 hits before it takes damage
										}
									}
								}
							}
							if(!isTileKudzu(tile.type) && !isTileGlass(tile.type)){
								Hits -= 1;
								newPos = hitpos;
							}
						}

						if(Hits > 0){
							continueRaycasting = true;
							OldPos = hitpos;
						}

						if (isClient())
						{
							if (map.isTileGroundStuff(tile.type) || map.isTileWood(tile.type))
							{
								ParticleBulletHit("DustSmall.png", hitpos, -dir.Angle() - 90);
							}
							else if (map.isTileCastle(tile.type) || isTileConcrete(tile.type) || isTileReinforcedConcrete(tile.type))
							{
								ParticleBulletHit("Smoke.png", hitpos, -dir.Angle() - 90);
							}

							Sound::Play(S_OBJECT_HIT, hitpos, 1.5f);
						}

						for (int m = 0; m < modules.length(); m++)
						{
							modules[m].onHitTile(this, tile, hitpos, damage);
						}
						
						ParticleBullet(newPos, CurrentVelocity); //Little sparks
					}
				}
			}
		}
		CurrentPos = newPos;

        if(Hits <= 0)
        {
            if(Fade !is null)Fade.Front = CurrentPos;
			TimeLeft = 0;
        }

        return false;
    }

    void onRender() // Every bullet gets forced to join the queue in onRenders, so we use this to calc to position
    {
        if(Fade !is null)Fade.Front = Vec2f_lerp(OldPos, CurrentPos, FRAME_TIME);
		
		// Are we on the screen?
        const Vec2f xLast = PDriver.getScreenPosFromWorldPos(OldPos);
        const Vec2f xNew  = PDriver.getScreenPosFromWorldPos(CurrentPos);
        if (!(xNew.x > 0 && xNew.x < ScreenX)) // Is our main position still on screen?
        {
            if (!(xLast.x > 0 && xLast.x < ScreenX)) // Was our last position on screen?
            {
                return; // No, lets not stay here then
            }
        }

        // Lerp
        Vec2f newPos = Vec2f_lerp(OldPos, CurrentPos, FRAME_TIME);
        LastLerpedPos = newPos;

        for (int a = 0; a < modules.length(); a++)
        {
            modules[a].onRender(this);
        }
		
		if(Texture.empty()) return; //No point in trying to render if we have no texture.

        const f32 B_LENGTH = gunBlob.get_f32("CustomBulletLength");
        const f32 B_WIDTH  = gunBlob.get_f32("CustomBulletWidth");

        Vec2f topLeft  = Vec2f(newPos.x - B_WIDTH, newPos.y - B_LENGTH);
        Vec2f topRight = Vec2f(newPos.x - B_WIDTH, newPos.y + B_LENGTH);
        Vec2f botLeft  = Vec2f(newPos.x + B_WIDTH, newPos.y - B_LENGTH);
        Vec2f botRight = Vec2f(newPos.x + B_WIDTH, newPos.y + B_LENGTH);

        // Rotate the sprite to be in the correct pos
        f32 angle = Angle - 90;

        botLeft.RotateBy( angle, newPos);
        botRight.RotateBy(angle, newPos);
        topLeft.RotateBy( angle, newPos);
        topRight.RotateBy(angle, newPos);

        Vertex[]@ bullet_vertex;
        if(getRules().get(Texture, @bullet_vertex)){
			bullet_vertex.push_back(Vertex(topLeft.x,  topLeft.y,  0, 0, 0, trueWhite)); // top left
			bullet_vertex.push_back(Vertex(topRight.x, topRight.y, 0, 1, 0, trueWhite)); // top right
			bullet_vertex.push_back(Vertex(botRight.x, botRight.y, 0, 1, 1, trueWhite)); // bot right
			bullet_vertex.push_back(Vertex(botLeft.x,  botLeft.y,  0, 0, 1, trueWhite)); // bot left
		}
    }
}
