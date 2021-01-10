// This is used in the production server.
// Can help with performance in a few **rare** cases.

// Source code for external app listening to this will be posted some day.
// Data is mostly used for alt logging, debug logging and every now and then for some cool stats (like how many unique players joined).
// We may let users opt out in the future


#define SERVER_ONLY

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    tcpr("[NPJ] Username: " +
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
    tcpr("[NPL] Player left-> Username: " + player.getUsername());
}

bool onServerProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player) {
    tcpr("[PC] " + player.getUsername() + ": " + textIn);
    return true;
}

