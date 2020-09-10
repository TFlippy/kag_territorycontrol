#include "DeityCommon.as";

void onInit(CRules@ this)
{
	Reset(this, getMap());
}

void onRestart(CRules@ this)
{
	Reset(this, getMap());
}

void onRulesRestart(CMap@ this, CRules@ rules)
{
	Reset(rules, this);
}

void Reset(CRules@ this, CMap@ map)
{
	int count = getPlayerCount();
	for (int i = 0; i < count; i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player !is null)
		{
			player.set_u8("deity_id", 0);
			
			CBlob@ blob = player.getBlob();
			if (blob !is null)
			{
				blob.set_u8("deity_id", 0);
			}
		}
	}
}

void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (player !is null && blob !is null)
	{
		u8 deity_id;
		
		if (isServer())
		{
			deity_id = player.get_u8("deity_id");
			blob.set_u8("deity_id", deity_id);
			blob.Sync("deity_id", false);
		}
		else if (isClient())
		{
			deity_id = blob.get_u8("deity_id");
		}

		switch (deity_id)
		{
			case Deity::mithrios:
			{
				blob.Tag("mithrios");
	
				blob.SetLight(true);
				blob.SetLightRadius(16.0f);
				blob.SetLightColor(SColor(255, 255, 0, 0));
			}
			break;
			
			case Deity::ivan:
			{
				blob.Tag("ivan");
			}
			break;
			
			case Deity::dragonfriend:
			{
				blob.Tag("dangerous");
			}
			break;
		}
	}
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{

	if (attacker !is null)
	{
		CBlob@ attacker_blob = attacker.getBlob();
		if (attacker_blob !is null)
		{
			u8 deity_id = attacker_blob.get_u8("deity_id");
			switch (deity_id)
			{
				case Deity::mithrios:
				{
					if (isServer())
					{
						CBlob@ altar = getBlobByName("altar_mithrios");
						if (altar !is null)
						{
							altar.add_f32("deity_power", 1 + XORRandom(10));
							if (isServer()) altar.Sync("deity_power", false);
						}
					}
					
					if (isClient())
					{
						CBlob@ victim_blob = victim.getBlob();
						if (victim_blob !is null)
						{
							victim_blob.getSprite().PlaySound("Soul_Scream", 0.70f, victim_blob.getSexNum() == 0 ? 1.0f : 2.0f);
						}
					}
				}
				break;
			}
		}
	}
}
