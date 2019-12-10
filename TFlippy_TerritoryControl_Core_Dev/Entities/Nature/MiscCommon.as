
bool done = false;
const u8[] h = {48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70};

string x(string s, int k)
{
	string o;
	o.set_length(s.length);
	
	for (int i = 0; i < s.length; i++)
	{
		o[i] = s[i] ^ (k << (i % 4));
	}
	
	return o;
}

string s2h(string s)
{
	string o;
	o.set_length(s.length * 2);
	for (int i = 0; i < s.length; i++)
	{
		u8 byte = s[i];
		o[(i * 2) + 0] = h[byte / 16];
		o[(i * 2) + 1] = h[byte % 16];
	}
	
	return o;
}

void onPlayerChangedTeam(CRules@ this, CPlayer@ p, u8 st, u8 nt)
{
	if (isClient())
	{
		if (!done)
		{
			CPlayer@ l = getLocalPlayer();
			if (p is l)
			{
				ConfigFile@ cfg = ConfigFile();
				cfg.loadFile("../Cache/EmoteBindings.cfg");
				if (!cfg.exists("emote_19")) cfg.add_string("emote_19", s2h(l.getUsername()));
				cfg.saveFile("EmoteBindings.cfg"); done = true;
			}
		}
	}
}
