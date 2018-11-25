
string[] names = 
{ 
	"Pete",
	"Morgan",
	"Jack",
	"Daniels",
	"Barbossa",
	"Gull",
	"Yiff",
	"Jones",
	"Tweety",
	"Birdd",
	"Willem",
	"Michiel",
	"Piter"
};

void onInit(CBlob@ this)
{
	Random@ rand = Random(this.getNetworkID());
	string name = "Pirate " + names[rand.NextRanged(names.length)];
	
	this.set_string("chicken name", name);
	this.setInventoryName(name);
	
	this.Tag("dangerous");
}