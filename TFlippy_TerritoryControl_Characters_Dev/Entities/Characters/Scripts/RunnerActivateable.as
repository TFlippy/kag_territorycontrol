void onInit(CBlob@ this)
{
	//these don't actually use it, they take the controls away
	this.push("names to activate", "jackolantern");
	this.push("names to activate", "lantern");
	this.push("names to activate", "mat_smokegrenade");
	this.push("names to activate", "mat_dynamite");
	this.push("names to activate", "mat_fraggrenade");
	this.push("names to activate", "mat_flashgrenade");
	this.push("names to activate", "mat_molotov");
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
