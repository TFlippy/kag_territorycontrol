#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "DeityCommon.as";
#include "MakeSeed.as";
#include "MakeMat.as";

void onInit(CBlob@ this)
{
	Random@ rand = Random(this.getNetworkID());

	this.set_u8("deity_id", Deity::dragonfriend);
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	
	// CSprite@ sprite = this.getSprite();
	// sprite.SetEmitSound("AltarDragonfriend_Music.ogg");
	// sprite.SetEmitSoundVolume(0.40f);
	// sprite.SetEmitSoundSpeed(1.00f);
	// sprite.SetEmitSoundPaused(false);
	
	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 170, 255, 61));
	
	AddIconToken("$icon_dragonfriend_follower$", "InteractionIcons.png", Vec2f(32, 32), 11);
	{
		ShopItem@ s = addShopItem(this, "Rite of Greed", "$icon_dragonfriend_follower$", "follower", "Gain a Premium Dragon Membership by paying 1000 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 1499);
		s.customButton = true;
		s.buttonwidth = 2;	
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
	
	AddIconToken("$icon_dragonfriend_offering_0$", "AltarDragonfriend_Icons.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Deposit of Stonks", "$icon_dragonfriend_offering_0$", "offering_protopopov", "Deposit 500 coins into a Stonks Investment Fund.");
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
		s.customButton = true;
		s.buttonwidth = 1;	
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	
	AddIconToken("$icon_dragonfriend_offering_1$", "AltarDragonfriend_Icons.png", Vec2f(24, 24), 1);
	{
		ShopItem@ s = addShopItem(this, "Withdrawal of Stonks", "$icon_dragonfriend_offering_1$", "offering_mlg", "Withdraw 500 coins from a Stonks Investment Fund.");
		s.customButton = true;
		s.buttonwidth = 1;	
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	
	AddIconToken("$icon_dragonfriend_offering_2$", "AltarDragonfriend_Icons.png", Vec2f(24, 24), 2);
	{
		ShopItem@ s = addShopItem(this, "Offering of Doritos", "$icon_dragonfriend_offering_2$", "offering_doritos", "Sacrifice some money to buy Doritos from the built-in vending machine.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.customButton = true;
		s.buttonwidth = 1;	
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	
	this.set_f32("stonks_volatility", 0.20f);
	this.set_f32("stonks_growth", 0.01f);
	this.set_f32("stonks_value", rand.NextRanged(stonks_value_max));

	this.addCommandID("stonks_update");
	this.addCommandID("stonks_purchase");
}

// const u32 stonks_update_frequency = 30 * 5;
const u32 stonks_update_frequency = 30 * 2;
// const u32 stonks_update_frequency = 3;
const f32 stonks_value_min = 100.00f;
const f32 stonks_value_max = 2000.00f;

f32[] graph = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
int graph_index = 0;


void onTick(CBlob@ this)
{
	const bool server = isServer();
	const bool client = isClient();

	if (client)
	{
		buy_pressed = false;	
		sell_pressed = false;	
	
		const f32 power = this.get_f32("deity_power");
	
		const f32 stonks_volatility = this.get_f32("stonks_volatility");
		const f32 stonks_growth = this.get_f32("stonks_growth");
		const f32 stonks_value = this.get_f32("stonks_value");
		
		string volatility_text;
		if (stonks_volatility > 0.90f) volatility_text = "extremely high";
		else if (stonks_volatility > 0.80f) volatility_text = "very high";
		else if (stonks_volatility > 0.60f) volatility_text = "high";
		else if (stonks_volatility > 0.40f) volatility_text = "medium";
		else if (stonks_volatility > 0.20f) volatility_text = "low";
		else volatility_text = "very low";
		
		string text = "Altar of the Dragon\n";
		text += "\nDragon Power: " + power;
		text += "\nFire Resistance: +" + Maths::Min(power * 0.01f, 100.00f) + "%";
		// text += "\n\nStonks:";
		// text += "\nVolatility: " + volatility_text;
		// text += "\nGrowth: " + (stonks_growth >= 0 ? "+" : "-") + (Maths::Abs(s32(stonks_growth * 10000.00f) * 0.01f)) + "%";
		// text += "\n";
		// text += "\nSell Price: " + Maths::Ceil(stonks_value) + " coins";
		// text += "\nBuy Price: " + Maths::Ceil(stonks_value * 0.98f) + " coins";
		this.setInventoryName(text);
		
		const f32 radius = 64.00f + ((power / 100.00f) * 8.00f);
		this.SetLightRadius(radius);
	}
	
	if (server)
	{
		u32 ticks = this.getTickSinceCreated();
		// print("" + ticks);
		
		if (ticks % stonks_update_frequency == 0)
		{
			// print("updating stonks");
		
			f32 stonks_volatility = this.get_f32("stonks_volatility");
			f32 stonks_growth = this.get_f32("stonks_growth");
			f32 stonks_value = this.get_f32("stonks_value");
		
			if (stonks_value == stonks_value_min || stonks_value == stonks_value_max) stonks_growth *= -Maths::Min(0.30f + stonks_volatility, 0.80f);
			if ((XORRandom(100) * 0.01f) < Maths::Pow(stonks_volatility, 2.00f)) stonks_growth *= -stonks_volatility * 1.40f;
			if ((XORRandom(100) * 0.01f) > Maths::Pow(stonks_volatility, 2.00f)) stonks_growth *= 0.80f;
			if ((XORRandom(100) * 0.01f) > Maths::Pow(stonks_volatility, 3.00f)) stonks_growth *= 1.25f;
		
			f32 stonks_volatility_new = (XORRandom(100) < 20) ? Maths::Pow(XORRandom(100) * 0.01f, 1.50f) : (stonks_volatility);
			f32 stonks_growth_new = stonks_growth + (((1000 - XORRandom(2000)) / 1000.00f) * (stonks_volatility_new * stonks_volatility_new * 0.05f));
			f32 stonks_value_new = Maths::Clamp(stonks_value * (1.00f + stonks_growth_new), stonks_value_min, stonks_value_max);
		
			CBitStream stream;
			
			stream.write_f32(stonks_volatility_new);
			stream.write_f32(stonks_growth_new);
			stream.write_f32(stonks_value_new);
			
			this.SendCommand(this.getCommandID("stonks_update"), stream);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		u16 caller, item;
		if (params.saferead_netid(caller) && params.saferead_netid(item))
		{
			string data = params.read_string();
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob !is null)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer !is null)
				{
					if (data == "follower")
					{
						this.add_f32("deity_power", 100);
						if (isServer()) this.Sync("deity_power", false);
						
						if (isClient())
						{
							// if (callerBlob.get_u8("deity_id") != Deity::dragonfriend)
							// {
								// client_AddToChat(callerPlayer.getCharacterName() + " has become a follower of Dragonfriend.", SColor(255, 255, 0, 0));
							// }
							
							CBlob@ localBlob = getLocalPlayerBlob();
							if (localBlob !is null)
							{
								if (this.getDistanceTo(localBlob) < 128)
								{
									this.getSprite().PlaySound("MLG_Hit", 2.00f, 1.00f);
									this.getSprite().PlaySound("MLG_Airhorn", 2.00f, 1.00f);
									SetScreenFlash(255, 255, 255, 255, 3.00f);
								}
							}
						}
						
						if (isServer())
						{
							callerPlayer.set_u8("deity_id", Deity::dragonfriend);
							callerPlayer.Sync("deity_id", false);
							
							callerBlob.set_u8("deity_id", Deity::dragonfriend);
							callerBlob.Sync("deity_id", false);
						}
					}
					else
					{
						if (data == "offering_protopopov")
						{
							this.add_f32("deity_power", 150);
							if (isServer()) this.Sync("deity_power", false);
							
							if (isServer())
							{
								CBlob@ item = server_MakeSeed(this.getPosition(), "protopopov_plant");
								callerBlob.server_Pickup(item);
							}
							
							if (isClient())
							{
								this.getSprite().PlaySound("MLG_Hit", 2.00f, 1.00f);
							}
						}
						else if (data == "offering_mlg")
						{
							this.add_f32("deity_power", 200);
							if (isServer()) this.Sync("deity_power", false);
							
							if (isServer())
							{
								CBlob@ item = server_CreateBlob("mlg", this.getTeamNum(), this.getPosition());
								callerBlob.server_Pickup(item);
							}
							
							if (isClient())
							{
								this.getSprite().PlaySound("MLG_Hit", 2.00f, 1.00f);
							}
						}
						else if (data == "offering_doritos")
						{
							this.add_f32("deity_power", 1);
							if (isServer()) this.Sync("deity_power", false);
							
							if (isServer())
							{
								CBlob@ item = server_CreateBlob("doritos", this.getTeamNum(), this.getPosition());
								callerBlob.server_Pickup(item);
							}
							
							if (isClient())
							{
								this.getSprite().PlaySound("MLG_Hit", 2.00f, 1.00f);
							}
						}
					}
				}				
			}
		}
	}
	else if (cmd == this.getCommandID("stonks_update"))
	{
		f32 stonks_volatility;
		f32 stonks_growth;
		f32 stonks_value;
		
		if (params.saferead_f32(stonks_volatility) && params.saferead_f32(stonks_growth) && params.saferead_f32(stonks_value))
		{
			// f32 stonks_value_old = this.get_f32("stonks_value");
			// f32 stonks_difference = stonks_value_new - stonks_value_old;
			// f32 stonks_percentage = stonks_value_old > 0.00f ? (stonks_value_new / stonks_value_old) : 0.00f;
			
			// print("updating stonks " + stonks_value_new);
			
			f32 stonks_value_old = this.get_f32("stonks_value");
			f32 stonks_value_delta = stonks_value / stonks_value_old;
			
			
			this.set_f32("stonks_volatility", stonks_volatility);
			this.set_f32("stonks_growth", stonks_growth);
			this.set_f32("stonks_value", Maths::Clamp(stonks_value, stonks_value_min, stonks_value_max));
			
			// print("" + stonks_value);
			
			graph[graph_index] = stonks_value;
			graph_index = Maths::FMod(graph_index + 1, graph.length());
			
			// print("" + stonks_value_delta);
			
			// string log_text = "Stonks #" + (this.getTickSinceCreated() / stonks_update_frequency);
			// log_text += "; 		Volatility: " + (Maths::Round(stonks_volatility * 1000.00f)) * 0.001f;
			// log_text += "; 		Growth: " + (Maths::Round(stonks_growth * 1000.00f)) * 0.1f;
			// log_text += "; 		Value: " + (Maths::Round(stonks_value * 1000.00f)) * 0.001f;
			// print(log_text);
			
			this.getSprite().PlaySound("LotteryTicket_Kaching", 0.25f, 1.00f + ((stonks_value_delta - 1.00f) * 4.00f));
		}
	}
	else if (cmd == this.getCommandID("stonks_purchase") && isServer())
	{
		u16 caller_netid;
		u8 action;
		
		if (params.saferead_netid(caller_netid) && params.saferead_u8(action))
		{
			CBlob@ caller = getBlobByNetworkID(caller_netid);
			if (caller !is null)
			{
				CPlayer@ callerPlayer = caller.getPlayer();
				if (callerPlayer !is null)
				{
					CBitStream reqs;
					CBitStream missing;
				
					f32 stonks_value = this.get_f32("stonks_value");
				
					s32 buy_price = Maths::Ceil(stonks_value * 1.02f);
					s32 sell_price = Maths::Ceil(stonks_value);
				
					switch (action)
					{
						case 0: // Buy
						{
							AddRequirement(reqs, "coin", "", "Coins", buy_price);
						}
						break;
						
						case 1: // Sell
						{
							AddRequirement(reqs, "blob", "mat_stonks", "Stonks", 1);
						}
						break;
					}
					
					bool has_reqs = false;
					if (hasRequirements_Tech(caller.getInventory(), this.getInventory(), reqs, missing))
					{
						if (isClient())
						{
							server_TakeRequirements(caller.getInventory(), this.getInventory(), reqs);
						}
						
						has_reqs = true;
					}
					
					if (has_reqs)
					{
						switch (action)
						{
							case 0: // Buy
							{
								if (isServer())
								{
									MakeMat(caller, this.getPosition(), "mat_stonks", 1);
									// this.set_f32("stonks_value", Maths::Clamp(stonks_value + (buy_price * 0.02f), stonks_value_min, stonks_value_max));
									// this.Sync("stonks_value", false);
								}
								
								if (isClient())
								{
									this.getSprite().PlaySound("/ChaChing.ogg");
								}
							}
							break;
							
							case 1: // Sell
							{
								if (isServer())
								{
									callerPlayer.server_setCoins(callerPlayer.getCoins() + sell_price);
									// this.set_f32("stonks_value", Maths::Clamp(stonks_value - (sell_price * 0.02f), stonks_value_min, stonks_value_max));
									// this.Sync("stonks_value", false);
								}
								
								if (isClient())
								{
									this.getSprite().PlaySound("/ChaChing.ogg");
								}
							}
							break;
						}
					}
					
					
					// print("has reqs: " + has_reqs);
				}
			}
		}
	}
}

f32 axis_x = 200;
f32 axis_y = 90;

void onRender(CSprite@ this)
{
	CBlob@ localBlob = getLocalPlayerBlob();
	if (localBlob !is null)
	{
		CBlob@ blob = this.getBlob();
		Vec2f blobPos = blob.getPosition();
		Vec2f localPos = localBlob.getPosition();
		
		bool inRange = (blobPos - localPos).getLength() < 32.00f;
		if (inRange)
		{
			f32 stonks_volatility = blob.get_f32("stonks_volatility");
			f32 stonks_growth = blob.get_f32("stonks_growth");
			f32 stonks_value = blob.get_f32("stonks_value");
			
			// string volatility_text;
			// if (stonks_volatility > 0.90f) volatility_text = "extremely high";
			// else if (stonks_volatility > 0.80f) volatility_text = "very high";
			// else if (stonks_volatility > 0.60f) volatility_text = "high";
			// else if (stonks_volatility > 0.40f) volatility_text = "medium";
			// else if (stonks_volatility > 0.20f) volatility_text = "low";
			// else volatility_text = "very low";
			
			Vec2f pos = blob.getScreenPos() + Vec2f(-axis_x * 0.50f, 224);

			GUI::DrawWindow(pos - Vec2f(8, axis_y + 8), pos + Vec2f(8 + axis_x, 8));
			GUI::DrawLine2D(pos, pos + Vec2f(0, -axis_y), SColor(255, 196, 135, 58));
			GUI::DrawLine2D(pos, pos + Vec2f(axis_x, 0), SColor(255, 196, 135, 58));
			
			string text;
			// text += "\nVolatility: " + volatility_text;
			text += "\nGrowth: " + (stonks_growth >= 0 ? "+" : "-") + (Maths::Abs(s32(stonks_growth * 10000.00f) * 0.01f)) + "%";
			text += "\n";
			text += "\nSell Price: " + Maths::Ceil(stonks_value) + " coins";
			text += "\nBuy Price: " + Maths::Ceil(stonks_value * 1.02f) + " coins";
			
			GUI::SetFont("menu");
			GUI::DrawText("Stonks Dashboard", pos + Vec2f(axis_x + 16, -axis_y - 8), SColor(255, 255, 255, 255));
			
			GUI::SetFont("");
			GUI::DrawText(text, pos + Vec2f(axis_x + 16, -axis_y - 0), SColor(255, 255, 255, 255));
			
			if (DrawButton("Buy", pos + Vec2f(axis_x + 16, -24), Vec2f(64, 32)) && !buy_pressed)
			{
				buy_pressed = true;
				
				Sound::Play("option");
				// print("he bought");
				
				CBitStream stream;
				stream.write_netid(localBlob.getNetworkID());
				stream.write_u8(0);
				blob.SendCommand(blob.getCommandID("stonks_purchase"), stream);
			}
			
			if (DrawButton("Sell", pos + Vec2f(axis_x + 16 + 64, -24), Vec2f(64, 32)) && !sell_pressed)
			{
				sell_pressed = true;
			
				Sound::Play("option");
				// print("he sold");
				
				CBitStream stream;
				stream.write_netid(localBlob.getNetworkID());
				stream.write_u8(1);
				blob.SendCommand(blob.getCommandID("stonks_purchase"), stream);
			}
			
			f32 step_x = axis_x / graph.length();
			for (int i = 0; i < graph.length() - 1; i++)
			{
				f32 value_a = (graph[Maths::FMod(i + graph_index, graph.length())] / stonks_value_max);
				f32 value_b = (graph[Maths::FMod(i + graph_index + 1, graph.length())] / stonks_value_max);
				
				// if (value_a == 0 || value_b == 0) continue;
				
				Vec2f pos_a = Vec2f(4 + pos.x + ((i + 0) * step_x), pos.y - (value_a * axis_y));
				Vec2f pos_b = Vec2f(4 + pos.x + ((i + 1) * step_x), pos.y - (value_b * axis_y));
				
				// print("" + value_b);
				
				GUI::DrawLine2D(pos_a + Vec2f(2, 2), pos_b + Vec2f(2, 2), SColor(255, 196, 135, 58));
				GUI::DrawLine2D(pos_a, pos_b, SColor(255, u8(Maths::Clamp((1.00f - value_b) * 500.00f, 0.00f, 255.00f)), u8(Maths::Clamp(value_b * 500.00f, 0.00f, 255.00f)), 0));
			}
			
			// GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 4), SColor(transparency, 148, 27, 27));
			// GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 2), SColor(transparency, 183, 51, 51));
		}
	}
}

bool buy_pressed = false;
bool sell_pressed = false;

bool DrawButton(string text, Vec2f pos, Vec2f size)
{
	f32 width = size.x;
	f32 height = size.y;

	Vec2f dim;
	GUI::GetTextDimensions(text, dim);

	Vec2f tl = pos + Vec2f(0, 0);
	Vec2f br = pos + Vec2f(width, height);
	
	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();
	
	bool hover = mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y;
	bool pressed = false;
	
	if (hover)
	{
		GUI::DrawButton(tl, br);
		
		if (controls.isKeyJustPressed(KEY_LBUTTON))
		{
			pressed = true;
		}
	}
	else
	{
		GUI::DrawPane(tl, br, 0xffcfcfcf);
	}
	
	GUI::DrawTextCentered(text, Vec2f(tl.x + (width * 0.50f), tl.y + (height * 0.50f)), 0xffffffff);
	
	return pressed;
}