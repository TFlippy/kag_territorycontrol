
void onInit(CBlob@ this){
	this.addCommandID("load_gyromat");
	this.addCommandID("unload_gyromat");
	
	this.set_f32("gyromat_acceleration", 1.00f);
	//this.set_Vec2f("gyro_button_pos",Vec2f(0,0));
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	Vec2f buttonPos;
	if(this.exists("gyro_button_pos"))buttonPos = this.get_Vec2f("gyro_button_pos");

	CBlob@ carried = caller.getCarriedBlob();
	if (carried !is null){
		if(carried.getName() == "gyromat"){
		
			u16 carried_netid = carried.getNetworkID();

			CBitStream params;
			params.write_u16(carried_netid);

			caller.CreateGenericButton("$icon_gyromat$", buttonPos, this, this.getCommandID("load_gyromat"), "Install Gyromat.\nUse wrench to uninstall.", params);
		
		} else 
		if(carried.getName() == "wrench"){
			caller.CreateGenericButton("$icon_wrench$", buttonPos, this, this.getCommandID("unload_gyromat"), "Uninstall Gyromat.");
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params){
	if (cmd == this.getCommandID("load_gyromat"))
	{
		CBlob@ carried = getBlobByNetworkID(params.read_u16());

		if(isServer())
		if(carried !is null){
			if(this.get_f32("gyromat_acceleration") > 1){
				CBlob @gyro = server_CreateBlobNoInit("gyromat");
					gyro.set_f32("gyromat_value",this.get_f32("gyromat_acceleration")-1.0f);
					gyro.setPosition(this.getPosition());
					gyro.server_setTeamNum(-1);
				gyro.Init();
			}
			
			this.set_f32("gyromat_acceleration", carried.get_f32("gyromat_value")+1.0f);
			this.Sync("gyromat_acceleration",true);
			carried.server_Die();
		}
	}
	
	if (cmd == this.getCommandID("unload_gyromat"))
	{
		if(isServer()){
			if(this.get_f32("gyromat_acceleration") > 1){
				CBlob @gyro = server_CreateBlobNoInit("gyromat");
					gyro.set_f32("gyromat_value",this.get_f32("gyromat_acceleration")-1.0f);
					gyro.setPosition(this.getPosition());
					gyro.server_setTeamNum(-1);
				gyro.Init();
			}
			
			this.set_f32("gyromat_acceleration", 1.0f);
			this.Sync("gyromat_acceleration",true);
		}
	}
}


void onDie(CBlob@ this){
	if(isServer())
	if(this.get_f32("gyromat_acceleration") > 1){
		CBlob @gyro = server_CreateBlobNoInit("gyromat");
			gyro.set_f32("gyromat_value",this.get_f32("gyromat_acceleration")-1.0f);
			gyro.setPosition(this.getPosition());
			gyro.server_setTeamNum(-1);
		gyro.Init();
	}
	
	this.set_f32("gyromat_acceleration", 1.0f);
}