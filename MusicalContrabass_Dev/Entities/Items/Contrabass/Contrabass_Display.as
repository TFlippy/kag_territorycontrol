
string[] note_names = 
{"B","C","C#","D","D#","E","F","F#","G","G#","A","A#"};

string[] layout_names = 
{"piano","bayan","guitar","wicki", "midi"};

string[] instr_names = 
{"harp","banjo","guitar"};

const SColor firstcolor(255, 255, 255, 0);
const SColor secondcolor(255, 255, 0, 0);
const SColor thirdcolor(255, 255, 0, 255);
const SColor fourthcolor(255, 0, 255, 255);
const SColor fifthcolor(255, 0, 255, 0);

//GUI::DrawText(string text, Vec2f pos, SColor color);
void displayNoteName(CBlob@ this)
{
    Vec2f pos = getDriver().getScreenPosFromWorldPos(Vec2f(this.getPosition().x,this.getPosition().y-5));
    s8 note = this.get_u8("note");
    //print("note 12 = "+note%12);
    s8 oct_num = (Maths::Floor((note-1)/12)+1);
    //print("note = "+note);
    GUI::DrawText(note_names[(note%12)]+oct_num, pos, SColor( 255, 255, 0, 200 ));
    this.set_u8("note_display_timer",this.get_u8("note_display_timer") - 1);
}

void displayLayoutName(CBlob@ this)
{
    bool music_mode = this.hasTag("music_mode");
	Vec2f pos = getDriver().getScreenPosFromWorldPos(Vec2f(this.getPosition().x,this.getPosition().y+10));
    GUI::DrawText(layout_names[this.get_u8("layout_number")], pos, music_mode?fifthcolor:secondcolor);
}


void onRender(CSprite@ this)
{
	//print("PLEASE RENDER!");
    //print("in onRender");
	CBlob@ blob = this.getBlob();
	if(blob !is null)
	{

		if(blob.get_u8("note_display_timer") > 0)
		    displayNoteName(blob);

		AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
	    CBlob@ playerblob = point.getOccupied();
		if(point !is null && playerblob !is null && playerblob.isMyPlayer())
		{
		    displayLayoutName(blob);
		    displayHelp(blob, playerblob);
		}
	}

}


u8 pages = 0;
u8 pages_timer = 0;
u8 timer_limit = 15;



void displayHelp(CBlob@ this ,CBlob@ playerblob )
{
    //CPlayer@ player = getLocalPlayer();  
    //if (player is null || !player.isMyPlayer()) { return; }

    CControls@ controls = playerblob.getControls();
    if(controls is null) return;
    //isKeyJustPressed seems to not work here

    //debug:
    //if(controls.isKeyPressed(KEY_F7))  
       // print("please");
    
    
    u8 prev_pages = pages;

    Vec2f scr(getScreenWidth(),getScreenHeight());

    //print("in display help");
    if(pages == 0)
    {
        GUI::DrawText( "Press F7 for help.", Vec2f(0,  0) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), thirdcolor, true, true);
        GUI::DrawText( "Press F8 for GUI.", Vec2f(0, 10) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), thirdcolor, true, true);
        if(pages_timer == 0)
        {       	
            if(controls.isKeyPressed(KEY_F7)) pages = 2;
            else if(controls.isKeyPressed(KEY_F8)) pages = 1;
            if(pages != prev_pages) pages_timer = timer_limit;
        }
        
    }
    else if(pages == 1)
    {        
        //print("in pages 1");
        bool music_mode = this.hasTag("music_mode");
        u8 layout_number = this.get_u8("layout_number");
        u8 instr_number = this.get_u8("instr_number");
        s8 octave_mod = this.get_s8("octave_mod");
        s8 key_shift = this.get_s8("key_shift");
        s8 note = this.get_u8("note");;
        s8 oct_num = (Maths::Floor((note-1)/12)+1);


        GUI::DrawText( "Press F7 for help.", Vec2f(0, 0) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), thirdcolor, true, true);
        GUI::DrawText( "Press F8 to close GUI.", Vec2f(0, 10) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), firstcolor, true, true);

        GUI::DrawText( "Layout="+layout_names[layout_number]+", Instr="+instr_names[instr_number], Vec2f(0, scr.y*6/8) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), thirdcolor, true, true);
        GUI::DrawText( "Note = "+note_names[(note%12)]+oct_num+"  "+note, Vec2f(0, scr.y*6/8+10) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), thirdcolor, true, true);
        bool isGuitar = (layout_number == 2);
        GUI::DrawText( "octave shift = "+octave_mod, Vec2f(0, scr.y*6/8+20) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), thirdcolor, true, true);
        GUI::DrawText( (isGuitar?"string":"key")+" shift = "+key_shift, Vec2f(0, scr.y*6/8+30) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), thirdcolor, true, true);
        
        if(isGuitar)
        {
        	for(s8 i = 7; i > 0; i--)
        	{
        		//print("octave_mod = "+octave_mod);
        		bool withinRange = ((key_shift < i) && (i <= (key_shift + 4)));
        		s8 number = (note+1-5*i);
                //print(i+" "+key_shift+" "+withinRange);
                SColor thiscolor;
                if(withinRange) thiscolor = firstcolor;
                else thiscolor = secondcolor;
        		GUI::DrawText( ""+i+":"+number/*+" "+key_shift+" "+withinRange*/, Vec2f(0, scr.y*6/8+40+(7-i)*10) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), thiscolor , true, true);
        	}
        }

        if(pages_timer == 0)
        {       	
            if(controls.isKeyPressed(KEY_F7)) pages = 2;
            else if(controls.isKeyPressed(KEY_F8)) pages = 0;
            if(pages != prev_pages) pages_timer = timer_limit;
        }
    }
    else if(pages == 2)
    {    	
        GUI::DrawText( "Press F7 to close help.", Vec2f(0, 0) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), firstcolor, true, true);
        GUI::DrawText( "Press F8 for GUI.", Vec2f(0, 10) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), thirdcolor, true, true);

        GUI::DrawText( "-to start using the instrument press Space (press Space again to disable it).",Vec2f(0, scr.y/20+scr.y/7) , Vec2f(scr.x/2 + scr.x/4 , scr.y/7), secondcolor, true, true);
        GUI::DrawText( "-press keyboard letters/characters/symbols to start playing music.",Vec2f(0,  scr.y/4) , Vec2f(scr.x/2 + scr.x/4 , scr.y/10), secondcolor, true, true);
        GUI::DrawText( "-press left Ctrl to cycle through layouts.",Vec2f(0, scr.y/15+scr.y/4) , Vec2f(scr.x/2 + scr.x/4 , scr.y/7), secondcolor, true, true);
        GUI::DrawText( "-press right Ctrl to cycle through instruments.",Vec2f(0, scr.y/15+scr.y/4+10) , Vec2f(scr.x/2 + scr.x/4 , scr.y/7), secondcolor, true, true);
        
        GUI::DrawText( "-press left and right Alt to change octave shift.",Vec2f(0, scr.y/15+scr.y/4+20) , Vec2f(scr.x/2 + scr.x/4 , scr.y/7), secondcolor, true, true);
        GUI::DrawText( "-press F9 and F10 to change key shift on piano or string shift on guitar.",Vec2f(0, scr.y/15+scr.y/4+30) , Vec2f(scr.x/2 + scr.x/4 , scr.y/7), secondcolor, true, true);
        if(pages_timer == 0)
        {       	
            if(controls.isKeyPressed(KEY_F7)) pages = 0;
            else if(controls.isKeyPressed(KEY_F8)) pages = 1;
            if(pages != prev_pages) pages_timer = timer_limit;
        }
    }
    if(pages_timer > 0)
        pages_timer--;
}