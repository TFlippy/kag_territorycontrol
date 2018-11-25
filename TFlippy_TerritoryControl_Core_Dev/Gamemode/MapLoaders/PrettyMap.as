void CalculateMinimapColour( CMap@ this, u32 offset, TileType tile, SColor &out col)
{
	int X = offset % this.tilemapwidth;
	int Y = offset/this.tilemapwidth;
	
	Vec2f pos = Vec2f(X,Y);
	
	//print("Pos:"+pos);
	
	Tile ctile = this.getTile(pos*8);
	
	if (this.isTileGround( tile ) || this.isTileStone( tile ) ||
        this.isTileBedrock( tile ) || this.isTileGold( tile ) ||
        this.isTileThickStone( tile ) ||
        this.isTileCastle( tile ) || this.isTileWood( tile ) )
	{
		if (X != 0 && Y != 0 && X < this.tilemapwidth && Y < this.tilemapheight)
		{
			if(!this.isTileSolid(this.getTile(pos*8 + Vec2f(0,8))) || !this.isTileSolid(this.getTile(pos*8 + Vec2f(0,-8))) 
			|| !this.isTileSolid(this.getTile(pos*8 + Vec2f(8,0))) || !this.isTileSolid(this.getTile(pos*8 + Vec2f(-8,0))))
			{
				col = SColor(255,132,71,21); //Foreground edge
				
				if(this.isTileGold(tile))col = col.getInterpolated(SColor(255,255,198,75),0.1f);
			}
			else
			{
				col = SColor(255,196,135,58); //Foreground
			}
		}
		else
		{
			col = SColor(255,196,135,58); //Foreground
		}
	}
	else if(this.isTileBackground(ctile))
	{
		if (X != 0 && Y != 0 && X < this.tilemapwidth && Y < this.tilemapheight)
		{
			if(this.getTile(pos*8 + Vec2f(0,8)).type == CMap::tile_empty || this.getTile(pos*8 + Vec2f(0,-8)).type == CMap::tile_empty 
			|| this.getTile(pos*8 + Vec2f(8,0)).type == CMap::tile_empty || this.getTile(pos*8 + Vec2f(-8,0)).type == CMap::tile_empty)
			{
				col = SColor(255,196,135,58); //Background edge
			}
			else
			{
				col = SColor(255,243,172,92); //Background
			}
		}
		else
		{
			col = SColor(255,243,172,92); //Background
		}
	}
	else
	{
		col = SColor(0,237,204,166); //Sky
	}
	
	
	
	SColor color_bricks(0xffaaAAaa);
	SColor color_brickwall(0xffaaAAaa);
	SColor color_wood(0xff844715);
	SColor color_woodwall(0xffF3AC5C);
	
	SColor color_dirt(0xffc4873a);
	SColor color_backdirt(0xffdb994b);
	SColor color_stone(0xff555555);
	
	SColor color_moss(0xff99CC99);
	SColor color_mossback(0xff99CC99);
	SColor color_bedrock(0xff668866);

	if(!this.isTileGold(tile)){
		if(this.isTileCastle(tile) && !(tile >= CMap::tile_castle_moss && tile <= CMap::tile_castle_moss+2))col = col.getInterpolated(color_bricks, 0.5f);
		else if(tile >= 64 && tile <= 80)col = col.getInterpolated(color_brickwall, 0.5f);
		
		else if(this.isTileWood(tile))col = col.getInterpolated(color_wood, 0.5f);
		else if(tile >= CMap::tile_wood_back && tile <= CMap::tile_wood_back+2)col = col.getInterpolated(color_wood, 0.6f);

		else if(this.isTileGround(tile))col = col.getInterpolated(color_dirt, 0.5f);
		else if(this.isTileGroundBack(tile))col = col.getInterpolated(color_backdirt, 0.5f);
		else if(this.isTileStone(tile) || this.isTileThickStone(tile))col = col.getInterpolated(color_stone, 0.5f);
		
		else if(tile >= CMap::tile_castle_moss && tile <= CMap::tile_castle_moss+2)col = col.getInterpolated(color_moss, 0.5f);
		else if(this.isTileBedrock(tile))col = col.getInterpolated(color_bedrock, 0.5f);
		else if(tile >= CMap::tile_castle_moss+3 && tile <= CMap::tile_castle_moss+16)col = col.getInterpolated(color_mossback, 0.5f);
		//else col = col.getInterpolated(SColor(255,128, 179, 184), 0.3f);
	}
	
	if(this.isInWater(pos*8))col = col.getInterpolated(SColor(0xff0088ff), 0.5f);
}