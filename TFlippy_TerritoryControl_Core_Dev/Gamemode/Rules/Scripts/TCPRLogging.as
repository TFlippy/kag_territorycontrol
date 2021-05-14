// This is used in the production server.
// Can help with performance in a few **rare** cases.

// Source code for external app listening to this will be posted some day.
// Data is mostly used for alt logging, debug logging and every now and then for some cool stats (like how many unique players joined).
// We may let users opt out in the future

// KEYS for tcpr logs

// [BDC] - Blob Does Collide
// [BDI] - Blob Dropped Item
// [BOC] - Blob On Collision
// [BPL] - Blob Print Log
// [BPU] - Blob Picked Up
// [BTC] - Blob Team Change
// [CCC] - Current Chicken Chance
// [DEBUG] - DEBUG SOME DUMB INFO FOR DUMB BUGS
// [MISC] - Other info
// [NBD] - New Blob Death
// [NBM] - New Blob Made
// [NPJ] - New Player Joined
// [NPL] - New Player Left
// [PBI] - Player Brought Item
// [PC]  - Player Chat
// [PDB] - Player Died by
// [PDI] - Player Dropped Item
// [PJT] - Player Joined Team
// [PPL] - Player Print Log
// [PPU] - Player Picked Up
// [RGE] - Random Game Event

// SPECIAL

// [R_STAT] - Responding to server status requests from Razi

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

