// OneClassAvailable.as

#include "StandardRespawnCommand.as";

const string req_class = "required class";
const string req_tag = "required tag";

void onInit(CBlob@ this)
{
	AddIconToken("$change_class$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);

	this.Tag("change class drop inventory");
	if(!this.exists("class offset"))
		this.set_Vec2f("class offset", Vec2f_zero);

	if(!this.exists("class button radius"))
	{
		CShape@ shape = this.getShape();
		if(shape !is null)
		{
			this.set_u8("class button radius", Maths::Max(this.getRadius(), (shape.getWidth() + shape.getHeight())));
		}
		else
		{
			this.set_u8("class button radius", 16);
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(!this.exists(req_class))
	{
		return;
	}

	bool CanChange = true;
	
	if(this.exists(req_tag)){
		if(!caller.hasTag(this.get_string(req_tag)))CanChange = false;
	}

	string cfg = this.get_string(req_class);
	if (canChangeClass(this, caller) && caller.getName() != cfg && CanChange)
	{
		CBitStream params;
		write_classchange(params, caller.getNetworkID(), cfg);

		CButton@ button = caller.CreateGenericButton(
		"$change_class$",                           // icon token
		this.get_Vec2f("class offset"),             // button offset
		this,                                       // button attachment
		SpawnCmd::changeClass,                      // command id
		"Swap Class",                               // description
		params);                                    // bit stream

		button.enableRadius = this.get_u8("class button radius");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (this.hasTag("dead")) return;

	onRespawnCommand(this, cmd, params);

	if (this.hasTag("kill on use"))
	{
		this.Tag("dead");

		if (isServer()) 
		{
			this.server_Die();
		}
	}
}
