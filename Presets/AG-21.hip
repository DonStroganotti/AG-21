Processor 
Type SynthChain ID AG-21 Bypassed Gain 	      �?Balance 	        VoiceLimit 	      P@KillFadeTime 	      4@IconColour 0 packageName  BuildVersion �  EditorStates BodyShown 0 Visible 1 Solo 0 Folded 1  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ScriptProcessor ID Interface Bypassed Script rContent.makeFrontInterface(800, 600);

Globals.note_ranges = {
    sustain : [36,72]
};

// set initial key colors

var min = Globals.note_ranges.sustain[0];
var max = Globals.note_ranges.sustain[1];

for(var i = min; i <= max; i++){
    Engine.setKeyColour(i, 0x3300ff00);
}

// current notes
Globals.midiList = Engine.createMidiList();
Globals.midiList.fill(0);

Globals.CC = Engine.createMidiList();
Globals.CC.fill(0);

// active notes 
Globals.active_notes = [];
Globals.active_notes_idx = 0;
for(var i = 0; i < 128; i++){
    Globals.active_notes[i] = {
        note: -1,
        velocity: -1,
        note_id: -1,
        identifier: -1,    
    };
}

// store data about a played note
inline function storeActiveNoteInfo(note, velocity, note_id, identifier){
    Globals.active_notes[Globals.active_notes_idx].note = note;
    Globals.active_notes[Globals.active_notes_idx].velocity = velocity;
    Globals.active_notes[Globals.active_notes_idx].note_id = note_id;  
    Globals.active_notes[Globals.active_notes_idx].identifier = identifier;  
    Globals.active_notes_idx = (Globals.active_notes_idx+1) % 128;
};
Globals.storeActiveNoteInfo = storeActiveNoteInfo;

inline function resetActiveNote(i){
    Globals.active_notes[i].note = -1;
    Globals.active_notes[i].velocity = -1;
    Globals.active_notes[i].note_id = -1;
    Globals.active_notes[i].identifier= -1;
};
Globals.resetActiveNote= resetActiveNote;


Globals.SamplerNoteIds = [];
    
for(var i = 0; i < 32; i++){
    Globals.SamplerNoteIds[i] = [];
    for(var j = 0; j < 8; j++){
        Globals.SamplerNoteIds[i][j] = -1;
    }
}

inline function pushId(a1, a2){
    local i;
    for(i = 0; i < 8; i++){
        if(Globals.SamplerNoteIds[a1][i] === -1){
            Globals.SamplerNoteIds[a1][i] = a2;
            break;
        }
    }
}

Globals.pushId = pushId;

// TOP LEVEL PANELS
const var Main_Panel = Content.getComponent("Main Panel");
const var Settings_Panel = Content.getComponent("Settings Panel");
const var PerformanceLabel = Content.getComponent("PerformanceLabel");

// SETTINGS

inline function onSettingsButtonControl(component, value)
{
    // hide main panel and display settings panel
    if(value == true){
   	    Main_Panel.set("visible", false);   
   	    Settings_Panel.set("visible", true); 
    }
};

Content.getComponent("SettingsButton").setControlCallback(onSettingsButtonControl);


inline function onSettingsOkayButtonControl(component, value)
{
    // hide settings panel and display main panel again
	if(value == true){
   	    Main_Panel.set("visible", true);     
   	    Settings_Panel.set("visible", false); 
    }
};

Content.getComponent("SettingsOkayButton").setControlCallback(onSettingsOkayButtonControl);


inline function onDisplayPerformanceStatsBtnControl(component, value)
{
	PerformanceLabel.set("visible", value);
};

Content.getComponent("DisplayPerformanceStatsBtn").setControlCallback(onDisplayPerformanceStatsBtnControl);



// SETTINGS - PRESET

// Articulations


// EFFECTS
const var Saturator = Synth.getEffect("Saturator");

inline function onSaturationControl(component, value)
{
	Saturator.setAttribute(0, value);
	if(value <= 0.0){
	    Saturator.setBypassed(true);
	}else{
	    Saturator.setBypassed(false);
	}
};

Content.getComponent("Saturation").setControlCallback(onSaturationControl);


// CURVES
const var VelocityCurve = Content.getComponent("VelocityCurve");
const var LowpassCurve = Content.getComponent("LowpassCurve");
const var CurveText = Content.getComponent("CurveText");

inline function onCurveSelectControl(component, value)
{
    local text = component.getItemText();
    CurveText.set("text", text);
	switch(text){
	    case "Velocity":	        
	        VelocityCurve.set("visible", true);
	        LowpassCurve.set("visible", false);
	    break;
	    case "Lowpass":
	        VelocityCurve.set("visible", false);
	        LowpassCurve.set("visible", true);
	    break;
	}
};

Content.getComponent("CurveSelect").setControlCallback(onCurveSelectControl);

// release slider
Globals.releaseTime = 200;

inline function onReleaseSliderControl(component, value)
{
	Globals.releaseTime = value;
};

Content.getComponent("ReleaseSlider").setControlCallback(onReleaseSliderControl);

// sample start time
Globals.SampleStartSlider = Content.getComponent("SampleStartSlider");

// double track
Globals.doubleTrack = false;

const var DoubleTrackWidth = Content.getComponent("DoubleTrackWidth");

Globals.doubleTrackWidth = 0.5;

inline function onDoubleTrackWidthControl(component, value)
{
	Globals.doubleTrackWidth = value;
};

Content.getComponent("DoubleTrackWidth").setControlCallback(onDoubleTrackWidthControl);

inline function onDblTrackBtnControl(component, value)
{
	Globals.doubleTrack = value > 0;
};

Content.getComponent("DblTrackBtn").setControlCallback(onDblTrackBtnControl);

/*const var Sustain_Down = Synth.getSampler("Sustain Down");
const var Sustain_Up = Synth.getSampler("Sustain Up");

const var Room_Select = Content.getComponent("Room Select");

inline function SelectRoom(component, value)
{
	//Console.print(component);
	//Console.print(value);
	switch(value){
	    case 1:
	        Sustain_Down.loadSampleMap("Soft Sustain Raw");
	        break;
	    case 2:
	        Sustain_Down.loadSampleMap("Soft Sustain Studio");
	        break;
	    case 3:
	        Sustain_Down.loadSampleMap("Soft Sustain Chamber");
	        break;
	}
};

Room_Select.setControlCallback(SelectRoom);*/
function onNoteOn()
{
	// set value in midi list 
    Globals.midiList.setValue(Message.getNoteNumber(), 1);
}
 function onNoteOff()
{
	// set value in midi list 
    Globals.midiList.setValue(Message.getNoteNumber(), 0);
}
 function onController()
{
	
}
 function onTimer()
{
	
}
 function onControl(number, value)
{
	
}
  EditorStates BodyShown 1 Visible 1 Solo 0 contentShown 1 onInitOpen 1  ChildProcessors   Content  
Control type ScriptButton id DisplayPerformanceStatsBtn value 	         Control type ScriptSlider id MasterVolume value 	         Control type ScriptSlider id Saturation value 	         Control type ScriptSlider id SampleStartSlider value 	   ����? Control type ScriptSlider id ReleaseSlider value 	      i@ Control type ScriptButton id DblTrackBtn value 	      �? Control type ScriptSlider id DoubleTrackWidth value 	     �A@ Control type ScriptComboBox id CurveSelect value 	      �? Control type ScriptTable id VelocityCurve value 	        data %24...............vO...f+....9C...sO  Control type ScriptTable id LowpassCurve value 	        data %24...............vO...f+....9C..PrO  UIData  ContentProperties DeviceType 	Desktop Component 
type ScriptPanel id Settings Panel x 	        y 	        width 	      �@height 	     ��@itemColour 	%%%�    itemColour2 	�    borderSize 	        visible     Component type ScriptFloatingTile id CustomSettings x 	        y 	      H@width 	      �@height 	     @�@ContentType CustomSettings bgColour 	   �    itemColour 	����    itemColour2 	����    Data �{
  "Driver": false,
  "Device": false,
  "Output": false,
  "BufferSize": false,
  "SampleRate": false,
  "GlobalBPM": false,
  "StreamingMode": true,
  "ScaleFactor": true,
  "VoiceAmountMultiplier": true,
  "ClearMidiCC": false,
  "SampleLocation": true,
  "DebugMode": false,
  "ScaleFactorList": [
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    2.0
  ]
} parentComponent Settings Panel Font Arial FontSize 	      0@ Component 
type ScriptButton id SettingsOkayButton x 	      0@y 	      q@width 	      `@height 	      @@parentComponent Settings Panel isMomentary text Back saveInPreset  Component 	type ScriptButton id DisplayPerformanceStatsBtn x 	     H�@y 	      q@width 	     `d@height 	      @@parentComponent Settings Panel text Display Performance Stats processorId   Component type ScriptPanel id PresetPanel x 	      0@y 	     �s@width 	      �@height 	     �p@parentComponent Settings Panel itemColour2 	        textColour 	���3    itemColour 	        bgColour 	���     Component type ScriptFloatingTile id PresetBrowser x 	        y 	        width 	      �@height 	     �p@parentComponent PresetPanel ContentType PresetBrowser bgColour 	        itemColour 	��T�    itemColour2 	�s��    Data �{
  "ShowSaveButton": true,
  "ShowFolderButton": true,
  "ShowNotes": true,
  "ShowEditButtons": true,
  "ShowFavoriteIcon": true,
  "NumColumns": 1
}  Component type ScriptSlider id MasterVolume x �   y   width 	     �`@height 	     �O@processorId Master Gain parameterId Gain mode 	Decibel min 	      Y�max 	      B@stepSize 	�������?suffix  dB middlePosition 	      2� Component 	type ScriptPanel id Main Panel x 	        y 	        width 	      �@height 	     ��@borderSize 	        itemColour 	%%%�    itemColour2 	�    	Component type ScriptSlider id Saturation x 	     @h@y 	      \@width 	     �b@height 	      P@parentComponent Main Panel max 	   ����? Component 
type ScriptButton id SettingsButton x 	     ��@y 	      P@width 	      Y@height 	      @@parentComponent Main Panel text 
SETTINGS isMomentary saveInPreset  Component type ScriptSlider id SampleStartSlider x 	      >@y 	      K@width 	     �b@height 	      P@parentComponent Main Panel text Sample Start processorId Constant1 parameterId Intensity defaultValue 	   ����?itemColour2 	   �    itemColour 	IIQf    textColour 	����    showTextBox  Component type ScriptSlider id ReleaseSlider x 	     �g@y 	      K@width 	     �d@height 	      P@parentComponent Main Panel text 	Release mode Time max 	     @�@stepSize 	      �?suffix  ms middlePosition 	     ��@defaultValue 	      i@min 	      �? Component 	type ScriptButton id DblTrackBtn x 	      w@y 	      P@width 	      `@height 	      @@parentComponent Main Panel text Double Track isPluginParameter  Component type ScriptSlider id DoubleTrackWidth x 	     �@y 	      K@width 	     @\@height 	      P@parentComponent Main Panel text Width defaultValue 	     �A@suffix % max 	      Y@ Component 	type ScriptComboBox id CurveSelect x 	      @@y 	      `@width 	     ``@height 	      A@max    parentComponent Main Panel items Velocity
Lowpass
  Component type ScriptFloatingTile id 
Keyboard x 	        y 	     ��@width 	      �@height 	      Y@parentComponent Main Panel ContentType 
Keyboard bgColour 	YYY     itemColour 	���    itemColour2 	����    Data ^{
  "KeyWidth": 16.0,
  "DisplayOctaveNumber": false,
  "LowKey": 9,
  "HiKey": 93,
  "CustomGraphics": false,
  "DefaultAppearance": true,
  "BlackKeyRatio": 0.75,
  "ToggleMode": false,
  "MidiChannel": 1,
  "UseVectorGraphics": true,
  "UseFlatStyle": false,
  "MPEKeyboard": false,
  "MPEStartChannel": 2,
  "MPEEndChannel": 16
} Font Arial textColour 	����     Component type ScriptPanel id CurvePanel x 	      @@y 	      e@width 	      �@height 	     �t@parentComponent Main Panel textColour 	���s    itemColour2 	��^%    itemColour 	���/    borderRadius 	      @borderSize 	      �?Component type ScriptLabel id CurveText x 	      �?y 	      �?width 	     ��@height 	      @@parentComponent CurvePanel fontSize 	      >@fontStyle 	Regular text 
Velocity bgColour 	   G    itemColour 	���     alignment centredBottom editable multiline  Component type ScriptTable id VelocityCurve x 	      �y 	     �@@width 	     �@height 	     �r@parentComponent CurvePanel itemColour2 	�ɬ�    itemColour �wT1bgColour 66F processorId Velocity Curve Global customColours  Component type ScriptTable id LowpassCurve x 	      �y 	     �@@width 	     �@height 	     �r@parentComponent CurvePanel itemColour2 	��    itemColour �wT1bgColour 66F processorId Lowpass Curve Global customColours visible      Component type ScriptLabel id Instrument Name x 	        y 	        width 	      �@height 	      H@text Rusty Strings fontSize 	      B@bgColour 	&
L    fontName Impact fontStyle 	Regular textColour 	PP��    editable  Component type ScriptFloatingTile id PerformanceLabel x 	     ��@y 	        width 	     �k@height 	      8@ContentType PerformanceLabel bgColour 	        itemColour 	����    itemColour2 	����    Data {
} Font 	Calibri FontSize 	      2@textColour 	�t�    visible 	         Component type ScriptPanel id left top line x 	     �D@y 	      8@width 	      n@height 	      @borderSize 	        borderRadius 	        textColour 	����    itemColour 	PP��    itemColour2 	PP��     Component type ScriptPanel id right top line x 	     @�@y 	      8@width 	      n@height 	      @borderSize 	        borderRadius 	        textColour 	����    itemColour 	PP��    itemColour2 	PP��     Processor Type ScriptProcessor ID main Bypassed Script r
//Synth.deferCallbacks(true);

var pick_dir = 0;

reg noteOn;
reg noteOff;
reg noteVelocity;
//reg active_note;
reg CC_NUM;
reg CC_VAL;

var last_note = -1;
function onNoteOn()
{
    Message.ignoreEvent(true);
    noteOn = Message.getNoteNumber();

    noteVelocity = Message.getVelocity();
 
    local noteId = -1;
    local noteId2 = -1;
    local identifier = -1;
    
    if(Engine.getNumVoices() == 0){
        pick_dir = 1; 
        identifier = 1; // down pick
        last_note = -1;
    }
    
    if(noteOn > last_note){
        pick_dir = 0; 
        identifier = 1; // down pick
    }else if(noteOn > last_note){
        pick_dir = 1;
        identifier = 2; // up pick
    }else{
        if(pick_dir == 1){
            pick_dir = 0;
            identifier = 1; // sus down
        }else{
            pick_dir = 1;
            identifier = 2; // sus up    
        }
    }
    
    //identifier = 2; // sus medium
    noteId = Synth.playNote(noteOn, noteVelocity);   
    
    // push note 
    Globals.pushId(identifier, noteId);
        
    // release current note
    local i;
    for(i = 0; i < 128; i++){
        local note_data = Globals.active_notes[i];
        if(note_data.note == noteOn){    
            // fade note out instead of note off because sustain pedal might be down
            Synth.addVolumeFade(note_data.note_id, 40, -100);
            Globals.resetActiveNote(i);   
        }  
    }
    
    // double track
    if (Globals.doubleTrack) {
        noteId2 = Synth.playNote(noteOn, noteVelocity);   
    
        // push note 
        Globals.pushId(identifier, noteId2);
        
        // store new note
        Globals.storeActiveNoteInfo(noteOn, noteVelocity, noteId2, identifier);
    }
        
    // store new note
    Globals.storeActiveNoteInfo(noteOn, noteVelocity, noteId, identifier);
    
    last_note = noteOn;
    
}
 function onNoteOff()
{
    noteOff = Message.getNoteNumber();
    
    //Console.print(Globals.CC.getValue(64));
    
    if(Globals.CC.getValue(64) > 64) return;
        
    local i;
    for(i = 0; i < 128; i++){
        local note_data = Globals.active_notes[i];
        if(note_data.note == noteOff){           
            Synth.addVolumeFade(note_data.note_id, Globals.releaseTime, -100);
            Globals.resetActiveNote(i);   
        }  
    }


}
 function onController()
{
    CC_NUM = Message.getControllerNumber();
    CC_VAL = Message.getControllerValue();
    
    //Console.print(Message.getControllerValue());
    // release notes when sustain pedal is lifted
    if( CC_NUM == 64 && CC_VAL < 64){
        local i;
        for(i = 0; i < 127; i++){
            local note_data = Globals.active_notes[i];
            if(Globals.midiList.getValue(note_data.note) == 0 && note_data.note_id != -1){           
                Synth.addVolumeFade(note_data.note_id, Globals.releaseTime, -100);
                Globals.resetActiveNote(i);   
            }  
        }
    }
    
	Globals.CC.setValue(CC_NUM, CC_VAL);
}
 function onTimer()
{
	
}
 function onControl(number, value)
{
	
}
  EditorStates 
BodyShown 1 Visible 1 Solo 0 contentShown 1 onInitOpen 1 onNoteOnOpen 0 onNoteOffOpen 0 onControllerOpen 0 onTimerOpen 0 onControlOpen 0  ChildProcessors   Content   UIData  ContentProperties DeviceType 	Desktop  Processor Type ModulatorChain ID GainModulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0 Folded 0  ChildProcessors  Processor Type SimpleGain ID Simple Gain1 Bypassed Gain 	      4@Delay 	        Width 	      Y@Balance 	        InvertPolarity 	        EditorStates BodyShown 1 Visible 1 Solo 0 Folded 1  ChildProcessors  Processor Type ModulatorChain ID Gain Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Delay Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Width Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Pan Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ����Channel1    Send1 ���� Processor 
Type 	CurveEq ID Parametriq EQ1 Bypassed NumFilters    Band0 	      @Band1 	      T@Band2 	      �?Band3 	      �?Band4 	      @FFTEnabled EditorStates BodyShown 1 Visible 1 Solo 0 Folded 1  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ����Channel1    Send1 ���� Processor Type Saturator ID Saturator Bypassed Saturation 	        WetAmount 	      �?PreGain 	      0@PostGain 	      0�EditorStates BodyShown 1 Visible 1 Solo 0 Folded 1  ChildProcessors  Processor Type ModulatorChain ID Saturation Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ����Channel1    Send1 ���� Processor Type SimpleGain ID Master Gain Bypassed Gain 	        Delay 	        Width 	      Y@Balance 	        InvertPolarity 	        EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID Gain Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Delay Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Width Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Pan Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ����Channel1    Send1 ���� Processor Type GlobalModulatorContainer ID Global Modulator Container Bypassed Gain 	      �?Balance 	        VoiceLimit 	      p@KillFadeTime 	      4@IconColour 0 EditorStates BodyShown 1 Visible 1 Solo 0 Folded 1  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Global Modulators Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type 
Velocity ID Velocity Curve Global Bypassed Intensity 	      �?UseTable 	      �?Inverted 	        DecibelMode 	        VelocityTableData %24...............vO...f+....9C...sO EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type 
Velocity ID Lowpass Curve Global Bypassed Intensity 	      �?UseTable 	      �?Inverted 	        DecibelMode 	        VelocityTableData %24...............vO...f+....9C..PrO EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ����Channel1    Send1 ���� Processor Type StreamingSampler ID Sustain Medium Down Bypassed Gain 	      �?Balance 	        VoiceLimit 	      @@KillFadeTime 	      4@IconColour 0 PreloadSize 	      �@BufferSize 	      �@VoiceAmount 	      @@SamplerRepeatMode 	       @RRGroupAmount 	      @PitchTracking 	      �?OneShot 	        CrossfadeGroups 	        Purged 	        Reversed 	        NumChannels    UseStaticMatrix 	        Group0Table  Group1Table  Group2Table  Group3Table  Group4Table  Group5Table  Group6Table  Group7Table  SampleMapID Sustain Down EditorStates BodyShown 1 Visible 1 Solo 0 MapPanelShown 1 BigSampleMap 1 Folded 1 CrossfadeTableShown 0  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type ScriptProcessor ID Medium Sustain Down Bypassed Script �const var identifier = 1;

reg input_id;function onNoteOn()
{
	input_id = Message.getEventId();
    
    local i;
	for(i = 0; i < 8; i++){
	    if(Globals.SamplerNoteIds[identifier][i] === input_id){   
	        Globals.SamplerNoteIds[identifier][i] = -1;
	        return;
	    }
	}
	// if loop doesn't find id, ignore event
	Message.ignoreEvent(true);
}
 function onNoteOff()
{
	
}
 function onController()
{
	
}
 function onTimer()
{
	
}
 function onControl(number, value)
{
	
}
  EditorStates 
BodyShown 1 Visible 1 Solo 0 contentShown 1 onInitOpen 1 onNoteOnOpen 0 onNoteOffOpen 0 onControllerOpen 0 onTimerOpen 0 onControlOpen 0  ChildProcessors   Content   UIData  ContentProperties DeviceType 	Desktop  Processor Type ModulatorChain ID GainModulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor 	Type SimpleEnvelope ID Soft Sustain Envelope3 Bypassed Monophonic 	        Retrigger 	      �?Intensity 	      �?Attack 	      @Release 	      $@LinearMode 	      �?EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID Attack Time Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type GlobalVoiceStartModulator ID Global Voice Start Modulator1 Bypassed Intensity 	      �?UseTable Inverted TableData  Connection 2Global Modulator Container:Velocity Curve Global EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type 
StereoFX ID Stereo FX1 Bypassed Pan 	      Y@Width 	      Y@EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID Pan Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type ScriptVoiceStartModulator ID Pan modulator Bypassed Intensity 	      �?Bipolar Script �var doubleTrackPanIndex = 0;function onVoiceStart(voiceIndex)
{
	if (Globals.doubleTrack > 0) {
	    if (doubleTrackPanIndex == 0){
	        doubleTrackPanIndex = 1;
	        return 0.5 - 0.5 * (Globals.doubleTrackWidth * 0.01);
	    }else{
	        doubleTrackPanIndex = 0;
	        return 0.5 + 0.5 * (Globals.doubleTrackWidth * 0.01);
	    }
	}else{
	    return 0.5;
	}
}
 function onVoiceStop(voiceIndex)
{
	
}
 function onController()
{
	
}
 function onControl(number, value)
{
	
}
  EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Content   UIData  ContentProperties DeviceType 	Desktop  Processor 	Type PolyphonicFilter ID 	Filter1 Bypassed Gain 	        Frequency 	     ��@Q 	   @33�?Mode 	      "@Quality 	        BipolarIntensity 	        EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID Frequency Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type GlobalVoiceStartModulator ID Global Voice Start Modulator2 Bypassed Intensity 	      �?UseTable Inverted TableData  Connection 1Global Modulator Container:Lowpass Curve Global EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type ModulatorChain ID Gain Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Bipolar Freq Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Q Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Sample Start Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type ScriptVoiceStartModulator ID Script Voice Start Modulator1 Bypassed Intensity 	      �?Script � function onVoiceStart(voiceIndex)
{
    return Globals.SampleStartSlider.getValue();
}
 function onVoiceStop(voiceIndex)
{
	
}
 function onController()
{
	
}
 function onControl(number, value)
{
	
}
  EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Content   UIData  ContentProperties DeviceType 	Desktop  Processor Type ModulatorChain ID Group Fade Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ����Channel1    Send1 ���� channels  channelData enabled level 	        suffix   Processor Type StreamingSampler ID Sustain Medium Up Bypassed Gain 	      �?Balance 	        VoiceLimit 	      @@KillFadeTime 	      4@IconColour 0 PreloadSize 	      �@BufferSize 	      �@VoiceAmount 	      @@SamplerRepeatMode 	       @RRGroupAmount 	      @PitchTracking 	      �?OneShot 	        CrossfadeGroups 	        Purged 	        Reversed 	        NumChannels    UseStaticMatrix 	        Group0Table  Group1Table  Group2Table  Group3Table  Group4Table  Group5Table  Group6Table  Group7Table  SampleMapID Sustain Up EditorStates BodyShown 1 Visible 1 Solo 0 MapPanelShown 1 BigSampleMap 1 Folded 1 CrossfadeTableShown 0  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type ScriptProcessor ID Sustain Up Bypassed Script �const var identifier = 2;

reg input_id;function onNoteOn()
{
	input_id = Message.getEventId();
    
    local i;
	for(i = 0; i < 8; i++){
	    if(Globals.SamplerNoteIds[identifier][i] === input_id){   
	        Globals.SamplerNoteIds[identifier][i] = -1;
	        return;
	    }
	}
	// if loop doesn't find id, ignore event
	Message.ignoreEvent(true);
}
 function onNoteOff()
{
	
}
 function onController()
{
	
}
 function onTimer()
{
	
}
 function onControl(number, value)
{
	
}
  EditorStates 
BodyShown 1 Visible 1 Solo 0 contentShown 1 onInitOpen 1 onNoteOnOpen 0 onNoteOffOpen 0 onControllerOpen 0 onTimerOpen 0 onControlOpen 0  ChildProcessors   Content   UIData  ContentProperties DeviceType 	Desktop  Processor Type ModulatorChain ID GainModulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor 	Type SimpleEnvelope ID Soft Sustain Envelope2 Bypassed Monophonic 	        Retrigger 	      �?Intensity 	      �?Attack 	      @Release 	      $@LinearMode 	      �?EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID Attack Time Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type GlobalVoiceStartModulator ID Global Voice Start Modulator3 Bypassed Intensity 	      �?UseTable Inverted TableData  Connection 2Global Modulator Container:Velocity Curve Global EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor 	Type SimpleEnvelope ID DefaultEnvelope1 Bypassed Monophonic 	        Retrigger 	      �?Intensity 	      �?Attack 	      @Release 	      $@LinearMode 	      �?EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID Attack Time Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type 
StereoFX ID Stereo FX2 Bypassed Pan 	      Y@Width 	      Y@EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID Pan Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type ScriptVoiceStartModulator ID Pan modulator Bypassed Intensity 	      �?Bipolar Script �var doubleTrackPanIndex = 0;function onVoiceStart(voiceIndex)
{
	if (Globals.doubleTrack > 0) {
	    if (doubleTrackPanIndex == 0){
	        doubleTrackPanIndex = 1;
	        return 0.5 - 0.5 * (Globals.doubleTrackWidth * 0.01);
	    }else{
	        doubleTrackPanIndex = 0;
	        return 0.5 + 0.5 * (Globals.doubleTrackWidth * 0.01);
	    }
	}else{
	    return 0.5;
	}
}
 function onVoiceStop(voiceIndex)
{
	
}
 function onController()
{
	
}
 function onControl(number, value)
{
	
}
  EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Content   UIData  ContentProperties DeviceType 	Desktop  Processor 	Type PolyphonicFilter ID 	Filter2 Bypassed Gain 	        Frequency 	     ��@Q 	   @33�?Mode 	      "@Quality 	        BipolarIntensity 	        EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID Frequency Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type GlobalVoiceStartModulator ID Global Voice Start Modulator2 Bypassed Intensity 	      �?UseTable Inverted TableData  Connection 1Global Modulator Container:Lowpass Curve Global EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type ModulatorChain ID Gain Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Bipolar Freq Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Q Modulation Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Sample Start Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type ScriptVoiceStartModulator ID Script Voice Start Modulator2 Bypassed Intensity 	      �?Script � function onVoiceStart(voiceIndex)
{
    return Globals.SampleStartSlider.getValue();
}
 function onVoiceStop(voiceIndex)
{
	
}
 function onController()
{
	
}
 function onControl(number, value)
{
	
}
  EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Content   UIData  ContentProperties DeviceType 	Desktop  Processor Type ModulatorChain ID Group Fade Bypassed Intensity 	      �?EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ����Channel1    Send1 ���� channels  channelData enabled level 	        suffix   RoutingMatrix NumSourceChannels    Channel0     Send0 ����Channel1    Send1 ���� macro_controls  macro name 	Macro 1 value 0.0 midi_cc -1  macro name 	Macro 2 value 0.0 midi_cc -1  macro name 	Macro 3 value 0.0 midi_cc -1  macro name 	Macro 4 value 0.0 midi_cc -1  macro name 	Macro 5 value 0.0 midi_cc -1  macro name 	Macro 6 value 0.0 midi_cc -1  macro name 	Macro 7 value 0.0 midi_cc -1  macro name 	Macro 8 value 0.0 midi_cc -1  MidiAutomation   MPEData Enabled  