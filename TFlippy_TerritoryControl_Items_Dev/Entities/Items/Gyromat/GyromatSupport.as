
void onInit(CBlob@ this)
{
	this.set_f32("gyromat_acceleration", 1.00f);
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	if (blob !is null)
	{
		string config = blob.getName();
		if (config == "gyromat")
		{
			RecalculateGyromats(this);
		}
	}
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if (blob !is null)
	{
		string config = blob.getName();
		if (config == "gyromat")
		{
			RecalculateGyromats(this);
		}
	}
}

void RecalculateGyromats(CBlob@ this)
{
	if (this !is null)
	{
		CInventory@ inv = this.getInventory();
		if (inv !is null)
		{
			s32 count = inv.getItemsCount();
			f32 acceleration = 1.00f;
			
			for (s32 i = 0; i < count; i++)
			{
				CBlob@ item = inv.getItem(i);
				if (item !is null && item.getName() == "gyromat")
				{
					acceleration += item.get_f32("gyromat_value");
				}
			}
			
			this.set_f32("gyromat_acceleration", acceleration);
		}
	}
}