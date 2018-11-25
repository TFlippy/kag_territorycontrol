#include "Explosion.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

const f32 hitmap_chance = 0.25f;

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 8;

	this.getSprite().SetEmitSound("Sparkle.ogg");

	this.getSprite().SetEmitSoundPaused(false);
	this.SetLight(true);
	this.SetLightRadius(48.0f);

	this.server_SetTimeToDie(5);
	
	
	this.set_bool("map_damage_raycast", true);
	this.Tag("map_damage_dirt");
	this.Tag("projectile");
	
	this.Tag("use hitmap");
	this.set_f32("hitmap_chance", hitmap_chance);
	
	 // To compensate for explosions dealing higher tile damage
	this.set_f32("mining_multiplier", (1.25f / hitmap_chance) * 2.00f);
}

void onTick(CSprite@ this)
{
	sparks(this.getBlob().getPosition(), this.getBlob().getAngleDegrees(), 3.5f + (XORRandom(10) / 5.0f), SColor(255, 255, 230, 0));
}

void sparks(Vec2f at, f32 angle, f32 speed, SColor color)
{
	Vec2f vel = getRandomVelocity(angle + 90.0f, speed, 25.0f);
	at.y -= 2.5f;
	ParticlePixel(at, vel, color, true, 119);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.isCollidable();
}

// void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
// {
	// if (inventoryBlob is null) return;

	// CInventory@ inv = inventoryBlob.getInventory();

	// if (inv is null) return;

	// this.doTickScripts = true;
	// inv.doTickScripts = true;
// }

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	// No chain reactions, as they cause crashes
	if (customData == Hitters::explosion)
	{
		this.Tag("exploded");
		if (getNet().isServer()) this.server_Die();
	}
	
	return damage;
}

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
	DoExplosion(this);
}

void DoExplosion(CBlob@ this)
{
	if (this.hasTag("exploded")) return;

	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = -this.get_f32("bomb angle");
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (40.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.50f);
	
	Explode(this, 40.0f + random, 25.0f);
	
	for (int i = 0; i < 10 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();
		
		LinearExplosion(this, dir, 16.0f + XORRandom(16) + (modifier * 8), 16 + XORRandom(24), 3, 2.00f, Hitters::explosion);
	}
	
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	
	for (int i = 0; i < 35; i++)
	{
		MakeParticle(this, Vec2f( XORRandom(64) - 32, XORRandom(80) - 60), getRandomVelocity(-angle, XORRandom(220) * 0.01f, 90), particles[XORRandom(particles.length)]);
	}
	
	this.Tag("exploded");
	this.getSprite().Gib();
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}





// void WorldExplode(Vec2f position, f32 radius, f32 damage)
// {
	// Vec2f pos = position;
	// CMap@ map = getMap();

	// //load custom properties
	// //map damage
	// f32 map_damage_radius = radius;
	// f32 map_damage_ratio = 0.5f;
	// bool map_damage_raycast = true;
	// u8 hitter = Hitters::explosion;
	
	// bool should_teamkill = true;

	// const int r = (radius * (2.0 / 3.0));

	// // print("rad: " + radius + "; " + damage);
	// ShakeScreen(damage * radius, 40.00f * Maths::FastSqrt(damage / 5.00f), pos);
	// makeLargeExplosionParticle(pos);

	// for (int i = 0; i < radius * 0.16; i++)
	// {
		// Vec2f partpos = pos + Vec2f(XORRandom(r * 2) - r, XORRandom(r * 2) - r);
		// Vec2f endpos = partpos;

		// if (map !is null)
		// {
			// if (!map.rayCastSolid(pos, partpos, endpos))
				// makeSmallExplosionParticle(endpos);
		// }
	// }

	// if (getNet().isServer())
	// {
		// //hit map if we're meant to
		// if (map_damage_radius > 0.1f)
		// {
			// int tile_rad = int(map_damage_radius / map.tilesize) + 1;
			// f32 rad_thresh = map_damage_radius * map_damage_ratio;
			// Vec2f m_pos = (pos / map.tilesize);
			// m_pos.x = Maths::Floor(m_pos.x);
			// m_pos.y = Maths::Floor(m_pos.y);
			// m_pos = (m_pos * map.tilesize) + Vec2f(map.tilesize / 2, map.tilesize / 2);

			// //explode outwards
			// for (int x_step = 0; x_step <= tile_rad; ++x_step)
			// {
				// for (int y_step = 0; y_step <= tile_rad; ++y_step)
				// {
					// Vec2f offset = (Vec2f(x_step, y_step) * map.tilesize);

					// for (int i = 0; i < 4; i++)
					// {
						// if (i == 1)
						// {
							// if (x_step == 0) { continue; }

							// offset.x = -offset.x;
						// }

						// if (i == 2)
						// {
							// if (y_step == 0) { continue; }

							// offset.y = -offset.y;
						// }

						// if (i == 3)
						// {
							// if (x_step == 0) { continue; }

							// offset.x = -offset.x;
						// }

						// f32 dist = offset.Length();

						// if (dist < map_damage_radius)
						// {
							// //do we need to raycast?
							// bool canHit = !map_damage_raycast || (dist < 0.1f);

							// if (!canHit)
							// {
								// Vec2f v = offset;
								// v.Normalize();
								// v = v * (dist - map.tilesize);
								// canHit = !(map.rayCastSolid(m_pos, m_pos + v));
							// }

							// if (canHit)
							// {
								// Vec2f tpos = m_pos + offset;

								// TileType tile = map.getTile(tpos).type;
								// if (canExplosionDamage(map, tpos, tile))
								// {
									// if (!map.isTileBedrock(tile))
									// {
										// if (dist >= rad_thresh || map.isTileGroundStuff(tile)) //  !canExplosionDestroy(this, map, tpos, tile)) // (this.hasTag("map_damage_dirt") ? true : !canExplosionDestroy(this, map, tpos, t))
										// {
											// map.server_DestroyTile(tpos, 1.0f);			
										// }
										// else
										// {
											// map.server_DestroyTile(tpos, 100.0f);
										// }
									// }
								// }
							// }
						// }
					// }
				// }
			// }
		// }

		// //hit blobs
		// CBlob@[] blobs;
		// map.getBlobsInRadius(pos, radius, @blobs);

		// for (uint i = 0; i < blobs.length; i++)
		// {
			// CBlob@ hit_blob = blobs[i];
			// WorldHitBlob(pos, hit_blob, radius, damage, hitter, true, should_teamkill);
		// }
	// }
// }

// bool WorldHitBlob(Vec2f position, CBlob@ hit_blob, f32 radius, f32 damage, const u8 hitter, const bool bother_raycasting = true, const bool should_teamkill = true)
// {
	// Vec2f pos = position;
	// CMap@ map = getMap();
	// Vec2f hit_blob_pos = hit_blob.getPosition();
	// Vec2f wall_hit;
	// Vec2f hitvec = hit_blob_pos - pos;

	// f32 scale;
	// f32 dam = damage * scale;

	// //explosion particle
	// makeSmallExplosionParticle(hit_blob_pos);

	// //hit the object
	// hit_blob.server_Hit(hit_blob, hit_blob_pos, Vec2f(), dam, hitter, true);
	// return true;
// }