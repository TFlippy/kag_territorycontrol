
void onInit(CBlob@ this)
{
  this.maxQuantity = 52;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
