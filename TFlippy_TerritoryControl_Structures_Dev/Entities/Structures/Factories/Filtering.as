
void onInit(CBlob@ this){
	this.Tag("filter");
	//this.set_Vec2f("filter_button_pos",Vec2f(0,0));
	
	string[] filter;
	this.set("filtered_items", @filter);
	
	this.addCommandID("add_filter_item");
	this.addCommandID("remove_filter_item");
	this.addCommandID("inspect_filter");
	this.addCommandID("send_filter");
	this.addCommandID("swap_list_type");
	
	this.Tag("whitelist");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.getDistanceTo(caller) > 12)return;
	if(this.isAttached())return;
	
	Vec2f buttonPos;
	if(this.exists("filter_button_pos"))buttonPos = this.get_Vec2f("filter_button_pos");

	CBlob@ carried = caller.getCarriedBlob();
	if (carried !is null){
		if(carried.getName() != "gyromat" && carried.getName() != "wrench"){
			u16 carried_netid = carried.getNetworkID();

			CBitStream params;
			params.write_u16(carried_netid);

			caller.CreateGenericButton("$icon_filter_add$", buttonPos, this, this.getCommandID("add_filter_item"), "Add to Filter", params);
		}
	} else {
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		caller.CreateGenericButton("$icon_filter_inspect$", buttonPos, this, this.getCommandID("inspect_filter"), "Inspect Filter", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params){
	if (cmd == this.getCommandID("add_filter_item"))
	{
		CBlob@ carried = getBlobByNetworkID(params.read_u16());

		//if(isServer())
		if (carried !is null){
			string[]@ filter;
			if(this.get("filtered_items", @filter)){
				bool has = false;
				for(int i = 0;i < filter.length();i++)if(filter[i] == carried.getConfig()){has = true;break;}
				if(!has)filter.push_back(carried.getConfig());
				this.set("filtered_items", @filter);
			}
		}
	}
	
	if (cmd == this.getCommandID("remove_filter_item"))
	{
		int index = params.read_u8();

		//if(isServer())
		{
			string[]@ filter;
			if(this.get("filtered_items", @filter)){
				filter.removeAt(index);
				this.set("filtered_items", @filter);
			}
		}
	}
	
	if (cmd == this.getCommandID("inspect_filter"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());

		if(isServer()){
			string[]@ filter;
			if(this.get("filtered_items", @filter)){
				CBitStream params;
				params.write_u16(caller.getNetworkID());
				params.write_u8(filter.length());
				for(int i = 0;i < filter.length();i++)params.write_string(filter[i]);
				
				this.SendCommand(this.getCommandID("send_filter"), params);
			}
		}
	}
	
	if (cmd == this.getCommandID("swap_list_type"))
	{
		if(isServer()){
			this.set_bool("whitelist",!this.get_bool("whitelist"));
			this.Sync("whitelist",true);
		}
	}
	
	if (cmd == this.getCommandID("send_filter"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		int length = params.read_u8();
		string[] filter;
		for(int i = 0;i < length;i++)filter.push_back(params.read_string());
		this.set("filtered_items", @filter);
		
		if(caller !is null)
		if(caller.isMyPlayer())
		{
			CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos(), this, Vec2f(1, length+1), this.hasTag("whitelist") ? "Whitelist" : "Blacklist");
			
			if (menu !is null){
				for(int i = 0;i < length;i++){
					CBitStream params;
					params.write_u8(i);
					menu.AddButton("$"+filter[i]+"$", "Remove", this.getCommandID("remove_filter_item"), Vec2f(1,1),params);
				}
				menu.AddButton(this.hasTag("whitelist") ? "$icon_whitelist$" : "$icon_blacklist$", "Swap list type", this.getCommandID("swap_list_type"), Vec2f(1,1));
			}
		}
	}
}
