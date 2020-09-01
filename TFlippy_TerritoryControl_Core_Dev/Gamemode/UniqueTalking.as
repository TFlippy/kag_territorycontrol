// const string[] hansPhrases
// {
// }

string[] w_wtf = {"gosh", "omg", "geez", "jesus", "woot", "wut", "wat", "oo", "xd", "huhuhu", "blurgle"};
string[] w_filler = {"like", "just", "maybe", "basically", "well", "*burp*", "pbfpsfst", "pffffoo", "buhuhu", "huhu", "harhar"};
string[] w_friends = {"darlings", "loves", "children", "friends", "comrades", "players", "beings", "bwoosh", "geti"};
string[] w_smileys = {":)", ":(", ":D", "XD", "xd", ":)))", ":o", ";(", ";_;", "<3", ":3"};
string[] w_expletives = {"fuck", "shit", "cock", "shite", "fuc", "fug", "bugger", "feck", "piss"};

string GetWTF() { return w_wtf[XORRandom(w_wtf.length)]; }
string GetFiller() { return w_filler[XORRandom(w_filler.length)]; }
string GetFriends() { return w_friends[XORRandom(w_friends.length)]; }
string GetSmileys() { return w_smileys[XORRandom(w_smileys.length)]; }
string GetExpletive() { return w_expletives[XORRandom(w_expletives.length)]; }

bool onClientProcessChat(CRules@ this, const string &in text_in, string &out text_out, CPlayer@ player)
{
	text_out = text_in;
	
	CPlayer@ localPlayer = getLocalPlayer();
	CBlob@ localBlob = getLocalPlayerBlob();


	if (XORRandom(10) == 0 && localPlayer !is player && localBlob !is null && localPlayer !is null && localBlob.hasTag("schisked"))
	{
		string playerName = localPlayer.getCharacterName();
	
		// text_out = text_out.replace("you", playerName).replace("are", "is").replace(" she", playerName).replace(" he", playerName);

		switch(XORRandom(10))
		{
			case 0:
			{
				text_out = playerName + ", " + text_out + ".";
			}
			break;
			
			case 1:
			{
				text_out = text_out + ". What do you say, " + playerName + "?";
			}
			break;
			
			case 2:
			{
				text_out = text_out + "??? What the fuck, " + playerName + "?";
			}
			break;
			
			case 3:
			{
				text_out = "\"" + text_out + "\", are you fucking kidding me, " + playerName + "?";
			}
			break;
			
			case 4:
			{
				text_out = "\"" + text_out + "\", are you fucking kidding me, " + playerName + "?";
			}
			break;
			
			case 5:
			{
				text_out = playerName + " said " + text_out;
			}
			break;
			
			case 6:
			{
				text_out = text_out + ", just like " + playerName;
			}
			break;
			
			case 7:
			{
				text_out = (playerName + "!!! " + text_out).toUpper();
			}
			break;
			
			case 8:
			{
				text_out = text_out + " " + playerName;
			}
			break;
			
			case 9:
			{
				text_out = text_out + ", except for " + playerName;
			}
			break;
			
			default:
			{
				text_out = playerName + ", " + text_out + ".";
			}
			break;
		}
	}
	
	if (player !is null)
	{
		CBlob@ senderBlob = player.getBlob();
		if (senderBlob !is null)
		{
			if (senderBlob !is localBlob && senderBlob.hasTag("schisked"))
			{	
				int total_len = text_out.size();
				int pos = XORRandom(total_len / 2);
				string result = "";
				
				for (int i = 0; i < 3 && pos < total_len; i++)
				{
					int len = XORRandom(total_len - pos);
					string segment = text_out.substr(pos, len);
				
					if (XORRandom(3) == 0) segment = segment.toUpper();
					
					result += segment;
					pos += len;
				}
			
				text_out = result;
			}
		}
	}	
	
	return true;
}

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null) return true;
	CBlob@ blob = player.getBlob();

	if (blob is null)
	{
		return true;
	}

	text_out = text_in;

	string username = player.getUsername();
	string charname = player.getCharacterName();
	
	///////////Lol, well you found it, feel free to look around.
	///////////If the lines here really annoy you, just send me a message.
	///////////If you're bunnie, then: AHAHAHAH :P
	
	if (username == "kreblthis" || charname == "Hans Smooth")
	{
		if (XORRandom(100) < 20)
		{
			switch(XORRandom(16))
			{
				case 0:
					text_out = "\"" + text_out + "\", said the badger";
					break;
					
				case 1:
					text_out += " seriously we need to stop the hatred";
					break;
					
				case 2:
					text_out += " and kick me if you dare yo";
					break;
					
				case 3:
					text_out += " or not???";
					break;
					
				case 4:
					text_out += ", my comrades";
					break;
					
				case 5:
					text_out += " save the refugees";
					break;
					
				case 6:
					text_out += ", marx will rise again";
					break;
			
				case 7:
					text_out += "... im sorry :(";
					break;
					
				case 8:
					text_out += " and praise jesus";
					break;
					
				case 9:
					text_out += " hail mary";
					break;
				
				case 10:
					text_out += " we're all equal";
					break;
					
				case 11:
					text_out += " ok?";
					break;	
					
				case 12:
					text_out = GetFriends() + ", together, we will " + text_out + " and everyone will be happy! " + GetSmileys();
					break;	
					
				case 13:
					text_out += " no offense " + GetSmileys();
					break;

				case 14:
					text_out += " woof woof " + GetSmileys();
					break;	

				case 15:
					text_out = GetFriends() + ", boing!!!!!! " + GetSmileys();
					break;						
					
				default:
					break;
			}
		
			text_out = text_out.toLower();
		}
	}
	
	if (blob.get_f32("drunk_effect") > 0)
	{
		if (XORRandom(100) < blob.get_f32("drunk_effect") * 10)
		{
			switch(XORRandom(13))
			{
				case 0:
					text_out += "... hic!";
					break;
					
				case 1:
					text_out += ". jk " + GetSmileys();
					break;
					
				case 2:
					text_out = "my " + GetFriends() + ", " + text_out + "!";
					break;
					
				case 3:
					text_out += " yesterday";
					break;
					
				case 4:
					text_out = GetFiller() + " " + text_out + " " + GetSmileys();
					break;
					
				case 5:
					text_out = GetWTF() + ", like just " + text_out;
					break;
					
				case 6:
					text_out = "shouldn't we " + GetFiller() + " " + text_out + "? " + GetSmileys();
					break;
			
				case 7:
					text_out += " just " + GetFiller() + " like gregor_builder";
					break;
					
				case 8:
					text_out += " pffffut " + GetSmileys();
					break;
					
				case 9:
					text_out += " rofl";
					break;
				
				case 10:
					text_out += " " + GetSmileys();
					break;
					
				case 11:
					text_out += " belugh?";
					break;	
					
				case 12:
					text_out = GetFiller() + " if we " + text_out + ", nobodsy can stop us " + GetSmileys();
					break;	
					
				default:
					break;
			}
			
			text_out = text_out.toLower().replace("c", "sh").replace("ing", "h...");
			text_out = tempReplace("o", "hoh",text_out);
		}
	}
	
	if (blob.get_f32("babbyed") > 0)
	{
		switch(XORRandom(13))
		{
			case 0:
				text_out += GetSmileys();
				break;
				
			case 1:
				text_out += " yay " + GetSmileys();
				break;
				
			case 2:
				text_out = "my " + GetFriends() + ", " + text_out + "!";
				break;
				
			case 3:
				text_out += " thanks!";
				break;
				
			case 4:
				text_out = GetSmileys() + " " + text_out + " " + GetSmileys();
				break;
				
			case 5:
				text_out = GetSmileys() + " ooooo " + text_out;
				break;
				
			case 6:
				text_out = "please " + GetSmileys() + " " + text_out + "? " + GetSmileys();
				break;
		
			case 7:
				text_out += " hehehehe";
				break;
				
			case 8:
				text_out += " thaaank " + GetSmileys();
				break;
				
			case 9:
				text_out += " yay";
				break;
			
			case 10:
				text_out += " " + GetSmileys();
				break;
				
			case 11:
				text_out += "!!!!!";
				break;	
				
			case 12:
				text_out = " hey everyone " + text_out + "!!!" + GetSmileys();
				break;	
				
			default:
				break;
		}
		
		text_out = text_out.toLower().replace("z", "s");
		text_out = tempReplace("y", "yy",text_out);
		text_out = tempReplace("e", "ee",text_out);
	}
	
	if (blob.get_f32("crak_effect") > 0)
	{
		switch(XORRandom(8))
		{
			case 0:
				if (XORRandom(4) == 0) text_out += " :DDDD";
				break;
				
			case 1:
				if (XORRandom(5) == 0) text_out += " OH " + GetExpletive() + " MY TEETH!";
				break;
				
			case 2:
				if (XORRandom(2) == 0) text_out += " " + text_out;
				break;
				
			case 3:
				if (XORRandom(4) == 0) text_out += " AAAA";
				break;
				
			case 4:
				if (XORRandom(3) == 0) text_out = "EEEE " + text_out; 
				break;
				
			case 5:
				if (XORRandom(2) == 0) text_out += " HHHHHHH";
				break;
		
			case 6:
				text_out += " " + GetExpletive();
				break;
				
			case 7:
				if (XORRandom(4) == 0) text_out = "HOLY " + GetExpletive();
				break;
				
			default:
				break;
		}
		
		// text_out = text_out.toLower();
		// text_out = text_out.replace("th", "f");
		// text_out = text_out.replace("t's", "f");
		// text_out = text_out.replace("z", "f");
		// text_out = text_out.replace("s", "f");
		// text_out = text_out.replace("g", "f");
		// text_out = text_out.replace("l", "w");
		// text_out = text_out.replace("c", "f");
		// text_out = text_out.replace("k", "f");
		// text_out = text_out.replace("t", "f");
		// text_out = text_out.replace("r", "w");
	
		// // Broken Dementia
		// int total_len = text_out.size();
		// int pos = XORRandom(total_len / 2);
		// string result = "";
		
		// for (int i = 0; i < 3 && pos < total_len; i++)
		// {
			// int len = XORRandom(total_len - pos);
			// string segment = text_out.substr(pos, len);
		
			// if (XORRandom(3) == 0) segment = segment.toUpper();
			
			// result += segment;
		// }
		// text_out = result;
	
		// if (text_out.find("!") > 0)
		// {
			// text_out = text_out.toUpper();
		// }
		
		// // Dementia
		// int total_len = text_out.size();
		// int pos = XORRandom(total_len / 2);
		// string result = "";
		
		// for (int i = 0; i < 3 && pos < total_len; i++)
		// {
			// int len = XORRandom(total_len - pos);
			// string segment = text_out.substr(pos, len);
		
			// if (XORRandom(3) == 0) segment = segment.toUpper();
			
			// result += segment;
			// pos += len;
		// }
	
		// text_out = result;
		
		int total_len = text_out.size();
		int pos = 0;
		string result = "";
		
		for (int i = 0; i < 10 && pos < total_len; i++)
		{
			int len = 1 + XORRandom(total_len - pos);
			string segment = text_out.substr(pos - (1 - XORRandom(2)), len);
		
			if (XORRandom(3) == 0) segment = segment.toUpper();
			
			result += segment;
			pos += len;
		}
	
		text_out = result;
	}
	
	f32 stim = blob.get_f32("stimed");
	if (stim > 0)
	{		
		text_out = text_out.toUpper();
		for (s32 i = 0; i < stim; i++)
		{
			text_out += '!';
		}
	}
	
	if (username == "Vamist" || charname == "Vamist") 
	{
		if(XORRandom(100) == 0)
		{
			text_out += " Rawr~! <3";
		}
	}

	// if (player.getUsername() == "TFlippy" || player.getCharacterName() == "TFlippy")
	// {
		// if (XORRandom(100) < 5)
		// {
			// switch(XORRandom(9))
			// {
				// case 0:
				// {
					// text_out = "its a mystery";
				// }
				// break;
				
				// case 1:
				// {
					// text_out = "rip";
				// }
				// break;
				
				// case 2:
				// {
					// text_out = "ripi";
				// }
				// break;
				
				// case 3:
				// {
					// text_out = "hi";
				// }
				// break;
				
				// case 4:
				// {
					// text_out = "yus";
				// }
				// break;
				
				// case 5:
				// {
					// text_out = "mystery";
				// }
				// break;
				
				// case 6:
				// {
					// text_out = "rup";
				// }
				// break;
				
				// case 7:
				// {
					// text_out = "such is life";
				// }
				// break;

				// case 8:
				// {
					// text_out = "snif";
				// }
				// break;
			// }
		// }
	// }
	
	if (username ==  "digga" || charname == "Rajang" || player.hasTag("awootism")) 
	{
		string emptyBOI = "";
		bool noTouch = false;

		for (int i = 0; i < text_out.length; i++)
  		{

        	string letter = text_out.substr(i,1);
			if(username == "digga" || username == "vamist")
			{
				if(letter == '.')
				{
					noTouch = true;
					continue;
				}
			}
			if(!noTouch)
			{
				if(i == 0)
				{
					emptyBOI += letter;
					continue;
				}


				if(letter == 'r' || letter == 'R')
				{
					if(XORRandom(4) > 1)
					{
						emptyBOI += 'w';
					}
				}
				else if(letter == 'e' || letter == 'o' || letter == 'u')
				{
					if(XORRandom(1) == 0)
					{
						if(XORRandom(2) == 0)
						{
							emptyBOI += letter + 'w';
						}
						else
						{
							emptyBOI += 'w' + letter;
						}
					}
					else
					{
						emptyBOI += letter;
					}
				}
				else if(letter == 'E' || letter == 'O' || letter == 'U')
				{
					if(XORRandom(1) == 0)
					{
						if(XORRandom(2) == 0)
						{
							emptyBOI += letter + 'W';
						}
						else
						{
							emptyBOI += 'W' + letter;
						}
					}
					else
					{
						emptyBOI += letter;
					}
				}
				else
				{
					emptyBOI += letter;
				}
			}
			else
			{
				emptyBOI += letter;
			}
        }
        
		text_out = emptyBOI;

		if(XORRandom(5) > 2)
		{
			switch(XORRandom(6))
			{
				case 0: text_out += " UwU";
						break;

				case 1: text_out += " 0w0";
						break;

				case 2: text_out += "~";
						break;

				case 3: text_out += " fufu";
						break;

				case 4: text_out += " >w<";
						break;
				
				case 5: text_out += "U//w//U";
						break;
			}
		}
	}
	
	if (username == "BarsukEughen555" || charname == "BarsukEughen")
	{
		if (XORRandom(100) == 0)
		{
			if (XORRandom(2) == 0) text_out = "As we russians tend to say, " + text_out + "!";
			else text_out = "[Russians have been muted on this server]";
		}
	}
	
	// if( player.getUsername() == "TFlippy" || player.getCharacterName() == "TFlippy")if(XORRandom(100) == 0)text_out = "[If you have any problems using your TFlipppy9000, please consult your local Pirate-Rob.]";
	
	return true;
}


string tempReplace(string letterToFind, string toReplaceItWith, string context)
{
	string temp = "";
	for(int a = 0; a < context.length; a++)
	{
		string letter = context.substr(a,1);
		
		if(letter == letterToFind)
		{
			temp += toReplaceItWith;
		}
		else
		{
			temp += letter;
		}

	}
	return temp;
}