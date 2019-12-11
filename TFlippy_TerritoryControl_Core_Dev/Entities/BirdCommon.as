
void onInit()
{
	CBlob@[] blobs;
	getBlobs(@blobs);
	
	for (int i = 0; i < blobs.length; i++)
	{
		blobs[i].set_f32("fly_time", 1);
		blobs[i].AddScript("Fly.as");
	}
}
