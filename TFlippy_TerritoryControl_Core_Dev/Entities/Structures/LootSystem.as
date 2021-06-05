#include "MakeMat.as";

class LootItem
{
	string blobname;
	u32 base_count;
	u32 bonus_count;
	u32 weight;

	LootItem(string blobname, u32 base_count, u32 bonus_count, u32 weight)
	{
		this.blobname = blobname;
		this.base_count = base_count;
		this.bonus_count = bonus_count;
		this.weight = weight;
	}
};

void server_SpawnRandomItem(CBlob@ this, const LootItem@[]@&in items)
{
    int index = GetRandomItem(@items);
	if (index >= 0 && index < items.length)
	{
		LootItem@ item = items[index];
		MakeMat(this, this.getPosition(), item.blobname, item.base_count + XORRandom(item.bonus_count));
	}
	else
	{
		printf("error while spawning loot! index: " + index);
	}
}

void server_SpawnCoins(CBlob@ this, u16 count)
{
	server_DropCoins(this.getPosition(), count);
}

// int sum = 0;

int GetRandomItem(const LootItem@[]@&in items)
{
	int sum = 0;
	for (int i = 0; i < items.length; i++)
	{
		sum += items[i].weight;
	}
	
	int rnd = XORRandom(sum);
	int num = 0;

	for (int i = 0; i < items.length; i++)
	{
		u32 weight = items[i].weight;

		if (rnd <= (num + weight))
		{
			return i;
		}

		num += weight;
	}

	return -1;
}
