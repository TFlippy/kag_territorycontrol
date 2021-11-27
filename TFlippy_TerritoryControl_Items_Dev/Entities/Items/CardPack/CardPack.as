
void onInit( CBlob@ this )
{
	this.addCommandID("useitem");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if (this.isOverlapping(caller) || this.isAttachedTo(caller))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(12, Vec2f_zero, this, this.getCommandID("useitem"), "Open the pack and see what's inside!", params);
		button.SetEnabled(this.isAttachedTo(caller));
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("useitem"))
	{
		u16 caller;

		if(!params.saferead_netid(caller)) return;
		CBlob@ callerBlob = getBlobByNetworkID(caller);
	
		if(!this.hasTag("opened"))
	    if(isServer()){
		
			for(int i = 0; i < 8; i+= 1){
			
				string name = "chaos_cards";
				switch(XORRandom(9)){
				
					case 0: 
						name = "holy_cards";
					break;
					
					case 1: 
						name = "chaos_cards";
					break;
					
					case 2: 
						name = "fire_cards";
					break;
					
					case 3: 
						name = "water_cards";
					break;
					
					case 4: 
						name = "cog_cards";
					break;
					
					case 5: 
						name = "steam_cards";
					break;
					
					case 6: 
						name = "nature_cards";
					break;
					
					case 7: 
						name = "mine_cards";
					break;
					
					case 8: 
						name = "death_cards";
					break;
				
				}
				
				CBlob@ blob = server_CreateBlob(name, -1, this.getPosition());
				
				if (blob !is null)
				{
					if (!callerBlob.server_PutInInventory(blob))
					{
						blob.setPosition(callerBlob.getPosition());
					}
				}
			}
			
			this.server_Die();
		
			this.Tag("opened");
		}
	}
}
