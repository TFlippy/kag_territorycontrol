//////////////////////////////////////////////////////
//
//  VehicleFire.as - Ginger
//
//  Holds the required information regarding bullets
//  This file is not required for blobs that use StandardFire.as
//

void onInit(CBlob@ this)
{
	if (!this.exists("CustomBullet")) this.set_string("CustomBullet", "Bullet.png");  // Default bullet image
	if (!this.exists("CustomBulletWidth")) this.set_f32("CustomBulletWidth", 0.7f);  // Default bullet width
	if (!this.exists("CustomBulletLength")) this.set_f32("CustomBulletLength", 3.0f); // Default bullet length

	string vert_name = this.get_string("CustomBullet");
	CRules@ rules = getRules();

	if (isClient()) //&& !rules.get_bool(vert_name + '-inbook'))
	{
		if (vert_name == "")
		{
			// warn(this.getName() + " Attempted to add an empty CustomBullet, this can cause null errors");
			return;
		}

		//rules.set_bool(vert_name + '-inbook', true);

		Vertex[]@ bullet_vertex;
		rules.get(vert_name, @bullet_vertex);

		if (bullet_vertex is null)
		{
			Vertex[] vert;
			rules.set(vert_name, @vert);
		}

		// #blamekag
		if (!rules.exists("VertexBook"))
		{
			string[] book;
			rules.set("VertexBook", @book);
			book.push_back(vert_name);
		}
		else
		{
			string[]@ book;
			rules.get("VertexBook", @book);
			book.push_back(vert_name);
		}
	}
}
