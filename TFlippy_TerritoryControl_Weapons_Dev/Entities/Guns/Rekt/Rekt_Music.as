
void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	CSprite@ sprite = attached.getSprite();
	sprite.RewindEmitSound();
	sprite.SetEmitSound("Rekt_Music");
	sprite.SetEmitSoundSpeed(1);
	sprite.SetEmitSoundVolume(2);
	sprite.SetEmitSoundPaused(false);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint)
{
	CSprite@ sprite = detached.getSprite();
	sprite.RewindEmitSound();
	sprite.SetEmitSound("");
	sprite.SetEmitSoundSpeed(1);
	sprite.SetEmitSoundVolume(1);
	sprite.SetEmitSoundPaused(true);
}