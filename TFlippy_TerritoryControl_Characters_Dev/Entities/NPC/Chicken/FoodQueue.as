//todo: make this a more generic class like "overlapqueue" as an example
//script by betelgeuse
class FoodQueue	//queue to eat food - collision based rather than radius based
{
	private CBlob@[] queue;
	private string food;	//the name of the food we want to eat
	private u32 eat_time;	//time until we can eat again (in seconds)
	private u32 eat_timer;
	private bool ate;	//did we just eat?

	FoodQueue(const string f, const u32 t) 
	{
		food = f;
		eat_time = t;
		eat_timer = t;	
	}

	bool Eat(CBlob@ this)
	{
		bool found_food = false;
		
		for (int i = queue.length - 1; i >= 0; i--)	//iterating backwards as to not bump the queue
		{
			CBlob@ blob = @queue[i];

			//blob doesn't exist or we're not close enough to eat
			if (blob is null || !this.isOverlapping(@blob)) 
			{
				queue.erase(i);
				continue;
			}

			if (!found_food && this.isOverlapping(@blob)) 
			{
				blob.server_Die();
				queue.erase(i);
				found_food = true;
			}
		}
		return found_food;
	}

	void onTick(CBlob@ this) 
	{
		if (eat_timer == 0)
		{
			ate = Eat(@this);
			if (ate) {
				eat_timer = getTicksASecond() * eat_time;
			}
		}
		else {
			ate = false;
			--eat_timer;
		}
	}

	bool Ate() {
		return ate;
	}

	void onCollision(CBlob@ this, CBlob@ blob) 
	{
		if (blob is null || blob.getName() != food) return;
		queue.push_back(@blob);
	}
}