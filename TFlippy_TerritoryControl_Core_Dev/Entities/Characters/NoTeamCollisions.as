
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return ((this.getTeamNum() != blob.getTeamNum() || (this.getTeamNum()<0 || this.getTeamNum()>=7)) || (blob.getShape().isStatic() && !blob.getShape().getConsts().platform));
}