
bool server_isItemAccepted(CBlob @this, string item, bool Default = true){
	if(item == "gyromat")return false;
	
	string[]@ filter;
	if(this.get("filtered_items", @filter)){
		if(filter.length() > 0){

			for(int i = 0;i < filter.length();i++){
				if(item == filter[i]){
					return this.hasTag("whitelist");
				}
			}
			return !this.hasTag("whitelist");
		}
	}
	
	return Default;
}