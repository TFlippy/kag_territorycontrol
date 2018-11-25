
//Clan mod. Each string is a clan, every reload/map change will update the strings.

const string kagdevs = "geti;mm;flieslikeabrick;furai;jrgp;";
const string tcdevs = "tflippy;pirate-rob;merser433;goldenguy;koi_;";
const string contributors = "cesar0;sylw;sjd360;mr_hobo;";
string clanDutch = "";
string clanSoviet = "";
string clanIrregular = "";
string clanTCoT = "";
string clanDARK = "";
string clanUFF = "";


const string usernamelist = "../Mods/TFlippy_TerritoryControl_Clans_v1f/Config/ClanInfo.cfg";//file location

void UpdateClanList()
{

	/*if(getRules().exists("clanconfig"))//checks if it exists (should do, unless you delete it once joined)
	{
		//usernamelist = getRules().get_string("clanconfig");//no clue what this does, forgot to test if it makes a diffrence
	}*/

	ConfigFile ClanUserList = ConfigFile(usernamelist);

	clanDutch = ClanUserList.read_string("Dutch_Republic");//gets name list
	clanSoviet = ClanUserList.read_string("Soviet_Union");
	clanIrregular = ClanUserList.read_string("Irregular_Militia");
	clanTCoT = ClanUserList.read_string("TCoT");
	clanDARK = ClanUserList.read_string("DARK");
	clanUFF = ClanUserList.read_string("UFF");
}

string getClan(CPlayer@ p) 
{
	string username = p.getUsername().toLower() + ";";

	if(clanDutch.find(username) != -1) return "Dutch Republic";//if name is not here, check next, if it is, return this
	else if(clanSoviet.find(username) != -1) return "Soviet Union";
	else if(clanIrregular.find(username) != -1) return "Irregular Militia";
	else if(clanTCoT.find(username) != -1) return "The Control of Territories";
	else if(clanDARK.find(username) != -1) return "DARK";
	else if(clanUFF.find(username) != -1) return "United Foghorn Federation";
	return "";
}

string getRank(CPlayer@ p, bool &out dev)
{
	string username = p.getUsername().toLower() + ";";
	string seclev = getSecurity().getPlayerSeclev(p).getName();
	dev = false;
	
	if (kagdevs.find(username) != -1) return "KAG Developer";
	else if (tcdevs.find(username) != -1)
	{	
		dev = true;
		return (username == "tflippy;" ? "Lead " : "") + "TC Developer";
	}
	else if (contributors.find(username) != -1) return "Contributor";
	else if (username == "vamist;") return "Glorious Server Host";
	else if (username == "mrhobo;") return "Clan Leader";
	else if (username == "turtlecake;") return "Clan Leader";
	else if (username == "rhysdavid299;") return "Clan Leader";
	else if (username == "agenthightower;") return "Clan Leader";
	else if (username == "blackguy123;") return "Clan Leader";
	else if (username == "mrpineapple;") return "Clan Leader";
	else if (seclev != "Normal") seclev;
	
	return "";
}