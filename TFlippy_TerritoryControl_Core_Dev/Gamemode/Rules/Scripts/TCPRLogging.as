#define SERVER_ONLY

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    tcpr("[LOG] Player joined-> Username: " +
        player.getUsername() +
        " | Char name: " +
        player.getCharacterName() +
        " | IP: " + 
        player.server_getIP() +
        " | HWID: " +
        player.server_getHWID()
    );
}

void onPlayerLeave(CRules@ this, CPlayer@ player) 
{
    tcpr("[LOG] Player left-> Username: " + player.getUsername());
}

bool onServerProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player) {
    tcpr("[LOG] " + player.getUsername() + ": " + textIn);
    return true;
}

