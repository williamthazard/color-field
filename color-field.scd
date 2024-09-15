Task({
	o = Server.default.options;
	o.outDevice_("External Headphones");
	s.reboot;
	s.waitForBoot({
		var xPix,yPix,bf,fb,af,topScope;
		n = PathName.new(thisProcess.nowExecutingPath.dirname++"/images/awood/").entries.asArray;
		m = Array.fill(n.size,{arg i; Image.open(n[i].fullPath)});
		z = Array.fill(n.size,{arg i; m[i].height}).sort.reverse;
		y = Array.fill(n.size,{arg i; m[i].width}).sum;
		s.sync;
		t = 8;
		p = rrand(0,n.size-1);
		Window.closeAll;
		u = Window("color field",Rect(0,0,(y/4)+10,z[0]/4),border:false)
		.visible_(true)
		.background_(Color.clear)
		.drawFunc_(
			{
				n.size.do(
					{
						arg i;
						m[i].drawInRect(Rect((i*377),u.bounds.height-(m[i].height/4),m[i].width/4,m[i].height/4),Rect(m[i].bounds))
					}
				)
			}
		);
		s.sync;
		xPix = Array.fill(n.size,{arg i; [0,0,0,0,m[i].width-1,m[i].width-1,m[i].width-1,m[i].width-1]});
		yPix = Array.fill(n.size,{arg i; [0,0,m[i].height-1,m[i].height-1,0,0,m[i].height-1,m[i].height-1]});
		bf = Buffer.alloc(Server.default,4096,2);
		fb = Bus.audio(Server.default,2);
		"scanning pixels...".postln;
		w=Array.fill(n.size,
			{
				arg j;
				Array.fill(t,
					{
						arg i;
						var poss = [0,0,1,1,2,2,3,3];
						View(u,Rect(5+(poss[i]*80)+(j*377),u.bounds.height-((i%2)*80)-80,75,75)).visible_(true).alpha_(0.25);
					}
				)
			}
		);
		x = Window("lissajous",u.bounds+[0,100,0,0],border:false)
		.background_(Color.clear)
		.visible_(true)
		.onClose_({topScope.stop; bf.free; fb.free});
		topScope = ScopeView(x,
			Rect(0,
				0,
				x.view.bounds.width,
				x.view.bounds.height
			)
		)
		.bufnum_(bf.bufnum)
		.server_(Server.default)
		.style_(2)
		.xZoom_(1)
		.yZoom_(1)
		.waveColors_(
			[
				m[p].getColor(rrand(1,m[p].width-1),rrand(1,m[p].height-1)),
				m[p].getColor(rrand(1,m[p].width-1),rrand(1,m[p].height-1))
			]
		)
		.background_(Color.clear)
		.start;
		af = SynthDef("duoscope", { arg bus, bufnum;
			var z;
			z = In.ar(bus, 2);
			ScopeOut2.ar(z, bufnum);
			Out.ar(0, z);
		}).play(
			target: RootNode(Server.default),
			args: [\bus, fb.index, \bufnum, bf.bufnum],
			addAction: \addToTail
		);
		s.sync;
		d = Array.fill(n.size,
			{
				arg j;
				Array.fill(t,
					{
						arg i;
						Task(
							{
								var color, up, down, newray, delta;
								loop {
									delta = (m[j].getColor(xPix[j][i],yPix[j][i]).asArray[j%3])/10;
									if(
										i%2 == 0,
										{
											if(
												xPix[j][i] == 0,
												{
													up = true
												}
											);
											if(
												yPix[j][i] == (m[j].height-1),
												{
													down = true
												}
											);
											if(
												yPix[j][i] == 0,
												{
													down = false
												}
											);
											if(
												xPix[j][i] == (m[j].width-1),
												{
													up = false;
													if(
														down == true,
														{
															yPix[j][i] = yPix[j][i]-1
														},
														{
															yPix[j][i] = yPix[j][i]+1
														}
													)
												}
											);
											if(
												up == true,
												{
													xPix[j][i] = xPix[j][i]+1
												},
												{
													xPix[j][i] = xPix[j][i]-1
												}
											);
										},
										{
											if(
												yPix[j][i] == 0,
												{
													up = true
												}
											);
											if(
												xPix[j][i] == (m[j].width-1),
												{
													down = true
												}
											);
											if(
												xPix[j][i] == 0,
												{
													down = false
												}
											);
											if(
												yPix[j][i] == (m[j].height-1),
												{
													up = false;
													if(
														down == true,
														{
															xPix[j][i]=xPix[j][i]-1
														},
														{
															xPix[j][i]=xPix[j][i]+1
														}
													)
												}
											);
											if(
												up == true,
												{
													yPix[j][i] = yPix[j][i]+1
												},
												{
													yPix[j][i] = yPix[j][i]-1
												}
											);
										}
									);
									color = m[j].getColor(xPix[j][i],yPix[j][i]);
									m[j].setColor(Color.new(color.red,color.green,color.blue,m[j].getColor(xPix[j][i],yPix[j][i]).alpha-0.1),xPix[j][i],yPix[j][i]);
									w[j][i].background_(color).alpha_(0.25);
									u.refresh;
									if(
										j == 0,
										{
											if(
												i == 0,
												{
													color.asArray.postln;
												}
											)
										}
									);
									delta.yield
								}
							},AppClock
						)
					}
				)
			}
		);
		s.sync;
		d.size.do({arg i; d[i].size.do({arg j; d[i][j].play})});
		s.sync;
		f = {
			arg hz=330,amp=0.5;
			var note=hz.cpsmidi;
			var snd,intro;
			var airports = Array.fill(n.size,
				{
					arg i;
					Array.fill2D((m[i].width-1),(m[i].height-1),
						{
							arg r,c;
							m[i].getColor(r,c)
							.red
							.linlin(0,1,-12,12)
							.round
							.asInteger
						}
					).lace(1024)
				}
			);
			var planes = Array.fill(n.size,
				{
					arg i;
					Array.fill2D((m[i].width-1),(m[i].height-1),
						{
							arg r,c;
							m[i].getColor(r,c)
							.green
							.linlin(0,1,-16,16)
							.round
							.asInteger
						}
					).lace(1024)
				}
			);
			var rates = Array.fill(n.size,
				{
					arg i;
					Array.fill2D((m[i].width-1),(m[i].height-1),
						{
							arg r,c;
							m[i].getColor(r,c)
							.blue
							.linlin(0,1,0,2)
							.round(0.25)
						}
					).lace(1024)
				}
			);
			var seq,seqnote,notepulse,noterate;
			var planeseq,planenotes,planeenv,planenotechange;
			// piano stuff
			var noise, string, delaytime, lpf, noise_env,pianosnd,pianosnd2, damp_mul,pianohz,noise_hz;
			var noise_attack=0.002, noise_decay=0.06,
			tune_up = 1.0005, tune_down = 0.9996, string_decay=6.0,
			lpf_ratio=2.0, lpf_rq = 4.0, hpf_hz = 40, damp=0, damp_time=0.1;
			s.sync;
			planenotechange=Dust.kr(1/30)+Impulse.kr(0);
			planeenv=1-EnvGen.kr(Env.perc(3,10,0.9),planenotechange);
			planenotes=Demand.kr(TDelay.kr(planenotechange,3),0,Dxrand(planes,inf)); //chord sequencer
			notepulse=1;
			noterate=TChoose.kr(Dust.kr(notepulse)+Impulse.kr(0),rates[rrand(0,rates.size-1)]/2)*Rand(0.78,1.32);
			notepulse=Impulse.kr(noterate);
			seq=Demand.kr(Dust.kr(0.1)+Impulse.kr(0),0,Dxrand(airports,inf)); //note sequencer
			seqnote=Demand.kr(notepulse,0,Dxrand(seq,inf));
			snd=SinOsc.ar((note-24).midicps,mul:SinOsc.kr(Rand(0.001,0.01)).range(0.05,0.15));
			snd=snd+SinOsc.ar((note-12).midicps,mul:SinOsc.kr(Rand(0.001,0.01)).range(0.001,0.05));
			snd=snd+(planeenv*Mix.ar(Array.fill(8,{arg i;
				var snd;
				snd=SawDPW.ar((note+planenotes[i%4]+Select.kr(DC.kr(i%4)<1,[24.neg,36.neg])).midicps,mul:0.9);
				snd=LPF.ar(snd,LinExp.kr(SinOsc.kr(rrand(1/30,1/10),rrand(0,2*pi)),-1,1,hz,hz*5));
				snd=DelayC.ar(snd, rrand(0.01,0.03), LFNoise1.kr(Rand(5,10),0.01,0.02)/15 );
				Pan2.ar(snd,VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine))/7
			})));
			snd=MoogLadder.ar(snd.tanh,LinExp.kr(VarLag.kr(LFNoise0.kr(1/6),6,warp:\sine),-1,1,hz*2,hz*60));
			snd=snd+(
				0.55*DynKlank.ar(
					`[
						[
							(
								note+planenotes[0]
							).midicps, (
								note+planenotes[1]
							).midicps, (
								note+planenotes[2]
							).midicps, (
								note+planenotes[3]
						).midicps], nil, [
							1, 1, 1, 1
						]
					], PinkNoise.ar(
						[
							0.004, 0.004
						]
					)
				)
			);

			// piano sound from ezra
			noise_hz=VarLag.kr(LFNoise0.kr(1/10),10).range(2000,5000);
			pianohz=A2K.kr((note+seqnote-12).midicps);
			noise_env = Decay2.ar(Impulse.ar(noterate));
			noise = LFNoise2.ar(noise_hz) * noise_env;
			damp_mul = LagUD.ar(K2A.ar(1.0 - damp), 0, damp_time);
			delaytime = 1.0 / (pianohz * [tune_up, tune_down]);
			string = Mix.new(CombL.ar(noise, delaytime, delaytime, string_decay * damp_mul));
			pianosnd = RLPF.ar(string, lpf_ratio * pianohz, lpf_rq) * amp;
			pianosnd = HPF.ar(pianosnd, hpf_hz);
			// classic PolyPerc
			pianosnd2=(
				EnvGen.ar(Env.perc,notepulse)*
				MoogFF.ar(Pulse.ar((note+seqnote).midicps,mul:1.0),(note).midicps*1.5)
			);
			snd=snd+SelectX.ar(SinOsc.kr(LFNoise0.kr(0.1).range(0.01,0.1)).range(0.1,0.9),[pianosnd*0.3,pianosnd2]);
			snd=LPF.ar(snd,(note+36).midicps);
			snd=HPF.ar(snd,120);
			snd=snd*EnvGen.ar(Env.new([0,0,1],[0.5,3]));
			snd=FreeVerb.ar(snd,0.45,2.0,0.5);
			Out.ar(fb.index,snd*amp);
		};
		e = f.asDefName;
		s.sync;
		g = Synth(e);
},AppClock)}).play
