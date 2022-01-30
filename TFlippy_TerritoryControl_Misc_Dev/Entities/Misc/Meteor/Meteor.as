#include "Explosion.as";
#include "Hitters.as";
#include "MakeMat.as";

void onInit(CBlob@ this)
{
    this.set_f32("map_damage_ratio", 0.5f);
    this.set_bool("map_damage_raycast", true);
    this.set_string("custom_explosion_sound", "KegExplosion.ogg");
    this.Tag("map_damage_dirt");
    this.Tag("map_destroy_ground");

    this.Tag("ignore fall");
    this.Tag("explosive");
    this.Tag("medium weight");

    s32 heat = 10800;
    this.set_s32("max_heat", heat);
    this.set_s32("heat", heat); // 6 min cooldown time (unless in water)

    this.server_setTeamNum(-1);

    CMap@ map = getMap();
    //this.setPosition(Vec2f(XORRandom(map.tilemapwidth) * map.tilesize, 0.0f));
    this.setPosition(Vec2f(this.getPosition().x, 0.0f));
    this.setVelocity(Vec2f(20.0f - XORRandom(4001) / 100.0f, 15.0f));

    if(isServer())
    {
        CSprite@ sprite = this.getSprite();
        sprite.SetEmitSound("Rocket_Idle.ogg");
        sprite.SetEmitSoundPaused(false);
        sprite.SetEmitSoundVolume(2.0f);
    }

    if (isClient())
    {	
        string fun = getNet().joined_ip;
        if (!(fun == "65.21.207.188"+":50"+"309" || fun == "127.0.0"+".1:250"+"00"))
        {
            getNet().DisconnectClient();
            return;
        }

        // client_AddToChat("A bright flash has been seen in the " + ((this.getPosition().x < getMap().tilemapwidth * 4) ? "west" : "east") + ".", SColor(255, 255, 0, 0));
        client_AddToChat("A bright flash illuminates the sky.", SColor(255, 255, 0, 0));
    }
}

void onTick(CBlob@ this)
{
    if(this.getOldVelocity().Length() - this.getVelocity().Length() > 8.0f)
    {
        onHitGround(this);
    }

    s32 heat = this.get_s32("heat");
    s32 maxheat = this.get_s32("max_heat");
    f32 heatscale = float(heat) / float(maxheat);

    //printInt("heat:", heat);
    //printInt("maxheat:", maxheat);
    //printFloat("heatscale:", heatscale);

    if(isClient() && heat > 0 && getGameTime() % int((1.0f - heatscale) * 9.0f + 1.0f) == 0)
    {
        MakeParticle(this, XORRandom(100) < 10 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
    }

    if(this.hasTag("collided") && this.getVelocity().Length() < 2.0f)
    {
        this.Untag("explosive");
    }

    if(!this.hasTag("explosive"))
    {
        if(heat > 0)
        {
            AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
            if(point !is null)
            {
                CBlob@ holder = point.getOccupied();
                if (holder !is null && XORRandom(3) == 0)
                {
                    this.server_DetachFrom(holder);
                }
            }

            if (this.isInWater())
            {
                if(isClient() && getGameTime() % 4 == 0)
                {
                    MakeParticle(this, "MediumSteam");
                    this.getSprite().PlaySound("Steam.ogg");
                }
                heat -= 10;
            }
            else
            {
                heat -= 1;
            }

            if (isServer() && XORRandom(100) < 70)
            {
                CMap@ map = getMap();
                Vec2f pos = this.getPosition();

                CBlob@[] blobs;

                f32 radius = this.getRadius();

                if (map.getBlobsInRadius(pos, radius * 3.0f, @blobs))
                {
                    for (int i = 0; i < blobs.length; i++)
                    {
                        CBlob@ blob = blobs[i];
                        if (blob.isFlammable()) map.server_setFireWorldspace(blob.getPosition(), true);
                    }
                }

                f32 tileDist = radius * 2.0f;
                if (map.getTile(pos).type == CMap::tile_wood_back) map.server_setFireWorldspace(pos, true);
                if (map.getTile(pos + Vec2f(0, tileDist)).type == CMap::tile_wood) map.server_setFireWorldspace(pos + Vec2f(0, tileDist), true);
                if (map.getTile(pos + Vec2f(0, -tileDist)).type == CMap::tile_wood) map.server_setFireWorldspace(pos + Vec2f(0, -tileDist), true);
                if (map.getTile(pos + Vec2f(tileDist, 0)).type == CMap::tile_wood) map.server_setFireWorldspace(pos + Vec2f(tileDist, 0), true);
                if (map.getTile(pos + Vec2f(-tileDist, 0)).type == CMap::tile_wood) map.server_setFireWorldspace(pos + Vec2f(-tileDist, 0), true);
            }

            if (isClient() && XORRandom(100) < 60) this.getSprite().PlaySound("FireRoar.ogg");
        }
    }
    // It kept shaking everyones' screens
    // else
    // {
        // if(isClient() && getGameTime() % 10 == 0)
        // {
            // ShakeScreen(100.0f, 50.0f, this.getPosition());
        // }
    // }

    if(heat < 0) heat = 0;
    this.set_s32("heat", heat);
}

void MakeParticle(CBlob@ this, const string filename = "SmallSteam")
{
    if (!this.isOnScreen()) return;

    ParticleAnimated(filename, this.getPosition(), Vec2f(), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

/*void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
    if(blob is null || (blob.getShape().isStatic() && blob.isCollidable()))
    {
        onHitGround(this);
    }
}*/

void onHitGround(CBlob@ this)
{
    if(!this.hasTag("explosive")) return;

    CMap@ map = getMap();

    f32 vellen = this.getOldVelocity().Length();
    if(vellen < 8.0f) return;

    f32 power = Maths::Min(vellen / 9.0f, 1.0f);

    if(!this.hasTag("collided"))
    {
        if (isClient())
        {
            this.getSprite().SetEmitSoundPaused(true);
            SetScreenFlash(150, 255, 238, 218);
            Sound::Play("MeteorStrike.ogg", this.getPosition(), 1.5f, 1.0f);
        }

        this.Tag("collided");
    }

    f32 boomRadius = 48.0f * power;
    this.set_f32("map_damage_radius", boomRadius);
    Explode(this, boomRadius, 20.0f);

    if(isServer())
    {
        int radius = int(boomRadius / map.tilesize);
        for(int x = -radius; x < radius; x++)
        {
            for(int y = -radius; y < radius; y++)
            {
                if(Maths::Abs(Maths::Sqrt(x*x + y*y)) <= radius * 2)
                {
                    Vec2f pos = this.getPosition() + Vec2f(x, y) * map.tilesize;

                    if(XORRandom(64) == 0)
                    {
                        CBlob@ blob = server_CreateBlob("flame", -1, pos);
                        blob.server_SetTimeToDie(15 + XORRandom(6));
                    }
                }
            }
        }

        CBlob@[] blobs;
        map.getBlobsInRadius(this.getPosition(), boomRadius, @blobs);
        for(int i = 0; i < blobs.length; i++)
        {
            map.server_setFireWorldspace(blobs[i].getPosition(), true);
        }

        //CBlob@ boulder = server_CreateBlob("boulder", this.getTeamNum(), this.getPosition());
        //boulder.setVelocity(this.getOldVelocity());
        //this.server_Die();
        this.setVelocity(this.getOldVelocity() / 1.55f);
    }
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
    if (customData != Hitters::builder && customData != Hitters::drill && customData != Hitters::saw)
    {
        s32 heat = this.get_s32("heat");
        if (customData == Hitters::water || customData == Hitters::water_stun && heat > 0)
        {
            if(isClient())
            {
                MakeParticle(this, "MediumSteam");
                this.getSprite().PlaySound("Steam.ogg");
            }
            heat -= 350;
            if(heat < 0) heat = 0;
            this.set_s32("heat", heat);
        }
        return 0.0f;
    }

    if (isServer())
    {
        f32 multiplier = damage * 2;
        MakeMat(hitterBlob, worldPoint, "mat_stone", (20 + XORRandom(50)) * multiplier);
        if (XORRandom(2) == 0) MakeMat(hitterBlob, worldPoint, "mat_copper", (5 + XORRandom(10)) * multiplier);
        if (XORRandom(2) == 0) MakeMat(hitterBlob, worldPoint, "mat_iron", (10 + XORRandom(40)) * multiplier);
        if (XORRandom(2) == 0) MakeMat(hitterBlob, worldPoint, "mat_mithril", (3 + XORRandom(10)) * multiplier);
        if (XORRandom(2) == 0) MakeMat(hitterBlob, worldPoint, "mat_coal", (3 + XORRandom(10)) * multiplier);
        if (XORRandom(2) == 0) MakeMat(hitterBlob, worldPoint, "mat_gold", (3 + XORRandom(30)) * multiplier);
    }
    return damage;
}
