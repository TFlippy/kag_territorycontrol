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

    // Pointer to BulletModules
    BulletModule@[] modules;

    Vec2f CurrentVelocity;
    Vec2f LastLerpedPos;
    Vec2f CurrentPos;
    Vec2f BulletGrav;
    Vec2f OldPos;
    Vec2f Gravity;
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

        GunSettings@ settings;
        gun.get("gun_settings", @settings);

        StartingAimAngle = angle;
        CurrentPos = pos;

        BulletGrav = settings.B_GRAV;
        FacingLeft = gun.isFacingLeft();

        TimeLeft = settings.B_TTL;
        Speed = settings.B_SPEED;

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
        if (TimeLeft == 0) return true;

        OldPos = LastLerpedPos;

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
            CurrentPos = ((dir * Speed) - (Gravity * Speed)) + CurrentPos;
            CurrentVelocity = CurrentPos - OldPos;
            Angle = -CurrentVelocity.getAngleDegrees();
        }

        for (int a = 0; a < modules.length(); a++)
        {
            modules[a].onTick(this);
        }

        bool endBullet = false;
        HitInfo@[] list;
        if (map.getHitInfosFromRay(OldPos, Angle, CurrentVelocity.Length(), hoomanShooter, @list))
        {
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

            bool breakLoop = false;

            for (int a = 0; a < list.length(); a++)
            {
                HitInfo@ hit = list[a];
                Vec2f hitpos = hit.hitpos;
                CBlob@ blob = @hit.blob;
                if (blob !is null)
                {
                    int hash = blob.getName().getHash();
                    switch (hash)
                    {
                        case 804095823: // platform
                        case 377147311: // iron platform
                        {
                            if (CollidesWithPlatform(blob, CurrentVelocity))
                            {
                                CurrentPos = hitpos;
                                breakLoop = true;

                                if (isClient())
                                {
                                    Sound::Play(S_OBJECT_HIT, CurrentPos, 1.5f);
                                }
                                if (isServer())
                                {
                                    hoomanShooter.server_Hit(blob, CurrentPos, CurrentVelocity, damage, ammotype); 
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

                                CurrentPos = hitpos;

                                if (isServer())
                                {
                                    if (blob.hasTag("door")) damage *= 1.5f;
                                    hoomanShooter.server_Hit(blob, CurrentPos, dir, damage, ammotype);
                                    gunBlob.server_Hit(blob, CurrentPos, dir, 0.0f, ammotype, false); //For calling onHitBlob

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
                                    Sound::Play(S_FLESH_HIT, CurrentPos, 1.5f);
                                }

                                breakLoop = true;
                            }
                        }
                    }

                    for (int a = 0; a < modules.length(); a++)
                    {
                        modules[a].onHitBlob(this, blob, hash, hitpos, damage);
                    }

                    if (breakLoop) // So we can break while inside the switch
                    {
                        endBullet = true;
                        break;
                    }
                }
                else
                { 
                    Tile tile = map.getTile(hitpos);
                    if (isServer())
                    {
                        if (gunBlob.exists("CustomPenetration"))
                        {
                            for (int i = 0; i < gunBlob.get_u8("CustomPenetration"); i++)
                            {
                                map.server_DestroyTile(hitpos, damage * 0.25f);
                            }
                        }
                        else
                        {
                            if (map.isTileGroundStuff(tile.type))
                            {
                                //Bullet resistance
                                if (XORRandom(4) < 3) map.server_DestroyTile(hitpos, damage * 0.25f);
                            }
                            else
                            {
                                map.server_DestroyTile(hitpos, damage * 0.25f);
                            }
                        }
                    }

                    if (isClient())
                    {
                        if (map.isTileGroundStuff(tile.type) || map.isTileWood(tile.type))
                        {
                            ParticleBulletHit("DustSmall.png", hitpos, -dir.Angle() - 90);
                        }
                        else if (map.isTileCastle(tile.type) || isTileConcrete(tile.type))
                        {
                            ParticleBulletHit("Smoke.png", hitpos, -dir.Angle() - 90);
                        }

                        Sound::Play(S_OBJECT_HIT, hitpos, 1.5f);
                    }

                    for (int a = 0; a < modules.length(); a++)
                    {
                        modules[a].onHitTile(this, tile, hitpos, damage);
                    }

                    CurrentPos = hitpos;
                    ParticleBullet(CurrentPos, CurrentVelocity); //Little sparks

                    if (tile.type != CMap::tile_empty && !map.isTileBackground(tile))
                    {
                        endBullet = true;
                    }
                }
            }
        }

        if (endBullet)
        {
            TimeLeft = 1;
        }

        return false;
    }

    void onRender() // Every bullet gets forced to join the queue in onRenders, so we use this to calc to position
    {
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

        //Find a better solution later
        if (gunBlob.exists("CustomBullet") && gunBlob.get_string("CustomBullet").empty()) return;

        // Lerp
        Vec2f newPos = Vec2f_lerp(OldPos, CurrentPos, FRAME_TIME);
        LastLerpedPos = newPos;

        for (int a = 0; a < modules.length(); a++)
        {
            modules[a].onRender(this);
        }

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
        getRules().get(gunBlob.get_string("CustomBullet"), @bullet_vertex);

        bullet_vertex.push_back(Vertex(topLeft.x,  topLeft.y,  0, 0, 0, trueWhite)); // top left
        bullet_vertex.push_back(Vertex(topRight.x, topRight.y, 0, 1, 0, trueWhite)); // top right
        bullet_vertex.push_back(Vertex(botRight.x, botRight.y, 0, 1, 1, trueWhite)); // bot right
        bullet_vertex.push_back(Vertex(botLeft.x,  botLeft.y,  0, 0, 1, trueWhite)); // bot left
    }
}
