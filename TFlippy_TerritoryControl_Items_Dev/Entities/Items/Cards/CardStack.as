
#include "Hitters.as";
#include "BuilderHittable.as";
#include "Knocked.as";
 
const string[] types =
{
    "death_cards",
    "holy_cards",
    "nature_cards",
    "water_cards",
    "fire_cards",
    "cog_cards",
    "steam_cards",
    "mine_cards"   
};
 
void onInit(CBlob@ this)
{
    AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
    if (ap !is null)
    {
        ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
    }
    this.set_u8("type",0);
   
    this.maxQuantity = 50;
    this.server_SetQuantity(1);
}
 
void onTick(CBlob@ this)
{
    CSprite@ sprite = this.getSprite();
   
    if (this.isAttached())
    {
        this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping);
        AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
        CBlob@ holder = point.getOccupied();
 
        if (holder is null) return;
 
        this.getShape().SetRotationsAllowed(false);
 
        if (point.isKeyJustPressed(key_action1) || getKnocked(holder) > 0)
        if(isServer()){
            CBlob @blob = server_CreateBlob("card", holder.getTeamNum(), this.getPosition());
            if (blob !is null)
            {
                Vec2f shootVel = holder.getAimPos()-this.getPosition();
                shootVel.Normalize();
                blob.setVelocity(shootVel*7);
                blob.SetDamageOwnerPlayer(holder.getPlayer());
                blob.set_u8("type", GetCardType(this));
            }
            this.server_SetQuantity(this.getQuantity()-1);
            if(this.getQuantity() <= 0)this.server_Die();
        }
    }
    else
    {
        this.getShape().SetRotationsAllowed(true);
    }
}
 
u8 GetCardType(CBlob@ this)
{
    string name = this.getName();
    for (u8 i = 0; i < types.length; i++)if (name == types[i]) return i;
    return XORRandom(types.length);
}
 
void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
    this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
}