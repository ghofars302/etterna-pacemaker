-- Config
local p1name = GAMESTATE:GetPlayerDisplayName(PLAYER_1)

local posx = SCREEN_WIDTH-5
local posy = 35

local center1P = PREFSMAN:GetPreference("Center1Player"); -- For relocating graph/judgecount frame
local cols = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer(); -- For relocating graph/judgecount frame

local target = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).TargetGoal/100

local judgecolor = {
	'#eebb00',
	'#eebb00',
	'#eebb00',
	'#66ccff',
	"#e61e25",
	"#e61e25",
	"#c97bff",
	"#c97bff",
	"#ed0972"
}

local lifecolor = {
	'#eebb00',
	'#66ccff',
	"#e61e25",
	"#e61e25",
	"#c97bff",
	"#c97bff",
	"#ed0972"
}

local playedgrade = {
	playedC = false, 
	playedB = false, 
	playedA = false,
	playedAA = false,
	playedAAA = false,
	playedMAX = false
}

local gradetier = {
	Tier00 = 100/100, -- MAX
	Tier01 = 99.97/100, -- AAAA
	Tier02 = 99.75/100, -- AAA
	Tier03 = 93/100, -- AA
	Tier04 = 80/100, -- A
	Tier05 = 70/100, -- B
	Tier06 = 60/100, -- C
	Tier07 = 0/100, -- D
};

local graphmode = "WIFE"
local avgscoretype = tonumber(GetUserPref("AvgScoreTypeP1")); -- unused. will allow users to select scoretype for average score. currently hardcoded to percent score.
local avgscoremode = "DP"

local graphx = SCREEN_WIDTH -- Location of graph, graph is aligned to right.
local graphy = SCREEN_HEIGHT-80 -- Location of scoregraph bottom (aka: 0% line)
local graphheight = 300 -- scoregraph height (aka: height from 0% to max)
local graphwidth = 100+25 -- width of scoregraph, minimum of 100 recommended to avoid overlapping text.

local currentbarx = graphx-1
local currentbarwidth = graphwidth*0.2

local pacemakerbarx = graphx+15
local pacemakerbarwidth = graphwidth*0.2

local bestcorebarx = graphx-43
local bestcorebarwidth = graphwidth*0.2



-- Others

function AddPacemakerDisplay(self, second)
	local isEnable = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GraphBestScore

	if second then
		if isEnable then
			graphwidth = graphwidth+20
		end

		self:halign(1):x(graphx):y(0):zoomto(graphwidth,SCREEN_HEIGHT):diffuse(color("0.2,0.2,0.2,0.4")):vertalign(top)
	else
		if isEnable then
			graphwidth = graphwidth+20
		end

		self:halign(1):x(graphx):y(0):zoomto(graphwidth,SCREEN_HEIGHT):diffuse(color("0,0,0,0.6")):vertalign(top):fadeleft(1)
	end
end

--[[
local isEnable = true -- playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GraphBestScore

if isEnable then
	currentbarx = graphx-10
	currentbarwidth = graphwidth*0.2

	pacemakerbarx = graphx-23
	pacemakerbarwidth = graphwidth*0.2
end
--]]

P1Fail = false

-- Functions

function WifeToPercentPacemaker(params)
	return (-(params.WifeDifferential-params.CurWifeScore ))*(params.TotalPercent/(100*params.CurWifeScore)) * 100
end

function WifeToPercentUser(params)
	return string.format("%5.2f",params.TotalPercent)
end

local t = Def.ActorFrame {
	Def.ActorFrame{ -- Score Graph
		InitCommand=function(self)
			self:visible(true)
		end;
		BeginCommand=function(self)
			if graphmode == 'Off' or cols >= 8 then
				self:visible(true)
			end;
		end;
		Def.Quad{ --Graph BG
			Name="graphbg";
			--InitCommand=cmd(x,graphx;y,50+graphy;zoomto,100,graphheight+125;diffuse,color("0,0,0,0.4");vertalign,bottom);
			InitCommand=function(self)
				AddPacemakerDisplay(self)
			end;
		};
		Def.Quad{ --Graph BG
			Name="graphbg";
			--InitCommand=cmd(x,graphx;y,50+graphy;zoomto,100,graphheight+125;diffuse,color("0,0,0,0.4");vertalign,bottom);
			InitCommand=function(self)
				AddPacemakerDisplay(self, true)
			end;
		};
		Def.Quad{ -- AAA Grade Line
			Name="AAALine";
			InitCommand=function(self)
				self:halign(1):x(graphx):y(graphy-graphheight):zoomto(graphwidth,2):diffuse(color("1,1,1,0.4")):vertalign(bottom):visible(true)
			end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:visible(true);
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if params.TotalPercent/100 >= 99.75/100 then
					self:diffuse(color("1,0.8,0,0.4"));
				else
					self:diffuse(color("1,1,1,0.4"));
				end;
			end;
		};
		LoadFont("Common Normal") .. { --AAA Text
      		Name="AAALineText";
      		InitCommand=function(self)
        		self:halign(0):x(graphx-(graphwidth)+2):y(graphy-graphheight-3):zoom(0.3):diffuse(color("1,1,1,0.4")):vertalign(bottom):visible(true)
      		end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:settext('AAA');
					self:visible(true);
				end;
			end;
			JudgmentMessageCommand=function(self)
			end;
    	};
    	LoadFont("Common Normal") .. { --AAA UpdateMessage
     		Name="AAAUpdateMessage";
      		InitCommand=function(self)
      			self:x(graphx+50):y(graphy-graphheight*gradetier["Tier02"]-3):zoom(0.4):diffuse(color("1,1,1,0.8")):vertalign(bottom):maxwidth(90*(1/0.4)):visible(true)
      		end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:settext('Rank AAA Pass');
						--self:visible(true);
				else
					self:visible(true)
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if graphmode == "WIFE" and playedgrade['playedAAA'] == false then
					if params.TotalPercent/100 >= 99.75/100 then
						playedgrade['playedAAA'] = true
						self:stoptweening();
						self:visible(true);
						self:sleep(0.1);
						self:linear(0.2);
						self:x(graphx-graphwidth/2);
						self:sleep(3);
						self:linear(0.2);
						self:x(graphx+50);
							--self:visible(true);
					end;
				end;
			end;
      	};
		Def.Quad{ -- AA Grade Line
			Name="AALine";
			InitCommand=function(self)
				self:halign(1):x(graphx):y(graphy-graphheight*gradetier["Tier03"]):zoomto(graphwidth,2):diffuse(color("1,1,1,0.4")):vertalign(bottom):visible(true)
			end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:visible(true);
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if params.TotalPercent/100 >= 93/100 then
					self:diffuse(color("1,0.8,0,0.4"));
				else
					self:diffuse(color("1,1,1,0.4"));
				end;
			end;
		};
		LoadFont("Common Normal") .. { --AA Text
      		Name="AALineText";
      		InitCommand=function(self)
        		self:halign(0):x(graphx-(graphwidth)+2):y(graphy-graphheight*gradetier["Tier03"]-3):zoom(0.3):diffuse(color("1,1,1,0.4")):vertalign(bottom):visible(true)
      		end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:settext('AA');
					self:visible(true)
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if params.TotalPercent/100 >= 93/100 then
					self:diffuse(color("1,0.8,0,0.4"));
					self:diffusealpha(1);
				else
					self:diffuse(color("1,1,1,0.4"));
				end;
			end;
    	};
    	LoadFont("Common Normal") .. { --AA UpdateMessage
      		Name="AAUpdateMessage";
      		InitCommand=function(self)
       			self:x(graphx+50):y(graphy-graphheight*gradetier["Tier03"]-3):zoom(0.4):diffuse(color("1,1,1,0.8")):vertalign(bottom):maxwidth(90*(1/0.4)):visible(true)
      		end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:settext('Rank AA Pass');
						--self:visible(true);
				else
					self:visible(true)
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if graphmode == "WIFE" and playedgrade['playedAA'] == false then
					if params.TotalPercent/100 >= 93/100 then
						playedgrade['playedAA'] = true
						self:stoptweening();
						self:visible(true);
						self:sleep(0.1);
						self:linear(0.2);
						self:x(graphx-graphwidth/2);
						self:sleep(3);
						self:linear(0.2);
						self:x(graphx+50);
							--self:visible(true);
					end;
				end;
			end;
    	};
		Def.Quad{ -- A Grade Line
			Name="ALine";
			InitCommand=function(self)
				self:halign(1):x(graphx):y(graphy-graphheight*gradetier["Tier04"]):zoomto(graphwidth,2):diffuse(color("1,1,1,0.4")):vertalign(bottom):visible(true)
			end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:visible(true);
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if params.TotalPercent/100 >= 80/100 then
					self:diffuse(color("1,0.8,0,0.4"));
				else
					self:diffuse(color("1,1,1,0.4"));
				end;
			end;
		};
		LoadFont("Common Normal") .. { --A Text
      		Name="ALineText";
     		InitCommand=function(self)
        		self:halign(0):x(graphx-(graphwidth)+2):y(graphy-graphheight*gradetier["Tier04"]-3):zoom(0.3):diffuse(color("1,1,1,0.4")):vertalign(bottom):visible(true)
      		end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:settext('A');
					self:visible(true);
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if params.TotalPercent/100 >= 80/100 then
					self:diffuse(color("1,0.8,0,0.4"));
					self:diffusealpha(1);
				else
					self:diffuse(color("1,1,1,0.4"));
				end;
			end;
    	};
    	LoadFont("Common Normal") .. { --A UpdateMessage
      		Name="AUpdateMessage";
      		InitCommand=function(self)
        		self:x(graphx+50):y(graphy-graphheight*gradetier["Tier04"]-3):zoom(0.4):diffuse(color("1,1,1,0.8")):vertalign(bottom):maxwidth(90*(1/0.4)):visible(true)
      		end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:settext('Rank A Pass');
						--self:visible(true);
				else
					self:visible(true)
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if graphmode == "WIFE" and playedgrade['playedA'] == false then
					if params.TotalPercent/100 >= 80/100 then
						playedgrade['playedA'] = true
						self:stoptweening();
						self:visible(true);
						self:sleep(0.1);
						self:linear(0.2);
						self:x(graphx-graphwidth/2);
						self:sleep(3);
						self:linear(0.2);
						self:x(graphx+50);
							--self:visible(true);
					end;
				end;
			end;
    	};
		Def.Quad{ -- B Grade Line
			Name="BLine";
			InitCommand=function(self)
				self:halign(1):x(graphx):y(graphy-graphheight*gradetier["Tier05"]):zoomto(graphwidth,2):diffuse(color("1,1,1,0.4")):vertalign(bottom):visible(true)
			end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:visible(true);
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if params.TotalPercent/100 >= 70/100 then
					self:diffuse(color("1,0.8,0,0.4"));
				else
					self:diffuse(color("1,1,1,0.4"));
				end;
			end;
		};
		LoadFont("Common Normal") .. { --B Text
      		Name="BLineText";
      		InitCommand=function(self)
        		self:halign(0):x(graphx-(graphwidth)+2):y(graphy-graphheight*gradetier["Tier05"]-3):zoom(0.3):diffuse(color("1,1,1,0.4")):vertalign(bottom):visible(true)
     		end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:settext('B');
					self:visible(true);
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if params.TotalPercent/100 >= 70/100 then
					self:diffuse(color("1,0.8,0,0.4"));
					self:diffusealpha(1);
				else
					self:diffuse(color("1,1,1,0.4"));
				end;
			end;
      	};
    	LoadFont("Common Normal") .. { --B UpdateMessage
      		Name="BUpdateMessage";
      		InitCommand=function(self)
        		self:x(graphx+50):y(graphy-graphheight*gradetier["Tier05"]-3):zoom(0.4):diffuse(color("1,1,1,0.8")):vertalign(bottom):maxwidth(90*(1/0.4)):visible(true)
      		end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:settext('Rank B Pass');
					--self:visible(true);
				else
					self:visible(true)
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if graphmode == "WIFE" and playedgrade['playedB'] == false then
					if params.TotalPercent/100 >= 70/100 then
						playedgrade['playedB'] = true
						self:stoptweening();
						self:visible(true);
						self:sleep(0.1);
						self:linear(0.2);
						self:x(graphx-graphwidth/2);
						self:sleep(3);
						self:linear(0.2);
						self:x(graphx+50);
						self:visible(true);
					end;
				end;
			end;
    	};
		Def.Quad{ -- C Grade Line
			Name="CLine";
			InitCommand=function(self)
				self:halign(1):x(graphx):y(graphy-graphheight*gradetier["Tier06"]):zoomto(graphwidth,2):diffuse(color("1,1,1,0.4")):vertalign(bottom):visible(true)
			end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:visible(true);
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if params.TotalPercent/100 >= 60/100 then
					self:diffuse(color("1,0.8,0,0.4"));
				else
					self:diffuse(color("1,1,1,0.4"));
				end;
			end;
		};
		LoadFont("Common Normal") .. { --C Text
      		Name="CLineText";
      		InitCommand=function(self)
        		self:halign(0):x(graphx-(graphwidth)+2):y(graphy-graphheight*gradetier["Tier06"]-3):zoom(0.3):diffuse(color("1,1,1,0.4")):vertalign(bottom)
      		end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:settext('C');
					self:visible(true);
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if params.TotalPercent/100 >= 60/100 then
					self:diffuse(color("1,0.8,0,0.4"));
					self:diffusealpha(1);
				else
					self:diffuse(color("1,1,1,0.4"));
				end;
			end;
    	};
    	LoadFont("Common Normal") .. { --C UpdateMessage
      		Name="CUpdateMessage";
      		InitCommand=function(self)
      			self:x(graphx+50):y(graphy-graphheight*gradetier["Tier06"]-3):zoom(0.4):diffuse(color("1,1,1,0.8")):vertalign(bottom):maxwidth(90*(1/0.4)):visible(true)
      		end;
			BeginCommand=function(self)
				if graphmode == "WIFE" then
					self:settext('Rank C Pass');
						--self:visible(true);
				else
					self:visible(true)
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if graphmode == "WIFE" and playedgrade['playedC'] == false then
					if params.TotalPercent/100 >= 60/100 then
						playedgrade['playedC'] = true
						self:stoptweening();
						self:visible(true);
						self:sleep(0.1);
						self:linear(0.2);
						self:x(graphx-graphwidth/2);
						self:sleep(3);
						self:linear(0.2);
						self:x(graphx+50);
						self:visible(true);
					end;
				end;
			end;
    	};
  		Def.Quad{ -- Base Line
			Name="BaseLine";
			InitCommand=function(self)
				self:halign(1):x(graphx):y(graphy):zoomto(graphwidth,2):diffuse(color("1,1,1,0.4")):vertalign(bottom):visible(true)
			end;
		};
		LoadFont("Common Normal") .. { --Pacemaker Curscore
      		Name="Pacemaker Curscore";
      		InitCommand=function(self)
        		self:x(graphx-5):y(65-1):zoom(0.35):horizalign(right)
      		end;
			BeginCommand=function(self)
				self:settext(0);
			end;
			JudgmentMessageCommand=function(self, params)
				self:settext(string.format("%5.2f",params.TotalPercent))
				self:visible(true)
			end;
  		};
    	LoadFont("Common Normal") .. { --Pacemaker username
      		Name="Pacemaker username";
      		InitCommand=function(self)
        		self:x(graphx-graphwidth+2):y(65):zoom(0.4):horizalign(left):maxwidth((graphwidth-30)/0.4)
      		end;
			BeginCommand=function(self)
				self:queuecommand("Set")
			end;
			SetCommand=function(self)
				self:settext(p1name);
			end;
    	};
		LoadFont("Common Normal") .. { --Pacemaker TargetScore
      		Name="Pacemaker_TargetScore";
      		InitCommand=function(self)
        		self:x(graphx-5):y(75-1):zoom(0.35):horizalign(right)
      		end;
			BeginCommand=function(self)
				self:settext(0);
			end;
			JudgmentMessageCommand=function(self, params)
				local score = (-(params.WifeDifferential-params.CurWifeScore ))*(params.TotalPercent/(100*params.CurWifeScore))
				self:settext(string.format("%5.2f",score * 100))
				self:visible(true)
			end;
		};
    	LoadFont("Common Normal") .. { --Pacemaker Label
      		Name="Pacemaker_TargetScore";
      		InitCommand=function(self)
        		self:x(graphx-graphwidth+2):y(75):zoom(0.4):horizalign(left)
      		end;
			BeginCommand=function(self)
				self:queuecommand("Set")
			end;
			SetCommand=function(self)
				self:settext('Pacemaker');
			end;
		};
		Def.Quad{ --CurrentTargetBarGhost
			Name="CurrentGhostTargetBar";
			InitCommand=function(self)
				self:x(pacemakerbarx-graphwidth*0.3):y(graphy):zoomx(graphwidth*0.2):diffuse(color("#ff9999")):vertalign(bottom):visible(true):diffuseshift():effectcolor1(color("1,0.5625,0.5625,0.1")):effectcolor2(color("1,0.5625,0.5625,0.1")):effectperiod(2)
			end;
			BeginCommand=function(self)
				self:zoomtoheight((target*(graphheight-1))+1)
				self:visible(true)
			end
		};
		Def.Quad{ --CurrentTargetBar
			Name="CurrentTargetBar";
			InitCommand=function(self)
				self:x(pacemakerbarx-graphwidth*0.3):y(graphy):zoomx(graphwidth*0.2):diffuse(color("#ff9999")):vertalign(bottom):visible(true):diffuseshift():effectcolor1(color("1,0.5625,0.5625,0.5")):effectcolor2(color("1,0.5625,0.5625,0.4")):effectperiod(2)
			end;
			JudgmentMessageCommand=function(self, params)
				local score = (-(params.WifeDifferential-params.CurWifeScore ))*(params.TotalPercent/(100*params.CurWifeScore))

				self:zoomtoheight((score*(graphheight-1))+1);
				self:visible(true);
			end;
		};
		
		Def.Quad{ --CurrentScoreBar
			Name="CurrentScoreBar";
			InitCommand=function(self)
				self:x(currentbarx-graphwidth*0.7):y(graphy):zoomx(currentbarwidth):diffuse(color("#99ccff")):vertalign(bottom):visible(true):diffuseshift():effectcolor1(color("0.5625, 0.75, 1, 0.6")):effectcolor2(color("0.5625, 0.75, 1, 0.4")):effectperiod(2)
			end;
			JudgmentMessageCommand=function(self, params)
				local score = (params.TotalPercent/100*(graphheight-1))+1
				if score >= 1 then
					self:zoomtoheight(score);
					self:visible(true);
				end
			end;
		};
		Def.Quad{ -- best score graph
			Name="BestScoreBar";
			InitCommand=function(self)
				self:x(bestcorebarx-graphwidth*0.1):y(graphy):zoomx(currentbarwidth):diffuse(color("#008000")):vertalign(bottom):visible(true):diffuseshift():effectcolor1(color("#008000D5")):effectcolor2(color("#006300D5")):effectperiod(2)
			end;
			BeginCommand=function(self)
				local score = GetDisplayScore()

				if score then
					local truescore = (score:GetWifeScore() * 10000) / 100 / 100

					self:zoomtoheight((truescore*(graphheight-1))+1);
					self:visible(true)
				end
			end;
			JudgmentMessageCommand=function(self, params)
				local score = GetDisplayScore()

				if not score then
					local score = (params.TotalPercent/100*(graphheight-1))+1
					if score >= 1 then
						self:zoomtoheight(score);
						self:visible(true);
					end
				end
			end
		};

		-- text above

		LoadFont("Common Normal") .. {
			InitCommand=function(self)
				self:x(posx):y(20):zoom(0.45):halign(1)
			end;
			BeginCommand=function(self)
				text=GetLifeDifficulty();
				self:settextf("ScoreGraph Data");
				self:visible(true)
			end;
		};
		LoadFont("Common Normal") .. {
			InitCommand=function(self)
				self:x(posx-8):y(posy):zoom(0.4):halign(1)
			end;
			BeginCommand=function(self)
				text=GetLifeDifficulty();
				self:settextf("Life Difficulty ");
				self:visible(true)
			end;
		};
		LoadFont("Common Normal") .. {
			InitCommand=function(self)
				self:x(posx-8):y(posy+10):zoom(0.4):halign(1)
			end;
			BeginCommand=function(self)
				text=GetTimingDifficulty();
				self:settextf("Timing Difficulty ");
				self:visible(true)
			end;
		};
		LoadFont("Common Normal") .. {
			InitCommand=function(self)
				self:x(posx):y(posy):zoom(0.4):halign(1)
			end;
			BeginCommand=function(self)
				text=tonumber(GetLifeDifficulty());
				self:settextf(text);
				self:diffuse(color(lifecolor[text]))
				self:visible(true)
			end;
		};
		LoadFont("Common Normal") .. {
			InitCommand=function(self)
				self:x(posx):y(posy+10):zoom(0.4):halign(1)
			end;
			BeginCommand=function(self)
				text=tonumber(GetTimingDifficulty());
				self:settextf(text);
				self:diffuse(color(judgecolor[text]))	
				self:visible(true)
			end;
		};

		-- text below

		LoadFont("Common Normal") .. {
			Name="TargetScore";
			InitCommand=function(self)
				self:x(graphx-graphwidth/2):y(graphy+10):zoom(0.45):diffuse(color("#99ccff"))
			end;
			BeginCommand=function(self)
				self:settext('Current Score')
			end;
		};

		LoadFont("Common Normal") .. {
			Name="TargetScore";
			InitCommand=function(self)
				self:x(graphx-graphwidth/2):y(graphy+25):zoom(0.45):diffuse(color("#47ff66"))
			end;
			BeginCommand=function(self)
				self:settext('Loading...')

				local score = GetDisplayScore()
				if score then
					self:settext('Best Score')
				else
					self:settext('First Score')
				end
			end;
		};

		LoadFont("Common Normal") .. { -- GraphType (Target)
			InitCommand=function(self)
				self:x(graphx-graphwidth/2):y(graphy+41):zoom(0.45):diffuse(color("#ff9999"))
			end;
			BeginCommand=function(self)
				if target == 1 then
					self:settext('Rank AAA')
				elseif target == gradetier["Tier03"] then
					self:settext('Rank AA')
				elseif target == gradetier["Tier04"] then
					self:settext('Rank A')
				elseif target == gradetier["Tier05"] then
					self:settext('Rank B')
				elseif target == gradetier["Tier06"] then
					self:settext('Rank C')
				else
					self:settext('Wife '..tostring(target*100)..'%')
				end;
			end;
		};
	};
};

local PMdisplay = themeConfig:get_data().PMDisplay

if PMdisplay == "1" then
	return Def.ActorFrame {}
else
	return t
end
