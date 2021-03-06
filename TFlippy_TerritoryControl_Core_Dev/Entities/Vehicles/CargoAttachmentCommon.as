void TryToAttachCargo(CBlob@ blob, CBlob@ toBlob = null)
{
	if (blob !is null && blob.getAttachments() !is null)
	{
		AttachmentPoint@ bap1 = blob.getAttachments().getAttachmentPointByName("CARGO");
		if (bap1 !is null && !bap1.socket && bap1.getOccupied() is null)
		{
			CBlob@[] blobsInRadius;
			if (toBlob !is null) blobsInRadius.push_back(toBlob);
			else getMap().getBlobsInRadius(blob.getPosition(), blob.getRadius() * 1.5f + 64.0f, @blobsInRadius);

			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob @b = blobsInRadius[i];
					AttachmentPoint@[] points;

					if (b.getTeamNum() == blob.getTeamNum() && b.getAttachmentPoints(@points))
					{
						for (uint j = 0; j < points.length; j++)
						{
							AttachmentPoint@ att = points[j];

							// print("count: " + points.length);
							// print("" + att.name + "/end");
							// print("" + (att is null ? "att is null" : "att is gud") + " " + (att.name.findFirst("VEHICLE") != -1) + "");

							if (att !is null && att.socket && att.name.findFirst("CARGO") != -1 && att.getOccupied() is null)
							{
								if (b.getName() == "triplane") //triplane crate only
								{
									if (blob.getName() == "crate") //&& !blob.hasTag("parachute")
									{
										b.server_AttachTo(blob, att);
									}
								}
								else
								{
									b.server_AttachTo(blob, att);
								}
							}
						}
					}
				}
			}
		}
	}
}