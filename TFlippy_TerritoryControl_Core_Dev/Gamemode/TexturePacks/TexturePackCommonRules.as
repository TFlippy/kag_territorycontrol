////Texture pack blob system by Rob
///All the data you need to mess with is bellow here. :)

string TreeTexture = "tree_texture";
string BushTexture = "bush_texture";
string IvyTexture = "ivy_texture";

void resetTextures(CRules@ this){
	//Reminder: Blobs from map loading are created *before* this script is called, for whatever reason.
	//This is called at the begining of new maps, so even though info_ blobs are theoretically capable of retexturing stuff themselves in the begining, the fact we need to reset textures here messes them up so we have to grab their texures again.
	
	
	//Reset textures to default.
	getRules().set_string(TreeTexture,"Vanilla_Trees.png");
	getRules().set_string(BushTexture,"Vanilla_Bushes.png");
	getRules().set_string(IvyTexture,"Ivy.png");
	
	CBlob@[] blobs;
	getBlobsByTag("texture_pack", @blobs); //Find our texture blob
	
	if(blobs.length > 0){ //If our texture blob exists, grab it's alternate texures if it has any.
		CBlob @pack = blobs[0];
		
		if(pack.exists(TreeTexture))getRules().set_string(TreeTexture,pack.get_string(TreeTexture));
		if(pack.exists(BushTexture))getRules().set_string(BushTexture,pack.get_string(BushTexture));
		if(pack.exists(IvyTexture))getRules().set_string(IvyTexture,pack.get_string(IvyTexture));
	}
	
	swapBlobTextures(); //Since blobs are created before this is fuction is called, we need to retexture everything again.
}


///Here's the code to swap out textures when needed, add swapping new blob textures here :D
void swapBlobTextures(){
	//Trees
	{
		string texture = getTextureSprite(TreeTexture);
		
		CBlob@[] blobs;
		getBlobsByName("tree_bushy", @blobs);
		getBlobsByName("tree_pine", @blobs);
		
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			CSprite@ sprite = b.getSprite();
			if(sprite !is null){
				sprite.ReloadSprite(texture, sprite.getFrameWidth(), sprite.getFrameHeight());
				for (int j = 0; j < sprite.getSpriteLayerCount(); j++){
					CSpriteLayer @layer = sprite.getSpriteLayer(j);
					if(layer !is null){
						layer.ReloadSprite(texture, layer.getFrameWidth(), layer.getFrameHeight());
					}
				}
			}
		}
	}
	
	//Bushes
	{
		string texture = getTextureSprite(BushTexture);
		
		CBlob@[] blobs;
		getBlobsByName("bush", @blobs);
		
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			CSprite@ sprite = b.getSprite();
			if(sprite !is null){
				sprite.ReloadSprite(texture, sprite.getFrameWidth(), sprite.getFrameHeight());
			}
		}
	}
	
	//Ivy
	{
		string texture = getTextureSprite(IvyTexture);
		
		CBlob@[] blobs;
		getBlobsByName("ivy", @blobs);
		
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			CSprite@ sprite = b.getSprite();
			if(sprite !is null){
				sprite.ReloadSprite(texture, sprite.getFrameWidth(), sprite.getFrameHeight());
			}
		}
	}
}

void onBlobCreated( CRules@ this, CBlob@ blob ){
	CSprite @sprite = blob.getSprite();
	if(sprite is null)return;
	
	//When a 'tree' is created, it's just a seed, so we don't have to loop through sprite layers
	//In theory at least, for some reason it does work and I can't be bothered to fix it
	//if(blob.getName() == "tree_bushy")sprite.ReloadSprite(getTextureSprite(TreeTexture), sprite.getFrameWidth(), sprite.getFrameHeight());
	//if(blob.getName() == "tree_pine")sprite.ReloadSprite(getTextureSprite(TreeTexture), sprite.getFrameWidth(), sprite.getFrameHeight());
	
	if(blob.getName() == "bush")sprite.ReloadSprite(getTextureSprite(BushTexture), sprite.getFrameWidth(), sprite.getFrameHeight());
}

///Touch anything below this and I murder you :D
void onInit(CRules@ this)
{
	resetTextures(this);
}

void onRestart(CRules@ this)
{
	resetTextures(this);
}

void setTextureSprite(CBlob @this, string texture_name, string texture){
	getRules().set_string(texture_name,texture);
	if(this !is null){
		this.set_string(texture_name,texture);
	}
}

string getTextureSprite(string texture_name){
	if(getRules().exists(texture_name))return getRules().get_string(texture_name);
	return "default.png"; //Uh-oh
}

