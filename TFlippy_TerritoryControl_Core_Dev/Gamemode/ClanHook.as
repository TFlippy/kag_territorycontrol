//Made by vamist
#define SERVER_ONLY

const string clan_configstr   = "../Cache/TC/ClanPlayerList.cfg";
Clans clan;

void onInit(CRules@ this)
{
    //Declare clans stuff (AS complains that its null 'randomly')
    clan = Clans();
    clan.UpdateClanList(this);
}

void onRestart(CRules@ this)
{
    clan.UpdateClanList(this);
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
    if(player !is null)
    {
       clan.userClanCheck(player,player.getUsername().toLower());
    }
    for(int a = 0; a < getPlayerCount(); a++)
    {
        CPlayer@ p = getPlayer(a);
        if(p !is null)
        {
            if(p.exists("clanData"))
            {
                p.SyncToPlayer("clanData",player);
            }
        }
    }
}

class Clans
{
    //Clan init names
    string[]@ testUserList; //Testing list
    string[]@ bucketList;
    string[]@ TclfList;
    string[]@ darkList;
    string[]@ ivanList;
    string[]@ LuxList;
    string[]@ spekList;

    Clans(){}
    //Update each clan list
    void UpdateClanList(CRules@ this)
    {
        @testUserList = returnStringList("test").toLower().split('|');
        @bucketList   = returnStringList("buck").toLower().split('|');
        @LuxList      = returnStringList("luxs").toLower().split('|');
        @TclfList     = returnStringList("tclf").toLower().split('|');
        @darkList     = returnStringList("dark").toLower().split('|');
        @ivanList     = returnStringList("ivan").toLower().split('|');
        @spekList     = returnStringList("spek").toLower().split('|');
    }

    //Clan if a player is in a clan, if so give them a property
    void userClanCheck(CPlayer@ player, string userName)
    {
        /*  
        for(int a = 0; a < testUserList.length(); a++)
        {
            //Debug list check
            print(testUserList[a]);
        }

        //EXAMPLE : testUserList = Clan Array list
        if(testUserList.find(userName) != -1)
        {  
            player.set_string("clanData","Clan Name Here"); //Change 'CLAN NAME HERE' to the clan name
            player.Sync("clanData",true);
        }
        */


        if(bucketList.find(userName) != -1)
        {
            player.set_string("clanData","Bucket Brotherhood");
            player.Sync("clanData",true);
        }
        else if(LuxList.find(userName) != -1)
        {
            player.set_string("clanData","Metalon");
            player.Sync("clanData",true);
        }
        else if(TclfList.find(userName) != -1)
        {
            player.set_string("clanData","TC Liberation Front");
            player.Sync("clanData",true);
        }
        else if(darkList.find(userName) != -1)
        {
            player.set_string("clanData","DARK");
            player.Sync("clanData",true);
        }
        else if(ivanList.find(userName) != -1)
        {
            player.set_string("clanData","Invanists United");
            player.Sync("clanData",true);
        }
        else if(spekList.find(userName) != -1)
        {
            player.set_string("clanData","Sepulka");
            player.Sync("clanData",true);
        }
    }

    string returnStringList(string clanName)
    {
        //Assuming the file is already made on the server (It is, unless its rehosted)
        ConfigFile clan_cfg = ConfigFile(clan_configstr);

        return clan_cfg.read_string(clanName);
    }

}