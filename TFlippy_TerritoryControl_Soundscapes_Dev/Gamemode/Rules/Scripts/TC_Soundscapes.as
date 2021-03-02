// Game Music

#define CLIENT_ONLY

enum GameMusicTag
{
	world_ambient_start,
		world_ambient_day,
		world_ambient_night,
		world_ambient_underground,
		world_ambient_mountain,
		world_ambient_upf_city,
		world_ambient_upf_base,
		world_ambient_upf_bunker,
		world_ambient_faction,
	world_ambient_end,
	
	world_soundscape_start,
		soundscape_world_day,
		soundscape_world_night,
		soundscape_world_underground,
		soundscape_world_mountain,
		soundscape_upf_city,
		soundscape_upf_base,
		soundscape_upf_bunker,
		soundscape_faction,
	world_soundscape_end,
	
	world_music_start,
		world_intro,
		world_home,
		world_calm,
		world_battle,
		world_battle_2,
		world_outro,
		world_quick_out,
		world_none,
	world_music_end,
};

void onInit(CBlob@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null) return;

	mixer.ResetMixer();
	this.set_bool("initialized game", false);
}

void onTick(CBlob@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null) return;

	if (s_soundon != 0 && s_musicvolume > 0.0f)
	{
		if (!this.get_bool("initialized game"))
		{
			AddGameMusic(this, mixer);
		}

		GameMusicLogic(this, mixer);
	}
	else
	{
		mixer.FadeOutAll(0.0f, 2.0f);
	}
}

void onReload(CBlob@ this)
{	
	CMixer@ mixer = getMixer();
	if (mixer !is null) AddGameMusic(this, mixer);
}

//sound references with tag
void AddGameMusic(CBlob@ this, CMixer@ mixer)
{
	if (mixer is null) return;

	this.set_bool("initialized game", true);
	mixer.ResetMixer();
	
	// Ambient Loops
	mixer.AddTrack("ambient_forrest.ogg", world_ambient_day);
	mixer.AddTrack("ambient_mountain.ogg", world_ambient_mountain);
	mixer.AddTrack("ambient_cavern.ogg", world_ambient_underground);
	mixer.AddTrack("ambient_night.ogg", world_ambient_night);
	mixer.AddTrack("ambient_upf_city.ogg", world_ambient_upf_city);
	mixer.AddTrack("ambient_upf_base.ogg", world_ambient_upf_base);
	mixer.AddTrack("ambient_upf_bunker.ogg", world_ambient_upf_bunker);
	mixer.AddTrack("ambient_faction.ogg", world_ambient_faction);
	
	// Nature Day
	mixer.AddTrack("amb_birds_0.ogg", soundscape_world_day);
	mixer.AddTrack("amb_birds_1.ogg", soundscape_world_day);
	mixer.AddTrack("amb_birds_2.ogg", soundscape_world_day);
	mixer.AddTrack("amb_birds_3.ogg", soundscape_world_day);
	
	// Nature Night
	mixer.AddTrack("amb_crickets.ogg", soundscape_world_night);
	mixer.AddTrack("amb_owl_0.ogg", soundscape_world_night);
	mixer.AddTrack("amb_owl_1.ogg", soundscape_world_night);
	mixer.AddTrack("amb_owl_2.ogg", soundscape_world_night);
	mixer.AddTrack("amb_wind_0.ogg", soundscape_world_night);
	mixer.AddTrack("amb_wind_1.ogg", soundscape_world_night);
	
	// Nature Mountain
	mixer.AddTrack("amb_crow_0.ogg", soundscape_world_mountain);
	mixer.AddTrack("amb_crow_1.ogg", soundscape_world_mountain);
	mixer.AddTrack("amb_wind_0.ogg", soundscape_world_mountain);
	mixer.AddTrack("amb_wind_1.ogg", soundscape_world_mountain);
	
	// Nature Underground
	mixer.AddTrack("amb_wind_0.ogg", soundscape_world_underground);
	mixer.AddTrack("amb_wind_1.ogg", soundscape_world_underground);
	mixer.AddTrack("amb_badger_0.ogg", soundscape_world_underground);
	mixer.AddTrack("amb_abstract_0.ogg", soundscape_world_underground);
	mixer.AddTrack("amb_abstract_1.ogg", soundscape_world_underground);
		
	// UPF City
	mixer.AddTrack("amb_marching.ogg", soundscape_upf_city);
	mixer.AddTrack("amb_aircraft.ogg", soundscape_upf_city);
	mixer.AddTrack("amb_train_0.ogg", soundscape_upf_city);
	mixer.AddTrack("amb_train_1.ogg", soundscape_upf_city);
	mixer.AddTrack("amb_train_2.ogg", soundscape_upf_city);
	mixer.AddTrack("amb_ambulance.ogg", soundscape_upf_city);
	mixer.AddTrack("amb_police.ogg", soundscape_upf_city);
	mixer.AddTrack("amb_truck.ogg", soundscape_upf_city);
	mixer.AddTrack("amb_helicopter.ogg", soundscape_upf_city);
	mixer.AddTrack("amb_abstract_0.ogg", soundscape_upf_city);
	mixer.AddTrack("amb_abstract_1.ogg", soundscape_upf_city);
	mixer.AddTrack("amb_metal_stress_0.ogg", soundscape_upf_city);
	mixer.AddTrack("amb_metal_stress_1.ogg", soundscape_upf_city);
	mixer.AddTrack("amb_metal_stress_2.ogg", soundscape_upf_city);
	
	// UPF Base
	mixer.AddTrack("amb_marching.ogg", soundscape_upf_base);
	mixer.AddTrack("amb_aircraft.ogg", soundscape_upf_base);
	mixer.AddTrack("amb_train_0.ogg", soundscape_upf_base);
	mixer.AddTrack("amb_train_1.ogg", soundscape_upf_base);
	mixer.AddTrack("amb_train_2.ogg", soundscape_upf_base);
	mixer.AddTrack("amb_helicopter.ogg", soundscape_upf_base);
	
	// UPF Bunker
	mixer.AddTrack("amb_marching.ogg", soundscape_upf_bunker);
	mixer.AddTrack("amb_metal_stress_0.ogg", soundscape_upf_bunker);
	mixer.AddTrack("amb_metal_stress_1.ogg", soundscape_upf_bunker);
	mixer.AddTrack("amb_metal_stress_2.ogg", soundscape_upf_bunker);
	mixer.AddTrack("amb_abstract_0.ogg", soundscape_upf_bunker);
	mixer.AddTrack("amb_abstract_1.ogg", soundscape_upf_bunker);

	// Faction
	mixer.AddTrack("amb_birds_0.ogg", soundscape_faction);
	mixer.AddTrack("amb_birds_1.ogg", soundscape_faction);
	mixer.AddTrack("amb_birds_2.ogg", soundscape_faction);
	mixer.AddTrack("amb_birds_3.ogg", soundscape_faction);
	
	// Music
	mixer.AddTrack("Sounds/Music/KAGWorldIntroShortA.ogg", world_intro);
	mixer.AddTrack("Sounds/Music/KAGWorld1-1a.ogg", world_home);
	mixer.AddTrack("Sounds/Music/KAGWorld1-2a.ogg", world_home);
	mixer.AddTrack("Sounds/Music/KAGWorld1-3a.ogg", world_home);
	mixer.AddTrack("Sounds/Music/KAGWorld1-4a.ogg", world_home);
	mixer.AddTrack("Sounds/Music/KAGWorld1-5a.ogg", world_calm);
	mixer.AddTrack("Sounds/Music/KAGWorld1-6a.ogg", world_calm);
	mixer.AddTrack("Sounds/Music/KAGWorld1-7a.ogg", world_calm);
	mixer.AddTrack("Sounds/Music/KAGWorld1-8a.ogg", world_calm);
	mixer.AddTrack("Sounds/Music/KAGWorld1-9a.ogg", world_home);
	mixer.AddTrack("Sounds/Music/KAGWorld1-10a.ogg", world_battle);
	mixer.AddTrack("Sounds/Music/KAGWorld1-11a.ogg", world_battle);
	mixer.AddTrack("Sounds/Music/KAGWorld1-12a.ogg", world_battle);
	mixer.AddTrack("Sounds/Music/KAGWorld1-13+Intro.ogg", world_battle_2);
	mixer.AddTrack("Sounds/Music/KAGWorld1-14.ogg", world_battle_2);
	mixer.AddTrack("Sounds/Music/KAGWorldQuickOut.ogg", world_quick_out);
}

u32 next_soundscape = 0;

GameMusicTag currentAmbience = world_ambient_day;

void GameMusicLogic(CBlob@ this, CMixer@ mixer)
{
	if (mixer is null || !s_gamemusic) return;

	u32 time = getGameTime();
	
	CRules @rules = getRules();
	CBlob @blob = getLocalPlayerBlob();
	if (blob is null)
	{
		mixer.FadeOutAll(0.0f, 6.0f);
		return;
	}

	CMap@ map = blob.getMap();
	if (map is null) return;

	Vec2f pos = blob.getPosition();

	u8 team = blob.getTeamNum();
	f32 dayTime = map.getDayTime();
	
	if (time % 10 == 0)
	{
		GameMusicTag chosenAmbience = world_ambient_day;
		GameMusicTag chosenMusic = world_none;
	
		bool isUnderground = map.rayCastSolid(pos, Vec2f(pos.x, pos.y - 128.0f));
		bool isUPF = false;
		bool isUrban = false;
		bool isFaction = false;
		bool isHostile = false;
		bool isDay = dayTime >= 0.10f && dayTime <= 0.90f;
		bool isRaining = getRules().get_bool("raining");
		
		CBlob@[] upf_buildings;
		getBlobsByTag("upf_base", @upf_buildings);
		getBlobsByName("merchantchicken", @upf_buildings);
		
		for (uint i = 0; i < upf_buildings.length; i++)
		{
			CBlob@ building = upf_buildings[i];
			if (building !is null)
			{
				if (building.getDistanceTo(blob) < 700.0f)
				{
					isUPF = true;
					if (team != 250) isHostile = true;
					if (building.getName() == "merchantchicken") isUrban = true;
				}
			}
		}
		
		CBlob@[] faction_bases;
		getBlobsByTag("faction_base", @faction_bases);
		
		for (uint i = 0; i < faction_bases.length; i++)
		{
			CBlob @base = faction_bases[i];
			if (base !is null)
			{
				if (base.getDistanceTo(blob) < 400.0f)
				{
					isFaction = true;
					if (base.getTeamNum() != blob.getTeamNum()) isHostile = true;
				}
			}
		}
		
		if (isUPF)
		{
			// if (isHostile && !isUnderground) chosenMusic = world_battle;
			// else chosenMusic = world_none;
		
			chosenMusic = world_none;
		
			if (isUrban) 
			{
				chosenAmbience = world_ambient_upf_city;
			}
			else
			{
				if (isUnderground) 
				{
					chosenAmbience = world_ambient_upf_bunker;
				}
				else 
				{
					chosenAmbience = world_ambient_upf_base;
				}
			}
		}
		else if (isFaction)
		{
			if (isHostile) 
			{
				chosenMusic = world_battle;
			}
			else 
			{
				chosenMusic = world_home;
			}
		
			if (!isRaining)
			{
				if (isDay)
				{
					chosenAmbience = world_ambient_faction;
				}
				else
				{
					chosenAmbience = world_ambient_night;
				}
			}
			else
			{
				chosenAmbience = world_none;
				chosenMusic = world_none;
			}
		}
		else
		{
			if (isUnderground || isRaining) 
			{
				chosenAmbience = world_ambient_underground;
				chosenMusic = world_none;
			}
			else if (pos.y < map.tilemapheight * map.tilesize * 0.2f) 
			{
				chosenAmbience = world_ambient_mountain;
				chosenMusic = world_none;
			}
			else
			{
				if (isDay)
				{			
					chosenAmbience = world_ambient_day;
					chosenMusic = world_calm;
				}
				else 
				{
					chosenAmbience = world_ambient_night;
					chosenMusic = world_none;
				}
			}			
		}

		changeAmbience(mixer, chosenAmbience, 3.0f, 3.0f);
		changeMusic(mixer, chosenMusic, 3.00f, 3.00f);
	}

	// print("" + currentAmbience);
	
	if (time >= next_soundscape)
	{
		switch (currentAmbience)
		{
			case world_ambient_day:
				changeSoundscape(mixer, soundscape_world_day, 1.0f, 3.0f);
				next_soundscape = time + (150 + XORRandom(300));
			break;
		
			case world_ambient_night:
				changeSoundscape(mixer, soundscape_world_night, 1.0f, 3.0f);
				next_soundscape = time + (150 + XORRandom(300));
			break;
			
			case world_ambient_underground:
				changeSoundscape(mixer, soundscape_world_underground, 1.0f, 3.0f);
				next_soundscape = time + (150 + XORRandom(300));
			break;
			
			case world_ambient_mountain:
				changeSoundscape(mixer, soundscape_world_mountain, 1.0f, 3.0f);
				next_soundscape = time + (150 + XORRandom(450));
			break;
			
			case world_ambient_upf_city:
				changeSoundscape(mixer, soundscape_upf_city, 1.0f, 3.0f);
				next_soundscape = time + (60 + XORRandom(100));
			break;
		
			case world_ambient_upf_base:
				changeSoundscape(mixer, soundscape_upf_base, 1.0f, 3.0f);
				next_soundscape = time + (150 + XORRandom(150));
			break;
			
			case world_ambient_upf_bunker:
				changeSoundscape(mixer, soundscape_upf_bunker, 1.0f, 3.0f);
				next_soundscape = time + (90 + XORRandom(150));
			break;
			
			case world_ambient_faction:
				changeSoundscape(mixer, soundscape_faction, 1.0f, 3.0f);
				next_soundscape = time + (150 + XORRandom(200));
			break;
			
			default:
				changeSoundscape(mixer, soundscape_world_day, 1.0f, 3.0f);
				next_soundscape = time + (150 + XORRandom(400));
				print("play soundscape");
			break;
		}
		
	}
}

u32 playingMusic(CMixer@ mixer)
{
	u32 count = 0;
	for (u32 i = world_music_start + 1; i < world_music_end; i++) count += mixer.isPlaying(i) ? 1 : 0;

	return count;
}

void changeMusic(CMixer@ mixer, GameMusicTag nextTrack, f32 fadeoutTime = 0.0f, f32 fadeinTime = 0.0f)
{
	if (!mixer.isPlaying(nextTrack))
	{
		for (u32 i = world_music_start + 1; i < world_music_end; i++) mixer.FadeOut(i, fadeoutTime);
	}

	mixer.FadeInRandom(nextTrack, fadeinTime);
}

void changeAmbience(CMixer@ mixer, GameMusicTag nextTrack, f32 fadeoutTime = 0.0f, f32 fadeinTime = 0.0f)
{
	// if (nextTrack != currentAmbience) print("Changed ambience from " + currentAmbience + " to " + nextTrack);

	if (!mixer.isPlaying(nextTrack))
	{
		for (u32 i = world_ambient_start + 1; i < world_ambient_end; i++) mixer.FadeOut(i, fadeoutTime);
	}

	currentAmbience = nextTrack;
	mixer.FadeInRandom(nextTrack, fadeinTime);
}

void changeSoundscape(CMixer@ mixer, GameMusicTag nextTrack, f32 fadeoutTime = 0.0f, f32 fadeinTime = 0.0f)
{
	if (!mixer.isPlaying(nextTrack))
	{
		for (u32 i = world_soundscape_start + 1; i < world_soundscape_end; i++) mixer.FadeOut(i, fadeoutTime);
	}

	mixer.FadeInRandom(nextTrack, fadeinTime);
}