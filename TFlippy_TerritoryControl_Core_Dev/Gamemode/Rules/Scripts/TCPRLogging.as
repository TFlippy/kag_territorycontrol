void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    tcpr("[LOG] Player joined-> Username:" +
        player.getUsername() +
        " |Char name: " +
        player.getCharacterName() +
        " |IP: " + 
        player.server_getIP() +
        " |HWID: " +
        player.server_getHWID()
    );
}

bool onServerProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player) {
    tcpr("[LOG] " + player.getUsername() + ": " + textIn);
    return true;
}

