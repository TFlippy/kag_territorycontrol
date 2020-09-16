
void onInit(CRules@ this)
{
    Driver@ driver = getDriver();


    driver.RemoveShader("hq2x");

    driver.AddShader("drunk", 1100.1f);
	driver.SetShader("drunk", true);
	driver.SetShaderFloat("drunk", "res_x", getScreenWidth()); // will break on asu's resizing build
	driver.SetShaderFloat("drunk", "res_y", getScreenHeight());
	driver.SetShaderFloat("drunk", "scroll_x", 0);
	driver.SetShaderFloat("drunk", "time", 0);
	driver.SetShaderFloat("drunk", "amount", 0);
	driver.SetShaderTextureFilter("drunk", false);



    this.RemoveScript("ShaderStartup.as");
}