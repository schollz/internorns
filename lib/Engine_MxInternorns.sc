// Engine_MxInternorns

// Inherit methods from CroneEngine
Engine_MxInternorns : CroneEngine {
    // MxSamples specific
    var sampleBuffMxSamples;
    // var sampleBuffMxSamplesDelay;
    var mxsamplesMaxVoices=40;
    var mxsamplesVoiceAlloc;
    // MxSamples ^
    // NornsDeck specific v0.1.0
    var synDrone;
    var synSupertonic;
    var synVoice=0;
    var maxVoices=5;
    var maxSamplers=6;
    var bufBreaklive;
    var synBreakliveRec;
    var synBreaklivePlay;
    var mainBus;
    var synSample;
    var bufSample;
    var synKeys;
    var bufKeys;
    // NornsDeck ^

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {

        mxsamplesVoiceAlloc=Dictionary.new(mxsamplesMaxVoices);

        context.server.sync;

        sampleBuffMxSamples = Array.fill(80, { arg i; 
            Buffer.new(context.server);
        });
        // sampleBuffMxSamplesDelay = Array.fill(mxsamplesMaxVoices, { arg i; 
        //     Buffer.alloc(context.server,48000,2);
        // });

        SynthDef("mxPlayer",{ 
                arg out=0,bufnum,bufnumDelay, amp, t_trig=0,envgate=1,name=1,
                attack=0.015,decay=1,release=2,sustain=0.9,
                sampleStart=0,sampleEnd=1,rate=1,pan=0,
                lpf=20000,hpf=10,
                secondsPerBeat=1,delayBeats=8,delayFeedback=1,delaySend=0;

                // vars
                var ender,snd;

                ender = EnvGen.ar(
                    Env.new(
                        curve: 'cubed',
                        levels: [0,1,sustain,0],
                        times: [attack+0.015,decay,release],
                        releaseNode: 2,
                    ),
                    gate: envgate,
                    doneAction: 2,
                );
                
                snd = PlayBuf.ar(2, bufnum,
                    rate:BufRateScale.kr(bufnum)*rate,
                    startPos: ((sampleEnd*(rate<0))*BufFrames.kr(bufnum))+(sampleStart/1000*48000),
                    trigger:t_trig,
                );
                // snd = LPF.ar(snd,lpf);
                // snd = HPF.ar(snd,hpf);
                // snd = Mix.ar([
                //     Pan2.ar(snd[0],-1+(2*pan),amp),
                //     Pan2.ar(snd[1],1+(2*pan),amp),
                // ]);
                snd = snd * amp * ender;
                // delay w/ 30 voices = 1.5% (one core) per voice
                // w/o delay w/ 30 voices = 1.1% (one core) per voice
                // SendTrig.kr(Impulse.kr(1),name,1);
                DetectSilence.ar(snd,doneAction:2);
                // just in case, release after 20 seconds, remove it
                FreeSelf.kr(TDelay.kr(DC.kr(1),20));
                Out.ar(out,snd)
        }).add; 

        this.addCommand("mxsamplesrelease","", { arg msg;
            (0..79).do({arg i; sampleBuffMxSamples[i].free});
        });
        this.addCommand("mxsamplesload","is", { arg msg;
            // lua is sending 0-index
            sampleBuffMxSamples[msg[1]].free;
            sampleBuffMxSamples[msg[1]] = Buffer.read(context.server,msg[2]);
        });

        this.addCommand("mxsampleson","iiffffffffffffff", { arg msg;
            var name=msg[1];
            if (mxsamplesVoiceAlloc.at(name)!=nil,{
                if (mxsamplesVoiceAlloc.at(name).isRunning==true,{
                    ("stealing "++name).postln;
                    mxsamplesVoiceAlloc.at(name).free;
                });
            });
            mxsamplesVoiceAlloc.put(name,
                Synth("mxPlayer",[
                \out,mainBus.index,
                // \bufnumDelay,sampleBuffMxSamplesDelay[msg[1]-1],
                \t_trig,1,
                \envgate,1,
                \bufnum,msg[2],
                \rate,msg[3],
                \amp,msg[4],
                \pan,msg[5],
                \attack,msg[6],
                \decay,msg[7],
                \sustain,msg[8],
                \release,msg[9],
                \lpf,msg[10],
                \hpf,msg[11],
                \secondsPerBeat,msg[12],
                \delayBeats,msg[13],
                \delayFeedback,msg[14],
                \delaySend,msg[15],
                \sampleStart,msg[16] ],target:context.server).onFree({
                    ("freed "++name).postln;
                    NetAddr("127.0.0.1", 10111).sendMsg("voice",name,0);
                });
            );
            NodeWatcher.register(mxsamplesVoiceAlloc.at(name));
        });

        this.addCommand("mxsamplesoff","i", { arg msg;
            // lua is sending 1-index
            var name=msg[1];
            if (mxsamplesVoiceAlloc.at(name)!=nil,{
                if (mxsamplesVoiceAlloc.at(name).isRunning==true,{
                    mxsamplesVoiceAlloc.at(name).set(
                        \envgate,0,
                    );
                });
            });
        });


	// break live
        mainBus=Bus.audio(context.server,2);

        bufBreaklive = Buffer.alloc(context.server, context.server.sampleRate * 18.0, 2);

        context.server.sync;

        SynthDef("defBreakliveRec", {
            arg bufnum, in;
            RecordBuf.ar(SoundIn.ar([0,1])+In.ar(in,2),bufnum);
        }).add;

        
        SynthDef("defBreaklivePlay", {
            arg amp=1, t_trig=0, bpm=140,bufnum, rate=1,ampmin=0, in,panRate=0;
            var timer, pos, start, end, snd, aOrB, crossfade, mainamp;
            aOrB=ToggleFF.kr(t_trig);
            crossfade=Lag.ar(K2A.ar(aOrB),0.5);
            rate=Lag.kr(rate,8);
            timer=Phasor.ar(1,1,0,BufFrames.ir(bufnum));
            start=Latch.kr(timer-(60/bpm/16*(LFNoise0.kr(1).range(1,16).floor)*BufSampleRate.ir(bufnum)),aOrB);
            start=(start>0*start)+(start<0*0);
            end=Latch.kr(timer,aOrB);
            pos=Phasor.ar(aOrB,
                rate:rate,
                start:(((rate>0)*start)+((rate<0)*end)),
                end:(((rate>0)*end)+((rate<0)*start)),
                resetPos:(((rate>0)*start)+((rate<0)*end)),
            );
            snd=BufRd.ar(2,bufnum,pos,interpolation:4);
            snd=(crossfade*snd)+(LinLin.kr(1-crossfade,0,1,ampmin,1)*(SoundIn.ar([0,1])+In.ar(in,2)));
            Out.ar(0,(snd*0.5).tanh);
        }).add;

        context.server.sync;

        synBreakliveRec = Synth("defBreakliveRec",[\bufnum,bufBreaklive,\in,mainBus.index],context.xg);
        synBreaklivePlay = Synth("defBreaklivePlay",[\bufnum,bufBreaklive,\in,mainBus.index],context.xg);

        this.addCommand("tapebreak","", { arg msg;
            synBreaklivePlay.set(\t_trig,1)
        });

        this.addCommand("taperate","f", { arg msg;
            synBreaklivePlay.set(\rate,msg[1])
        });

        this.addCommand("tapepan","f", { arg msg;
            synBreaklivePlay.set(\panRate,msg[1])
        });

	   context.server.sync;



        // sampler thing

        bufSample=Dictionary.new(8);
        synSample=Dictionary.new(8);

        SynthDef("defSampler", {
            arg out=0, amp=0,bufnum=0, rate=1, start=0, end=1, reset=0, t_trig=0,
            loops=1, pan=0;
            var snd,snd2,pos,pos2,frames,duration,env,finalsnd;
            var startA,endA,startB,endB,resetA,resetB,crossfade,aOrB;

            // latch to change trigger between the two
            aOrB=ToggleFF.kr(t_trig);
            startA=Latch.kr(start,aOrB);
            endA=Latch.kr(end,aOrB);
            resetA=Latch.kr(reset,aOrB);
            startB=Latch.kr(start,1-aOrB);
            endB=Latch.kr(end,1-aOrB);
            resetB=Latch.kr(reset,1-aOrB);
            crossfade=Lag.ar(K2A.ar(aOrB),0.05);
            amp=VarLag.kr(amp,6,0);


            rate = rate*BufRateScale.kr(bufnum);
            frames = BufFrames.kr(bufnum);
            duration = frames*(end-start)/rate.abs/context.server.sampleRate*loops;

            // envelope to clamp looping
            env=EnvGen.ar(
                Env.new(
                    levels: [0,1,1,0],
                    times: [0,duration-0.05,0.05],
                ),
                gate:t_trig,
            );

            pos=Phasor.ar(
                trig:aOrB,
                rate:rate,
                start:(((rate>0)*startA)+((rate<0)*endA))*frames,
                end:(((rate>0)*endA)+((rate<0)*startA))*frames,
                resetPos:(((rate>0)*resetA)+((rate<0)*endA))*frames,
            );
            snd=BufRd.ar(
                numChannels:2,
                bufnum:bufnum,
                phase:pos,
                interpolation:4,
            );

            // add a second reader
            pos2=Phasor.ar(
                trig:(1-aOrB),
                rate:rate,
                start:(((rate>0)*startB)+((rate<0)*endB))*frames,
                end:(((rate>0)*endB)+((rate<0)*startB))*frames,
                resetPos:(((rate>0)*resetB)+((rate<0)*endB))*frames,
            );
            snd2=BufRd.ar(
                numChannels:2,
                bufnum:bufnum,
                phase:pos2,
                interpolation:4,
            );

            finalsnd=(crossfade*snd)+((1-crossfade)*snd2) * env;
            Out.ar(out,Balance2.ar(finalsnd[0],finalsnd[1],-1*pan,amp))
        }).add;


        this.addCommand("wav","is", { arg msg;
            if (bufSample.at(msg[1])==nil,{
            },{
                bufSample.at(msg[1]).free;
            });
            Buffer.read(context.server,msg[2],action:{
                arg bufnum;
                ("loaded "++msg[2]++" into slot "++msg[1]).postln;
                bufSample.put(msg[1],bufnum);
		if (synSample.at(msg[1])==nil,{
                synSample.put(msg[1],Synth("defSampler",[
                    \out,mainBus.index,
                    \bufnum,bufnum,
                    \t_trig,1,\reset,0,\start,0,\end,1,\rate,1,\loops,1000
                ],target:context.server));
		},{
		synSample.at(msg[1]).set(\bufnum,bufnum);
		});
            });                       
        });

        this.addCommand("amp","if", { arg msg;
            synSample.at(msg[1]).set(\amp,msg[2])
        });

        this.addCommand("release","i", { arg msg;
            synSample.at(msg[1]).free;
	    synSample.removeAt(msg[1]);
            bufSample.at(msg[1]).free;
	    bufSample.removeAt(msg[1]);
        });

        this.addCommand("pan","if", { arg msg;
            synSample.at(msg[1]).set(\pan,msg[2])
        });

        this.addCommand("rate","if", { arg msg;
            synSample.at(msg[1]).set(\rate,msg[2])
        });

        this.addCommand("pos","iff", {arg msg;
            synSample.at(msg[1]).set(\t_trig,1,\reset,msg[2],\start,0,\end,1,\rate,msg[3]);
        });

        this.addCommand("loop","iff", {arg msg;
            synSample.at(msg[1]).set(\t_trig,1,\start,msg[2],\reset,msg[2],\end,msg[3]);
        });


        SynthDef("supertonic", {
            arg out,
            mix=50,level=(-5),distAmt=2,
            eQFreq=632.4,eQGain=(-20),
            oscAtk=0,oscDcy=500,
            oscWave=0,oscFreq=54,
            modMode=0,modRate=400,modAmt=18,
            nEnvAtk=26,nEnvDcy=200,
            nFilFrq=1000,nFilQ=2.5,
            nFilMod=0,nEnvMod=0,nStereo=1,
            oscLevel=1,nLevel=1,
            oscVel=100,nVel=100,modVel=100,
            fx_lowpass_freq=20000,fx_lowpass_rq=1,
            vel=64;

            // variables
            var osc,noz,nozPostF,snd,pitchMod,nozEnv,numClaps,oscFreeSelf,wn1,wn2,clapFrequency,decayer;

            // convert to seconds from milliseconds
            vel=LinLin.kr(vel,0,128,0,2);
            oscAtk=DC.kr(oscAtk/1000);
            oscDcy=DC.kr(oscDcy/1000);
            nEnvAtk=DC.kr(nEnvAtk/1000);
            nEnvDcy=DC.kr(nEnvDcy/1000*1.4);
            level=DC.kr(level);
            // add logistic curve to the mix
            mix=DC.kr(100/(1+(2.7182**((50-mix)/8))));
            // this is important at low freq
            oscFreq=oscFreq+5;

            // white noise generators (expensive)
            // wn1=SoundIn.ar(0); 
            // wn2=SoundIn.ar(1);
            wn1=WhiteNoise.ar();
            wn1=Clip.ar(wn1*100,-1,1);
            wn2=wn1;

            clapFrequency=DC.kr((4311/(nEnvAtk*1000+28.4))+11.44); // fit using matlab
            // determine who should free
            oscFreeSelf=DC.kr(Select.kr(((oscAtk+oscDcy)>(nEnvAtk+nEnvDcy)),[0,2]));

            // define pitch modulation1
            pitchMod=Decay.ar(Impulse.ar(0.0001),(1/(2*modRate)));
            // pitchMod=Select.ar(modMode,[
            //     Decay.ar(Impulse.ar(0.0001),(1/(2*modRate))), // decay
            //     SinOsc.ar(-1*modRate), // sine
            //     Lag.ar(LFNoise0.ar(4*modRate),1/(4*modRate)), // random
            // ]);

            // mix in the the pitch mod
            pitchMod=pitchMod*modAmt/2*(LinLin.kr(modVel,0,200,2,0)*vel);
            oscFreq=((oscFreq).cpsmidi+pitchMod).midicps;

            // define the oscillator
            osc=SinOsc.ar(oscFreq);
            // osc=Select.ar(oscWave,[
            //     SinOsc.ar(oscFreq),
            //     LFTri.ar(oscFreq,mul:0.5),
            //     SawDPW.ar(oscFreq,mul:0.5),
            // ]);
            // osc=Select.ar(modMode>1,[
            //     osc,
            //     SelectX.ar(oscDcy<0.1,[
            //         LPF.ar(wn2,modRate),
            //         osc,
            //     ])
            // ]);


            // add oscillator envelope
            decayer=SelectX.kr(distAmt/100,[0.05,distAmt/100*0.3]);
            osc=osc*EnvGen.ar(Env.new([0.0001,1,0.9,0.0001],[oscAtk,oscDcy*decayer,oscDcy],\exponential),doneAction:oscFreeSelf);

            // apply velocity
            osc=(osc*LinLin.kr(oscVel,0,200,1,0)*vel).softclip;

            // generate noise
            noz=wn1;

            // optional stereo noise
            // noz=Select.ar(nStereo,[wn1,[wn1,wn2]]);

            // define noise envelope
            nozEnv=Select.ar(nEnvMod,[
                EnvGen.ar(Env.new(levels: [0.001, 1, 0.0001], times: [nEnvAtk, nEnvDcy],curve:\exponential),doneAction:(2-oscFreeSelf)),
                DC.ar(1), //EnvGen.ar(Env.new([0.0001,1,0.9,0.0001],[nEnvAtk,nEnvDcy*decayer,nEnvDcy*(1-decayer)],\linear)),
                Decay.ar(Impulse.ar(clapFrequency),1/clapFrequency,0.85,0.15)*Trig.ar(1,nEnvAtk+0.001)+EnvGen.ar(Env.new(levels: [0.001, 0.001, 1,0.0001], times: [nEnvAtk,0.001, nEnvDcy],curve:\exponential)),
            ]);

            // apply noise filter
            nozPostF=Select.ar(nFilMod,[
                DC.ar(1),
                // BLowPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3)),
                BBandPass.ar(noz,nFilFrq,Clip.kr(2/nFilQ,0.1,6)),
                BHiPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3))
            ]);

            // special Q
            // nozPostF=SelectX.ar((0.1092*(nFilQ.log)+0.0343),[nozPostF,SinOsc.ar(nFilFrq)]);

            // apply envelope to noise
            noz=Splay.ar(nozPostF*nozEnv);

            // apply velocities
            noz=(noz*LinLin.kr(nVel,0,200,1,0)*vel).softclip;



            // mix oscillator and noise
            snd=SelectX.ar(mix/100*2,[
                noz*0.5,
                noz*2,
                osc*1
            ]);

            // apply distortion
            snd=SineShaper.ar(snd,1.0,1+(10/(1+(2.7182**((50-distAmt)/8))))).softclip;

            // apply eq after distortion
            snd=BPeakEQ.ar(snd,eQFreq,1,eQGain/2);

            snd=HPF.ar(snd,30);

            snd=snd*level.dbamp*0.2;

            // free self if its quiet
            DetectSilence.ar(snd,doneAction:2);

            Out.ar(out, snd);
        }).add;

        context.server.sync;

        synSupertonic = Array.fill(maxVoices,{arg i;
            Synth("supertonic", [\level,-100,\out,0],target:context.xg);
        });

        context.server.sync;

        this.addCommand("supertonic","ffffffffffffffffffffffffi", { arg msg;
            // lua is sending 1-index
            synVoice=synVoice+1;
            if (synVoice>(maxVoices-1),{synVoice=0});
            if (synSupertonic[synVoice].isRunning,{
                ("freeing "++synVoice).postln;
                synSupertonic[synVoice].free;
            });
            synSupertonic[synVoice]=Synth("supertonic",[
                \out,mainBus.index,
                \distAmt, msg[1],
                \eQFreq, msg[2],
                \eQGain, msg[3],
                \level, msg[4],
                \mix, msg[5],
                \modAmt, msg[6],
                \modMode, msg[7],
                \modRate, msg[8],
                \nEnvAtk, msg[9],
                \nEnvDcy, msg[10],
                \nEnvMod, msg[11],
                \nFilFrq, msg[12],
                \nFilMod, msg[13],
                \nFilQ, msg[14],
                \nStereo, msg[15],
                \oscAtk, msg[16],
                \oscDcy, msg[17],
                \oscFreq, msg[18],
                \oscWave, msg[19],
                \oscVel, msg[20],
                \nVel, msg[21],
                \modVel, msg[22],
                \fx_lowpass_freq,msg[23],
                \fx_lowpass_rq,msg[24],
            ],target:context.xg);
            NodeWatcher.register(synSupertonic[synVoice]);
        });
        // ^ NornsDeck specific

	}

	free {
        (0..79).do({arg i; sampleBuffMxSamples[i].free});
        // (mxsamplesMaxVoices).do({arg i; sampleBuffMxSamplesDelay[i].free;});
        mxsamplesVoiceAlloc.keysValuesDo({ arg key, value; value.free; });
        // NornsDeck Specific v0.0.1
        synDrone.free;
        (0..maxVoices).do({arg i; synSupertonic[i].free});
        synBreaklivePlay.free;
        synBreakliveRec.free;
        mainBus.free;
        synSample.keysValuesDo({ arg key, value; value.free; });
        bufSample.keysValuesDo({ arg key, value; value.free; });
        synKeys.free;
        bufKeys.free;
	}
}
