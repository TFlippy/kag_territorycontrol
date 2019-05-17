void onInit(CBlob@ this)
{
	// Vec2f[] shape = 
	// { 
		// Vec2f(0, 0),
		// Vec2f(1, 0),
		// Vec2f(1, 1),
		// Vec2f(0, 1)
	// };
		
	// this.getShape().AddShape(shape);
}

void onAttach(CBlob@ this,CBlob@ attached,AttachmentPoint @attachedPoint)
{
	if (attachedPoint !is null && attachedPoint.name == "CARGO")
	{
		// Seems that this was causing crashes / freezes
		// f32 width = attached.getShape().getWidth(), height = attached.getShape().getHeight();
		
		// // Vec2f offset = Vec2f(this.getShape().getWidth() / 2, -attachedPoint.offset.y);
		// Vec2f offset = Vec2f(0, -attachedPoint.offset.y / 2);
	
		// Vec2f[] shape = 
		// { 
			// Vec2f(0, 0) - offset,
			// Vec2f(width, 0) - offset,
			// Vec2f(width, height) - offset,
			// Vec2f(0, height) - offset
		// };
	
		// this.getShape().RemoveShape(1);
		// this.getShape().AddShape(shape);
	}
}

void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	if (attachedPoint !is null && attachedPoint.name == "CARGO")
	{
		// this.getShape().RemoveShape(1);
		
		// Vec2f[] shape = 
		// { 
			// Vec2f(0, 0),
			// Vec2f(1, 0),
			// Vec2f(1, 1),
			// Vec2f(0, 1)
		// };
		
		// this.getShape().AddShape(shape);
	}
}