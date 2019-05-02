//Made by vamist

const string clan_configstr   = "../Cache/TC/ClanPlayerList.cfg";
Clans clan;

void onInit(CRules@ this)
{
    if(isServer())
    {
        clan = Clans();
        clan.UpdateClanList(this);
    }
}

void onRestart(CRules@ this)
{
    if(isServer())
    {   
        clan.UpdateClanList(this);
    }
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
    if(isServer())
    {
        if(player !is null)
        {
            clan.userClanCheck(this,player,player.getUsername().toLower());
        }
        for(int a = 0; a < getPlayerCount(); a++)
        {
            CPlayer@ p = getPlayer(a);
            if(p !is null)
            {
                if(this.exists("clanData"+p.getUsername().toLower()))
                {
                    this.SyncToPlayer("clanData"+p.getUsername().toLower(),player);
                }
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
    void userClanCheck(CRules@ this,CPlayer@ player, string userName)
    {
        print("checking!");
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
            print("p a s s s");
            this.set_string("clanData"+userName,"Bucket Brotherhood");
            this.Sync("clanData"+userName,true);
        }
        else if(LuxList.find(userName) != -1)
        {
            print("bad");
            this.set_string("clanData"+userName,"Metalon");
            this.Sync("clanData"+userName,true);
        }
        else if(TclfList.find(userName) != -1)
        {
            print("meh");
            this.set_string("clanData"+userName,"TC Liberation Front");
            this.Sync("clanData"+userName,true);
        }
        else if(darkList.find(userName) != -1)
        {
            print("no pls");
            this.set_string("clanData"+userName,"DARK");
            this.Sync("clanData"+userName,true);
        }
        else if(ivanList.find(userName) != -1)
        {
            print("ok");
            this.set_string("clanData"+userName,"Invanists United");
            this.Sync("clanData"+userName,true);
        }
        else if(spekList.find(userName) != -1)
        {
            print("hello world!");
            this.set_string("clanData"+userName,"Sepulka");
            this.Sync("clanData"+userName,true);
        }
        else
        {
            print("not found in any!");
        }

    }

    string returnStringList(string clanName)
    {
        //Assuming the file is already made on the server (It is, unless its rehosted)
        ConfigFile clan_cfg = ConfigFile(clan_configstr);

        return clan_cfg.read_string(clanName);
    }

}