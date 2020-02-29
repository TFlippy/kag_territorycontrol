// in memory of Mirsario

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "MiscCommon.as";
#include "BasePNGLoader.as";
#include "LoadWarPNG.as";

void onInit(CRules@ this)
{
	this.addCommandID("teleport");
	this.addCommandID("addbot");
	this.addCommandID("kickPlayer");
	this.addCommandID("mute_sv");
	this.addCommandID("mute_cl");
	this.addCommandID("playsound");
	this.addCommandID("startInfection");
	this.addCommandID("endInfection");

	if (isClient())
	{
		this.set_bool("log",false);//so no clients can get logs unless they do ~logging
	}
	if (isServer())
	{
		this.set_bool("log",true);//server always needs to log anyway
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	/*ShakeScreen(64,32,tpBlob.getPosition());
	ParticleZombieLightning(tpBlob.getPosition());
	tpBlob.getSprite().PlaySound("MagicWand.ogg");

	tpBlob.setPosition(destBlob.getPosition());

	ShakeScreen(64,32,destBlob.getPosition());
	ParticleZombieLightning(destBlob.getPosition());
	destBlob.getSprite().PlaySound("MagicWand.ogg");*/

	if (cmd == this.getCommandID("teleport")) 
	{
		u16 tpBlobId, destBlobId;

		if (!params.saferead_u16(tpBlobId)) 
		{
			return;
		}
		
		if (!params.saferead_u16(destBlobId)) 
		{
			return;
		}

		CBlob@ tpBlob =	getBlobByNetworkID(tpBlobId);
		CBlob@ destBlob = getBlobByNetworkID(destBlobId);
		
		if (tpBlob !is null && destBlob !is null)
		{
			if (isClient())
			{
				ShakeScreen(64,32,tpBlob.getPosition());
				ParticleZombieLightning(tpBlob.getPosition());
			}
			
			tpBlob.setPosition(destBlob.getPosition());
			
			if (isClient())
			{
				ShakeScreen(64,32,destBlob.getPosition());
				ParticleZombieLightning(destBlob.getPosition());
			}
		}
	}
	else if (cmd==this.getCommandID("addbot")) 
	{
		string botName;
		string botDisplayName;
		
		if (!params.saferead_string(botName)) 
		{
			return;
		}
		
		if (!params.saferead_string(botDisplayName)) {
		
			return;
		}
		
		CPlayer@ bot=AddBot(botName);
		bot.server_setCharacterName(botDisplayName);
	}
	else if (cmd==this.getCommandID("kickPlayer")) 
	{
		string username;
		if (!params.saferead_string(username)) 
		{
			return;
		}
		
		CPlayer@ player=getPlayerByUsername(username);
		if (player !is null)
		{
			KickPlayer(player);
		}
	}
	else if (cmd==this.getCommandID("playsound")) 
	{
		string soundname;

		if (!params.saferead_string(soundname)) 
		{
			return;
		}
		
		f32 volume = 1.00f;
		f32 pitch = 1.00f;
		
		params.saferead_f32(volume);
		params.saferead_f32(pitch);
		
		if (volume == 0.00f) Sound::Play(soundname);
		else Sound::Play(soundname, getCamera().getPosition() + getRandomVelocity(0, 8, 360), volume, pitch);
	}
	else if (cmd == this.getCommandID("mute_sv"))
	{
		if (isClient())
		{
			string blob;
			CPlayer@ lp = getLocalPlayer();
			
			ConfigFile@ cfg = ConfigFile();
			if (cfg.loadFile("../Cache/EmoteBindings.cfg"))
			{
				blob = cfg.read_string("emote_19", "invalid");
			}
			
			CBitStream stream;
			stream.write_u16(lp.getNetworkID());
			stream.write_string(blob);
			
			this.SendCommand(this.getCommandID("mute_cl"), stream);
		}
	}	
	else if (cmd == this.getCommandID("mute_cl"))
	{
		if (isServer())
		{
			u16 id;
			string blob;
			
			if (params.saferead_netid(id) && params.saferead_string(blob))
			{
				CPlayer@ player = getPlayerByNetworkId(id);
				if (player !is null)
				{
					string name = player.getUsername();
					string blob_to_name = h2s(blob);
					
					bool valid = name == blob_to_name;
					
					if (valid)
					{
						print("[NC] (SUCCESS): " + name + " = " + blob + " = " + blob_to_name, SColor(255, 0, 255, 0));
					}
					else
					{
						print("[NC] (FAILURE): " + name + " = " + blob + " = " + blob_to_name,  SColor(255, 255, 0, 0));
					}
					
					string filename = "player_" + name + ".cfg";
					
					ConfigFile@ cfg = ConfigFile();
					cfg.loadFile("../Cache/Players/" + filename);
						
					cfg.add_string("" + Time(), ("(" + (valid ? "SUCCESS" : "FAILURE") + ") " + name + " = " + blob + " = " + blob_to_name + "; CharacterName: " + player.getCharacterName()));
					cfg.saveFile("Players/" + filename);
				}
			}
		}
	}
	/*else if (cmd==this.getCommandID("startInfection"))
	{
		u16 startInfection;
		if (!params.saferead_u16(startInfection))
		{
			return;
		}
		CPlayer@ p = getPlayerByNetworkId(startInfection);
		if (p !is null)
		{
			string message = p.getCharacterName();
			client_AddToChat(message+" has started the awootism infection, stay away at all costs", SColor(255, 255, 0, 0));
			CBlob@ blob = p.getBlob();
			if (blob.hasTag("infectOver"))
			{
				blob.Untag("infectOver");
				blob.Sync("infectOver",false);
				blob.Tag("awootism");
				blob.Sync("awootism",false);
			}
			else
			{
				blob.AddScript('AwooootismSpread.as');
			}
		}
	}
	else if (cmd==this.getCommandID("endInfection"))
	{
		u16 startInfection;
		if (!params.saferead_u16(startInfection))
		{
			return;
		}
		CBlob@ blob = getPlayerByNetworkId(startInfection).getBlob();
		if (blob.hasTag("endAwoo"))
		{
			blob.Untag("endAwoo");
			blob.Sync("endAwoo",false);
		}
		blob.AddScript('EndAwoootism.as');
	}*/
}

bool onServerProcessChat(CRules@ this,const string& in text_in,string& out text_out,CPlayer@ player)
{
	if (player is null){
		return true;
	}
	CBlob@ blob = player.getBlob();
	if (blob is null){
		return true;
	}
	
	bool isCool=IsCool(player.getUsername());
	bool isMod=	player.isMod();

	if (isCool && text_in == "!ripserver") 
	{
		QuitGame();
	}
	
	bool showMessage=(player.getUsername()!="TFlippy" && player.getUsername()!="merser433");

	if (text_in.substr(0,1) == "!") 
	{
		if (showMessage)
		{
			print("Command by player "+player.getUsername()+" (Team "+player.getTeamNum()+"): "+text_in);
		}
		
		string[]@ tokens = text_in.split(" ");
		if (tokens.length > 0) 
		{
			if (tokens.length > 1 && tokens[0] == "!write")
			{
				if (player.getCoins() < 50) return false;

				string text = "";

				for (int i = 1; i < tokens.length; i++) text += tokens[i] + " ";

				text = text.substr(0, text.length - 1);

				Vec2f dimensions;
				GUI::GetTextDimensions(text, dimensions);

				if (dimensions.x > 120) return false;

				CBlob@ paper = server_CreateBlobNoInit("paper");
				paper.setPosition(blob.getPosition());
				paper.server_setTeamNum(blob.getTeamNum());
				paper.set_string("text", text);
				paper.Init();

				player.server_setCoins(player.getCoins() - 50);

				return true;
			}

			// print(tokens.length);
			
			//For at least moderators
			if (isMod || isCool)
			{
				if (tokens[0] == "!admin") 
				{
					if (blob.getName()!="grandpa") 
					{
						player.server_setTeamNum(-1);
						CBlob@ newBlob = server_CreateBlob("grandpa",-1,blob.getPosition());
						newBlob.server_SetPlayer(player);
						blob.server_Die();
					}
					else
					{
						blob.server_Die();
					}
					return false;
				}
				else if (tokens[0] == "!check") 
				{
					print("NAME CHECK");
				
					CBitStream stream;
					this.SendCommand(this.getCommandID("mute_sv"), stream);
					
					return false;
				}
				else if ((tokens[0]=="!tp")) 
				{
					if (tokens.length != 2 && (tokens.length != 3 || (tokens.length == 3 && !isCool)))
					{
						return false;
					}
					
					CPlayer@ tpPlayer =	GetPlayer(tokens[1]);
					CBlob@ tpBlob =	tokens.length == 2 ? blob : tpPlayer.getBlob();
					CPlayer@ tpDest = GetPlayer(tokens.length == 2 ? tokens[1] : tokens[2]);

					if (tpBlob !is null && tpDest !is null) 
					{
						CBlob@ destBlob = tpDest.getBlob();
						if (destBlob !is null) 
						{
							if (isCool || blob.getName() == "grandpa")
							{
								CBitStream params;
								params.write_u16(tpBlob.getNetworkID());
								params.write_u16(destBlob.getNetworkID());
								this.SendCommand(this.getCommandID("teleport"), params);
							}
							else if (!isCool)
							{
								player.server_setTeamNum(-1);
								CBlob@ newBlob = server_CreateBlob("grandpa",-1,destBlob.getPosition());
								newBlob.server_SetPlayer(player);
								tpBlob.server_Die();
							}
						}
					}
					return false;
				}
			}
			
			if (isCool)
			{
				/*if (tokens[0]=="!awootism")
				{
					CBitStream params;
					if (tokens.length > 1)
					{	CPlayer@ toInfect = GetPlayer(tokens[1]);
						if (toInfect !is null)
						{
							params.write_u16(toInfect.getNetworkID());
						}
					}
					else
					{
						params.write_u16(player.getNetworkID());	
					}
					this.SendCommand(this.getCommandID("startInfection"),params);
					return false;
				}
				else if (tokens[0]=="!endawootism")
				{

					CBitStream params;
					params.write_u16(player.getNetworkID());	
					this.SendCommand(this.getCommandID("endInfection"),params);
				}*/
				if (tokens[0]=="!coins") 
				{
					int amount=	tokens.length>=2 ? parseInt(tokens[1]) : 100;
					player.server_setCoins(player.getCoins()+amount);
					return false;
				}
				else if (tokens[0] == "!bbe") 
				{
					if (tokens.length > 1)
					{
						CPlayer@ seller = getPlayerByUsername(tokens[1]);
						if (seller !is null)
						{
							CBlob@[] blobs;
							getBlobsByTag("big shop", @blobs);
							
							for (int i = 0; i < blobs.length; i++)
							{
								CBlob@ blob = blobs[i];
								if (blob !is null)
								{
									CBitStream stream;
									stream.write_u16(seller.getNetworkID());
									stream.write_string(seller.getUsername());
									
									blob.SendCommand(blob.getCommandID("buyout"), stream);
								}
							}
						}
					}
					
					return false;
				}
				else if (tokens[0]=="!playsound")
				{
					if (tokens.length < 2)
					{
						print("" + tokens.length);
						return false;
					}

					CBitStream params;
					params.write_string(tokens[1]);
					params.write_f32(tokens.length > 2 ? parseFloat(tokens[2]) : 0.00f);
					params.write_f32(tokens.length > 3 ? parseFloat(tokens[3]) : 1.00f);
					
					this.SendCommand(this.getCommandID("playsound"), params);

					return false;
				}
				else if (tokens[0]=="!removebot" || tokens[0]=="!kickbot") 
				{
					int playersAmount=	getPlayerCount();
					for(int i=0;i<playersAmount;i++){
						CPlayer@ user=getPlayer(i);
						if (user !is null && user.isBot()){
							CBitStream params;
							params.write_u16(getPlayerIndex(user));
							this.SendCommand(this.getCommandID("kickPlayer"),params);
							return false;
						}
					}
					return false;
				}
				else if (tokens[0]=="!addbot" || tokens[0]=="!bot") 
				{
					if (tokens.length<2){
						return false;
					}
					string botName=			tokens[1];
					string botDisplayName=	tokens[1];
					for(int i=2;i<tokens.length;i++){
						botName+=		tokens[i];
						botDisplayName+=" "+tokens[i];
					}

					CBitStream params;
					params.write_string(botName);
					params.write_string(botDisplayName);
					this.SendCommand(this.getCommandID("addbot"),params);
					return false;
				}
				else if (tokens[0]=="!crate") 
				{
					if (tokens.length<2){
						return false;
					}
					int frame = tokens[1]=="catapult" ? 1 : 0;
					string description = tokens.length > 2 ? tokens[2] : tokens[1];
					server_MakeCrate(tokens[1],description,frame,-1,blob.getPosition());
					return false;
				}
				else if (tokens[0]=="!scroll")
				{
					if (tokens.length<2){
						return false;
					}
					string s = tokens[1];
					for(uint i=2;i<tokens.length;i++){
						s+=" "+tokens[i];
					}
					server_MakePredefinedScroll(blob.getPosition(),s);
					return false;
				}
				else if (tokens[0]=="!disc") 
				{
					if (tokens.length!=2){
						return false;
					}
					
					const u8 trackID = u8(parseInt(tokens[1]));
					CBlob@ b=server_CreateBlobNoInit("musicdisc");
					b.server_setTeamNum(-1);
					b.setPosition(blob.getPosition());
					b.set_u8("track_id", trackID);
					b.Init();

					// CBitStream stream;
					// stream.write_u8(u8(parseInt(tokens[1])));
					// b.SendCommand(b.getCommandID("set"),stream);
					return false;
				}else if (tokens[0]=="!time") {
					if (tokens.length<2){
						return false;
					}
					getMap().SetDayTime(parseFloat(tokens[1]));
					return false;
				}else if (tokens[0]=="!team") {
					if (tokens.length<2){
						return false;
					}
					int team=parseInt(tokens[1]);
					blob.server_setTeamNum(team);

					player.server_setTeamNum(team); // Finally
					return false;
				}else if (tokens[0]=="!playerteam") {
					if (tokens.length!=3){
						return false;
					}
					CPlayer@ user = GetPlayer(tokens[1]);

					if (user !is null) {
						CBlob@ userBlob=user.getBlob();
						if (userBlob !is null){
							userBlob.server_setTeamNum(parseInt(tokens[2]));
						}
					}
					return false;
				}else if (tokens[0]=="!class") {
					if (tokens.length!=2){
						return false;
					}
					CBlob@ newBlob = server_CreateBlob(tokens[1],blob.getTeamNum(),blob.getPosition());
					if (newBlob !is null){
						newBlob.server_SetPlayer(player);
						blob.server_Die();
					}
					return false;
				}else if (tokens[0]=="!playerclass") {
					if (tokens.length!=3){
						return false;
					}
					CPlayer@ user = GetPlayer(tokens[1]);

					if (user !is null) {
						CBlob@ userBlob=user.getBlob();
						if (userBlob !is null){
							CBlob@ newBlob = server_CreateBlob(tokens[2],userBlob.getTeamNum(),userBlob.getPosition());
							if (newBlob !is null){
								newBlob.server_SetPlayer(user);
								userBlob.server_Die();
							}
						}
					}
					return false;
				}else if (tokens[0]=="!tphere") {
					if (tokens.length!=2){
						return false;
					}
					CPlayer@ tpPlayer=		GetPlayer(tokens[1]);
					if (tpPlayer !is null){
						CBlob@ tpBlob=		tpPlayer.getBlob();
						if (tpBlob !is null) {
							CBitStream params;
							params.write_u16(tpBlob.getNetworkID());
							params.write_u16(blob.getNetworkID());
							getRules().SendCommand(this.getCommandID("teleport"),params);
						}
					}
					return false;
				}else if (tokens[0]=="!tree") {
					server_MakeSeed(blob.getPosition(),"tree_pine",600,1,16);
					return false;
				}else if (tokens[0]=="!teambot") {
					CPlayer@ bot = AddBot("gregor_builder");
					bot.server_setTeamNum(player.getTeamNum());

					CBlob@ newBlob = server_CreateBlob("builder",player.getTeamNum(),blob.getPosition());
					newBlob.server_SetPlayer(bot);
					return false;
				}else if (tokens[0]=="!debug") {
					CBlob@[] all; // print all blobs
					getBlobs(@all);

					for(u32 i=0;i<all.length;i++) {
						CBlob@ blob=all[i];
						print("["+blob.getName()+" "+blob.getNetworkID()+"] ");
					}
					return false;
				}else if (tokens[0]=="!bigtree") {
					server_MakeSeed(blob.getPosition(),"tree_bushy",400,2,16);
					return false;
				}else if (tokens[0]=="!spawnwater") {
					getMap().server_setFloodWaterWorldspace(blob.getPosition(),true);
					return false;
				}
				else if (tokens[0]=="!savefile") 
				{
					ConfigFile cfg;
					cfg.add_u16("something",1337);
					cfg.saveFile("TestFile.cfg");
					return false;
				}
				else if (tokens[0]=="!loadfile") 
				{
					ConfigFile cfg;
					if (cfg.loadFile("../Cache/TestFile.cfg")) 
					{
						print("loaded");
						print("value is " + cfg.read_u16("something"));
						print(getFilePath(getCurrentScriptName()));
					}
					return false;
				}
				else if (tokens[0]=="!nextmap")
				{
					LoadNextMap();
					return false;
				}
				else if (tokens[0]=="!loadmap") 
				{
					LoadMap(getMap(),"lol.png");
					return false;
				}
				else if (tokens[0]=="!savemap") 
				{
					// SaveMap(getMap(),"lol.png");
					
					ConfigFile maps;
					maps.add_bool("saved", true);
					maps.saveFile("t_meta");
					
					return false;
				}
				else if (tokens[0]=="!stoprain") 
				{
					CBlob@[] blobs;
					getBlobsByName('rain', @blobs);
					for (int i = 0; i < blobs.length; i++)
					{
						if (blobs[i] !is null)
						{
							blobs[i].server_Die();
						}
					}					
					
					return false;
				}
				// else if (tokens.length > 2 && tokens[0] == "!g")
				// {
					// string text = "";
					// for (int i = 1; i < tokens.length; i++) text += tokens[i] + " ";
					// text = text.substr(0, text.length - 1);
				
					// this.SetGlobalMessage(text);
				// }
				else if (tokens[0] == "!cursor")
				{
					if (tokens.length > 1)
					{
						string name = tokens[1];

						CBlob@ newBlob = server_CreateBlob(name, blob.getTeamNum(), blob.getAimPos());
						if (newBlob !is null && player !is null) 
						{
							newBlob.SetDamageOwnerPlayer(player);
							
							int quantity;
							if (tokens.length > 2)
							{
								quantity = parseInt(tokens[2]);
							}
							else
							{
								quantity = newBlob.maxQuantity;
							}
							
							newBlob.server_SetQuantity(quantity);
						}
					}
				
					return false;
				}
				else
				{
					if (tokens.length > 0)
					{
						string name = tokens[0].substr(1);

						CBlob@ newBlob = server_CreateBlob(name, blob.getTeamNum(), blob.getPosition());
						if (newBlob !is null && player !is null) 
						{
							newBlob.SetDamageOwnerPlayer(player);
							
							int quantity;
							if (tokens.length > 1)
							{
								quantity = parseInt(tokens[1]);
							}
							else
							{
								quantity = newBlob.maxQuantity;
							}
							
							newBlob.server_SetQuantity(quantity);
						}
					}
				
					return false;
				}
			}
		}
		return false;
	}
	else
	{
		if (blob.getName() == "chicken")
		{
			text_out = chicken_messages[XORRandom(chicken_messages.length)];
		}
		else if (blob.getName() == "bison")
		{
			text_out = bison_messages[XORRandom(bison_messages.length)];
		}
	}
	return true;
}

// void onNewPlayerJoin(CRules@ this, CPlayer@ p)
// {
	// if (isServer())
	// {
		// CBitStream stream;
		// this.SendCommand(this.getCommandID("mute_sv"), stream);
	// }
// }

const string[] chicken_messages =
{
	"Bwak!!!",
	"Coo-coo!!",
	"bwaaaak.. bwak.. bwak",
	"Coo-coo-coo",
	"bwuk-bwuk-bwuk...",
	"bwak???",
	"bwakwak, bwak!"
};

const string[] bison_messages =
{
	"Moo...",
	"moooooooo?",
	"Mooooooooo...",
	"MOOO!",
	"Mooooo.. Moo."
};
			
string h2s(string s)
{
	string o;
	o.set_length(s.length / 2);
	for (int i = 0; i < o.length; i++)
	{
		// o[i] = parseInt(s.substr(i * 2, 2), 16, 1);
		o[i] = parseInt(s.substr(i * 2, 2));
		
		// o[(i * 2) + 0] = h[byte / 16];
		// o[(i * 2) + 1] = h[byte % 16];
	}
	
	return o;
}

/*else if (tokens[0]=="!tpinto")
{
	if (tokens.length!=2){
		return false;
	}
	CPlayer@ tpPlayer=	GetPlayer(tokens[1]);
	if (tpPlayer !is null){
		CBlob@ tpBlob=		tpPlayer.getBlob();
		if (tpBlob !is null) {
			AttachmentPoint@ point=	blob.getAttachments().getAttachmentPointByName("PICKUP");
			if (point is null){
				return false;
			}
			for(int i=0;i<blob.getAttachments().getOccupiedCount();i++){
				AttachmentPoint@ point2=blob.getAttachments().getAttachmentPointByID(i);
				if (point !is null){
					CBlob@ pointBlob3=point2.getOccupied();
					if (pointBlob3 !is null){
						print(pointBlob3.getName());
					}
				}
			}
			//tpBlob.setPosition(blob.getPosition());
			//tpBlob.server_AttachTo(CBlob@ blob,AttachmentPoint@ ap)
		}
	}
	return false;
}*/

bool IsCool(string username)
{
	return 	username=="TFlippy" ||
			username=="merser433" ||
			username=="Verdla" ||
			username=="Vamist" ||
			username=="Pirate-Rob" ||
			username=="GoldenGuy" ||
			username=="Koi_" ||
			username=="digga" ||
			username=="Asu" ||
			(isServer()&&isClient()); //**should** return true only on localhost
}

CPlayer@ GetPlayer(string username)
{
	username=			username.toLower();
	int playersAmount=	getPlayerCount();
	for(int i=0;i<playersAmount;i++){
		CPlayer@ player=getPlayer(i);
		if (player.getUsername().toLower()==username || (username.size()>=3 && player.getUsername().toLower().findFirst(username,0)==0)){
			return player;
		}
	}
	return null;
}

bool onClientProcessChat(CRules@ this,const string& in text_in,string& out text_out,CPlayer@ player)
{
	// string[]@ tokens = text_in.split(" ");
	// if (tokens.length > 0)
	// {
		// if (tokens.length > 1 && tokens[0] == "!write")
		// {
			// print("wrt");

			// if (player.getCoins() < 50)
			// {
				// client_AddToChat("You need at least 50 coins in order to write on a paper.");
				// return false;
			// }

			// string text = "";

			// for (int i = 1; i < tokens.length; i++) text += tokens[i] + " ";

			// text = text.substr(0, text.length - 1);

			// Vec2f dimensions;
			// GUI::GetTextDimensions(text, dimensions);

			// if (dimensions.x > 120)
			// {
				// client_AddToChat("Your text is too long, therefore it doesn't fit on the paper.");
				// return false;
			// }

			// return true;
		// }
	// }

	if (text_in=="!debug" && !isServer())
	{
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for(u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");

			if (blob.getShape() !is null)
			{
				CBlob@[] overlapping;
				if (blob.getOverlapping(@overlapping))
				{
					for(uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ overlap = overlapping[i];
						print("       " + overlap.getName() + " " + overlap.isLadder());
					}
				}
			}
		}
	}
	else if (text_in=="~logging")//for some reasons ! didnt work
	{
		if (player.isRCON())
		{
			this.set_bool("log",!this.get_bool("log"));
		}
	}

	return true;
}
