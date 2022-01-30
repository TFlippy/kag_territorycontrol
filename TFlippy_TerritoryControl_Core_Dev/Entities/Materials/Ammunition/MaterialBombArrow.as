
#define SERVER_ONLY

void onInit(CBlob@ this)
{
  this.set_u16('decay time', 150);

  this.maxQuantity = 4;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
