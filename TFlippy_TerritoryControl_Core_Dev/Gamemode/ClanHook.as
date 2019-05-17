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
    string[]@ spekList;
    string[]@ scpList;

    Clans(){}
    //Update each clan list
    void UpdateClanList(CRules@ this)
    {
        @spekList     = returnStringList("spek").toLower().split('|');
        @scpList      = returnStringList("scp").toLower().split('|');
    }

    //Clan if a player is in a clan, if so give them a property
    void userClanCheck(CRules@ this,CPlayer@ player, string userName)
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

        if(spekList.find(userName) != -1)
        {
            this.set_string("clanData"+userName,"Sepulka");
            this.Sync("clanData"+userName,true);
        }
        else if(scpList.find(userName) != -1)
        {
            this.set_string("clanData"+userName,"SCP");
            this.Sync("clanData"+userName,true);
        }

    }

    string returnStringList(string clanName)
    {
        //Assuming the file is already made on the server (It is, unless its rehosted)
        ConfigFile clan_cfg = ConfigFile(clan_configstr);

        return clan_cfg.read_string(clanName);
    }

}