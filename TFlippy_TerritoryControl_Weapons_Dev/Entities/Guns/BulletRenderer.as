#include "BulletCommon.as";

Vertex[] vertices;
const f32 speed = 20;

void onInit(CRules@ this)
{
	Reset(this);
	Render::addScript(Render::layer_postworld, "BulletRenderer", "Render", 0.0f); //Only add once
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onReload(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	Bullet[] bullets;
	this.set("bullets", @bullets);
}

void Render(int id)
{
	CRules@ rules = getRules();
	if (rules !is null)
	{
		Bullet[]@ bullets;
		rules.get("bullets", @bullets);
		
		if (bullets !is null && bullets.length > 0)
		{
			vertices.clear();
			
			for (u32 i = 0; i < bullets.length; i++)
			{
				Bullet@ bullet = bullets[i];
			
				const f32 x = bullet.currentPos.x;
				const f32 y = bullet.currentPos.y;
				
				f32 size_x = 2.00f;
				f32 size_y = 0.50f;
				
				Vec2f tl = Vec2f(x - size_x, y - size_y);
				Vec2f tr = Vec2f(x - size_x, y + size_y);
				Vec2f bl = Vec2f(x + size_x, y - size_y);
				Vec2f br = Vec2f(x + size_x, y + size_y);
				
				f32 angle = -bullet.angle;
				Vec2f pos = Vec2f(x, y);
				
				tl.RotateBy(angle, pos);
				tr.RotateBy(angle, pos);
				bl.RotateBy(angle, pos);
				br.RotateBy(angle, pos);   

				SColor color = SColor(255, 255, 255, 255);
				vertices.push_back(Vertex(tl, 0, Vec2f(0, 0), color));
				vertices.push_back(Vertex(tr, 0, Vec2f(1, 0), color));
				vertices.push_back(Vertex(br, 0, Vec2f(1, 1), color));
				vertices.push_back(Vertex(bl, 0, Vec2f(0, 1), color));
				
				// Use something faster that doesn't involve square root
				bullet.distance = Maths::Clamp((bullet.currentPos - bullet.startPos).getLength() + speed, 0, bullet.distance_target);
				bullet.currentPos = bullet.startPos + (bullet.dir * bullet.distance);
				bullet.done = bullet.distance >= bullet.distance_target;
			}
		
			for (s32 i = 0; i < bullets.length;)
			{
				if (bullets[i].done)
				{
					bullets.removeAt(i);
				}
				else i++;
			}
		
			Render::RawQuads("Bullet.png", vertices);
		}
	}
}

const float lerp(float v0, float v1, float t)
{
	return v0 + t * (v1 - v0);
}