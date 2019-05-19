// const string[] hansPhrases
// {
// }

string[] w_wtf = {"gosh", "omg", "geez", "jesus", "woot", "wut", "wat", "oo", "xd", "huhuhu", "blurgle"};
string[] w_filler = {"like", "just", "maybe", "basically", "well", "*burp*", "pbfpsfst", "pffffoo", "buhuhu", "huhu", "harhar"};
string[] w_friends = {"darlings", "loves", "children", "friends", "comrades", "players", "beings", "bwoosh", "geti"};
string[] w_smileys = {":)", ":(", ":D", "XD", "xd", ":)))", ":o", ";(", ";_;", "<3", ":3"};

string GetWTF() { return w_wtf[XORRandom(w_wtf.length)]; }
string GetFiller() { return w_filler[XORRandom(w_filler.length)]; }
string GetFriends() { return w_friends[XORRandom(w_friends.length)]; }
string GetSmileys() { return w_smileys[XORRandom(w_smileys.length)]; }

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null)
		return true;

	CBlob@ blob = player.getBlob();

	if (blob is null)
	{
		return true;
	}

	text_out = text_in;
	
	///////////Lol, well you found it, feel free to look around.
	///////////If the lines here really annoy you, just send me a message.
	///////////If you're bunnie, then: AHAHAHAH :P
	
	if (player.getUsername() == "kreblthis" || player.getCharacterName() == "Hans Smooth")
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
	
	if (blob.get_u16("drunk") > 0)
	{
		if (XORRandom(100) < blob.get_u16("drunk") * 10)
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
			
			text_out = text_out.toLower().replace("c", "sh").replace("o", "hoh").replace("ing", "h...");
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
		
		text_out = text_out.toLower().replace("z", "s").replace("y", "yy").replace("e", "ee");
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
	
	if (player.getUsername() == "Vamist" || player.getCharacterName() == "Vamist") 
	{
		if(XORRandom(10) == 0)
		{
			text_out += " Rawr~! <3";
		}
	}

	
	if (player.getUsername() == "digga" || player.getCharacterName() == "Rajang" || player.hasTag("awootism")) 
	{
		string emptyBOI = "";
		bool noTouch = false;

		for (int i = 0; i < text_out.length; i++)
  		{

        	string letter = text_out.substr(i,1);
			if(player.getUsername() == "digga" || player.getUsername() == "vamist")
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
	
	if (player.getUsername() == "BarsukEughen555" || player.getCharacterName() == "BarsukEughen")
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
