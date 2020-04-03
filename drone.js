
// csound.StartAudioInput()


// called by csound.js
function moduleDidLoad() {

	document.getElementById('pause').disabled = false;

	CSOUND_AUDIO_CONTEXT.suspend();
	
	csound.CopyToLocal("sample1.00.wav", "sample1.00.wav");
	csound.PlayCsd("drone.csd");

	// impostazioni iniziali
	var val = document.getElementById("drone_duration").value;
	csound.SetChannel("drone_duration", val);

	SetParam("synthOn");
	SetParam("volumeSynth");
	SetParam("volumeNoisesynth");

}


function droneduration() {
	var val = document.getElementById('drone_duration').value;
	document.getElementById('drone_duration_value').value=val;
	csound.SetChannel("drone_duration", val);
	handleMessage("\ndrone duration " + val);
}
		
function synthOn() {
	var elem = document.getElementById('synthOn').innerText;
	
	if (elem=='ON') {
		csound.SetChannel("synthOn", 1);
		document.getElementById('synthOn').innerText = "OFF";
		handleMessage("\nSynth " + 1);
	} else {
		csound.SetChannel("synthOn", 0);
		document.getElementById('synthOn').innerText = "ON";
		handleMessage("\nSynth " + 0);
	}
}

function volumeSynth() {
	var value = document.getElementById("volumeSynth").value;
	document.getElementById('volumeSynth_value').value=value;
	csound.SetChannel("volumeSynth", value*0.1);
	handleMessage("\nvolume Synth " + value);
}

function reverbLevelSynth() {
	var value = document.getElementById("reverbLevelSynth").value;
	document.getElementById('reverbLevelSynth_value').value=value;
	csound.SetChannel("reverbLevelSynth", value*0.1);
	handleMessage("\nreverb Level Synth " + value);
}

function noisesynthOn() {
	var elem = document.getElementById('noisesynthOn').innerText;
	
	if (elem=='ON') {
		csound.SetChannel("noisesynthOn", 1);
		document.getElementById('noisesynthOn').innerText = "OFF";
		handleMessage("\nnoiseSynth " + 1);
	} else {
		csound.SetChannel("noisesynthOn", 0);
		document.getElementById('noisesynthOn').innerText = "ON";
		handleMessage("\nnoiseSynth " + 0);
	}
}

function volumeNoisesynth() {
	var value = document.getElementById("volumeNoisesynth").value;
	document.getElementById("volumeNoisesynth_value").value=value;
	csound.SetChannel("volumeNoisesynth", value*0.1);
	handleMessage("\nvolume noise Synth " + value);
}


// set parameter
function SetParam(name) {
	var val = document.getElementById(name).value;
	csound.SetChannel(name, val*0.1);
	console.log("\nSetParam: " + name + ": " + val);
}


var count = 0;

function handleMessage(message) {
	var element = document.getElementById('console');
	element.value += message;
	element.scrollTop = 99999; // focus on bottom
	count += 1;
	if (count == 1000) {
		element.value = ' ';
		count = 0;
	}
}

var playing = false;
var started = false;

function click_this() {
	if (playing == false) {
		CSOUND_AUDIO_CONTEXT.resume();
		if (started == false) {
			console.log("\n Fra");
			started = true;
		}
		document.getElementById('pause').innerText = "pause";
		playing = true;
	} else {
		CSOUND_AUDIO_CONTEXT.suspend();
		document.getElementById('pause').innerText = "play";
		playing = false;
	}
}

