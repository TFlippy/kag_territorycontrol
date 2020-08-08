
void onTick(CBlob@ blob)
{
	if (isServer()) {
		if (blob.get_bool("should_do_attack_hack")) {
			blob.setKeyPressed(key_action1, true);
			blob.set_bool("should_do_attack_hack", false);
		} else {
			blob.setKeyPressed(key_action1, false);
		}
	}
}