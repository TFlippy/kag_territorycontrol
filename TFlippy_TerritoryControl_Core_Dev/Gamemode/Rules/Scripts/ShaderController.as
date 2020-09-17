// Might do more here later

void onInit(CRules@ this)
{
    //Shader inits stuff here
    Driver@ driver = getDriver();
    driver.ForceStartShaders();

    driver.AddShader("drunk", 1100.1f);
    driver.SetShader("drunk", false);
    driver.SetShaderFloat("drunk", "res_x", getScreenWidth()); // will break on asu's resizing build until we move it into ontick or something
    driver.SetShaderFloat("drunk", "res_y", getScreenHeight());
    driver.SetShaderFloat("drunk", "scroll_x", 0);
    driver.SetShaderFloat("drunk", "time", 0);
    driver.SetShaderFloat("drunk", "amount", 0);

    driver.AddShader("bobomax", 1000.0f);
    driver.SetShader("bobomax", false);
    driver.SetShaderFloat("bobomax", "res_x", getScreenWidth());
    driver.SetShaderFloat("bobomax", "res_y", getScreenHeight());
    driver.SetShaderFloat("bobomax", "time", 0);

    if (!isClient())
    {
        this.RemoveScript("ShaderController.as");
    }
}

void onTick(CRules@ this)
{
    Driver@ driver = getDriver();

    if (!driver.ShaderState()) 
    {
        driver.ForceStartShaders(); // force enable shaders at all times
    }
}

void onSetPlayer( CRules@ this, CBlob@ blob, CPlayer@ player )
{
    if (player is getLocalPlayer())
    {
        getDriver().SetShader("drunk", false);
        getDriver().SetShader("bobomax", false);
    }
}