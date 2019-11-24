-- Pacemaker aka scoregraph for 'til death from Staiain Ultralight shitport using "sure.py"
-- Credit Nick12#9400 for make the shit work

-- TODO for Monox#0934: remove useless shit and clean a mess

-- NOTE: This pacemaker hardcoded on p1, thank god etterna will remove players so this shit will need big ass update

---------------------------------------
-- Score Weights and Rank Conditions --
---------------------------------------

local posx = SCREEN_WIDTH-5
local posy = 35

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

local gradestring = {
	Grade_Tier01 = 'AAAA',
	Grade_Tier02 = 'AAA',
	Grade_Tier03 = 'AA',
	Grade_Tier04 = 'A',
	Grade_Tier05 = 'B',
	Grade_Tier06 = 'C',
	Grade_Tier07 = 'D',
	Grade_Failed = 'F'
};

local gradetier = {
	Tier01 = 99.97/100, -- AAAA
	Tier02 = 99.75/100, -- AAA
	Tier03 = 93/100, -- AA
	Tier04 = 80/100, -- A
	Tier05 = 70/100, -- B
	Tier06 = 60/100, -- C
	Tier07 = 0/100, -- D
};

local scoreweight =  { -- Score Weights for DP score (MAX2)
	TapNoteScore_W1				= 2,--PREFSMAN:GetPreference("GradeWeightW1"),					--  2
	TapNoteScore_W2				= 2,--PREFSMAN:GetPreference("GradeWeightW2"),					--  2
	TapNoteScore_W3				= 1,--PREFSMAN:GetPreference("GradeWeightW3"),					--  1
	TapNoteScore_W4				= 0,--PREFSMAN:GetPreference("GradeWeightW4"),					--  0
	TapNoteScore_W5				= -4,--PREFSMAN:GetPreference("GradeWeightW5"),					-- -4
	TapNoteScore_Miss			= -8,--PREFSMAN:GetPreference("GradeWeightMiss"),				-- -8
	HoldNoteScore_Held			= 6,--PREFSMAN:GetPreference("GradeWeightHeld"),				--  6
	TapNoteScore_HitMine		= -8,--PREFSMAN:GetPreference("GradeWeightHitMine"),				-- -8
	HoldNoteScore_LetGo			= 0,--PREFSMAN:GetPreference("GradeWeightLetGo"),				--  0
	-- HoldNoteScore_Missed = 0 --Placeholder for now
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit	= 0,--PREFSMAN:GetPreference("GradeWeightCheckpointHit"),		--  0
	TapNoteScore_CheckpointMiss = 0,--PREFSMAN:GetPreference("GradeWeightCheckpointMiss"),		--  0

};

local pweight =  { -- Score Weights for percentage scores (EX oni)
	TapNoteScore_W1			= 3,--PREFSMAN:GetPreference("PercentScoreWeightW1"),
	TapNoteScore_W2			= 2,--PREFSMAN:GetPreference("PercentScoreWeightW2"),
	TapNoteScore_W3			= 1,--PREFSMAN:GetPreference("PercentScoreWeightW3"),
	TapNoteScore_W4			= 0,--PREFSMAN:GetPreference("PercentScoreWeightW4"),
	TapNoteScore_W5			= 0,--PREFSMAN:GetPreference("PercentScoreWeightW5"),
	TapNoteScore_Miss			= 0,--PREFSMAN:GetPreference("PercentScoreWeightMiss"),
	HoldNoteScore_Held			= 3,--PREFSMAN:GetPreference("PercentScoreWeightHeld"),
	TapNoteScore_HitMine			= 0,--PREFSMAN:GetPreference("PercentScoreWeightHitMine"),
	HoldNoteScore_LetGo			= 0,--PREFSMAN:GetPreference("PercentScoreWeightLetGo"),
	-- HoldNoteScore_Missed = 0 --Placeholder for now
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= 0,--PREFSMAN:GetPreference("PercentScoreWeightCheckpointHit"),
	TapNoteScore_CheckpointMiss 	= 0,--PREFSMAN:GetPreference("PercentScoreWeightCheckpointMiss"),
};

local migsweight =  { -- Score Weights for MIGS score
	TapNoteScore_W1			= 3,
	TapNoteScore_W2			= 2,
	TapNoteScore_W3			= 1,
	TapNoteScore_W4			= 0,
	TapNoteScore_W5			= -4,
	TapNoteScore_Miss			= -8,
	HoldNoteScore_Held			= 6,
	TapNoteScore_HitMine			= -8,
	HoldNoteScore_LetGo			= 0,
	-- HoldNoteScore_Missed = 0 --Placeholder for now
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= 0,
	TapNoteScore_CheckpointMiss 	= 0,
};

local judgestats = { -- Table containing the # of judgements made so far
	TapNoteScore_W1 = 0,
	TapNoteScore_W2 = 0,
	TapNoteScore_W3 = 0,
	TapNoteScore_W4 = 0,
	TapNoteScore_W5 = 0,
	TapNoteScore_Miss = 0,
	HoldNoteScore_Held = 0,
	TapNoteScore_HitMine = 0,
	HoldNoteScore_LetGo = 0,
	-- HoldNoteScore_Missed = 0 --Placeholder for now
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= 0,
	TapNoteScore_CheckpointMiss 	= 0,
};


-----------------------------------------
-- Variables for JudgeCount/PA Counter --
-----------------------------------------
local center1P = PREFSMAN:GetPreference("Center1Player"); -- For relocating graph/judgecount frame
local cols = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer(); -- For relocating graph/judgecount frame

--Position of JudgeCount, the values here assumes center1P being enabled.

local framex = 45
local framey = SCREEN_HEIGHT*0.71

-- Change X Position depending on centered 1p
if center1P == false and cols == 4 then
	framex = framex + 320
elseif center1P == false and cols == 6 then
	framex = framex + 384
end;

local judgemode = "off"

-------------------------------
-- Variables for  Scoregraph --
-------------------------------
--local target = (tonumber(GetUserPref("GraphTargetP1"))+1)/100; -- target score from 0% to 100%.
local target = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).TargetGoal/100
--local targetdec = (tonumber(GetUserPref("GraphTargetP1dec"))+1)/10000; -- not used yet, will be used for decimal places for score target.

 -- for Rank <Grade> get messages on the scoregraph to make sure they only display once since DP score can go back down.
local playedgrade = {
	playedC = false, -- Played<Rank>
	playedB = false, 
	playedA = false,
	playedAA = false,
	playedAAA = false,
}

-- Sets everything in playedgrade to true if hidegrademessage is true so "Rank <grade> pass" message no longer appears.
local hidegraphmessage = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GraphMessage -- Used to toggle graphmessage preferences
if hidegraphmessage == "1" then
	hidegraphmessage = true
else
	hidegraphmessage = false
end;

for k,v in pairs(playedgrade) do
	playedgrade[k] = hidegraphmessage
end;

local graphtype = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GraphType -- unused until this hardcoded fixed
local graphmode

graphmode = "DP"

----------------------------------------------
-- Variables for  Ghost Score and Avg Score --
----------------------------------------------
local avgscoretype = tonumber(GetUserPref("AvgScoreTypeP1")); -- unused. will allow users to select scoretype for average score. currently hardcoded to percent score.
local avgscoremode = "DP"
--local ghostscoretype = "On" -- unused. for toggling ghostscore on and off.


-------------------------------------------
-- Variables for Current Play Statistics -- --- unused
-------------------------------------------
local p1name = GAMESTATE:GetPlayerDisplayName(PLAYER_1)
local maxnotes = GAMESTATE:GetCurrentSteps(PLAYER_1):GetRadarValues(PLAYER_1):GetValue("RadarCategory_TapsAndHolds"); -- Radarvalue, maximum number of notes
local maxholds = GAMESTATE:GetCurrentSteps(PLAYER_1):GetRadarValues(PLAYER_1):GetValue("RadarCategory_Holds") + GAMESTATE:GetCurrentSteps(PLAYER_1):GetRadarValues(PLAYER_1):GetValue("RadarCategory_Rolls"); -- Radarvalue, maximum number of holds
local totnotes = 0 -- #number of notes played so far
local totholds = 0 -- #number of holds played so far
local totmines = 0 -- #number of mines played so far

local dpscore = 0 -- current player score
local curmaxdp = 0 -- highest possible DP score at given moment
local maxdp = maxnotes*scoreweight["TapNoteScore_W1"]+maxholds*scoreweight["HoldNoteScore_Held"] -- maximum DP
local dppercent = 0.0 -- current player score percent

local percentscore = 0 -- current player score
local curmaxps = 0 -- highest possible percent score at given moment
local maxps = maxnotes*pweight["TapNoteScore_W1"]+maxholds*pweight["HoldNoteScore_Held"]  -- maximum %score DP
local pspercent = 0.0

local migsscore = 0 -- current player score
local curmaxmigs = 0 -- highest possible MIGS score at given moment
local maxmigs = maxnotes*migsweight["TapNoteScore_W1"]+maxholds*migsweight["HoldNoteScore_Held"]  -- maximum MIGS DP
local migspercent = 0.0

local curgrade

-------------
--Functions--
-------------

-- Takes both DP and %Score and player number as input, returns grade.
-- GetGradeFromPercent() doesn't seem to be able to distinguish AAAA and AAA
function curavggrade(DPScore,MaxDP,PScore,MaxPDP,pn)
	if SCREENMAN:GetTopScreen():GetLifeMeter(pn):IsFailing() then
		return 'Grade_Failed'
	elseif MaxDP == 0 and MaxPDP == 0 then
		return GetGradeFromPercent(0)
	elseif PScore == MaxPDP then
		return 'Grade_Tier01'
	elseif DPScore == MaxDP then
		return 'Grade_Tier02'
	else
		return GetGradeFromPercent(DPScore/MaxDP)
	end;
end;

function PJudge(pn,judge)
	return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores(judge)
end; 
function PHJudge(pn,judge)
	return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetHoldNoteScores(judge)
end;

function WifeToPercentPacemaker(params)
	return (-(params.WifeDifferential-params.CurWifeScore ))*(params.TotalPercent/(100*params.CurWifeScore)) * 100
end

function WifeToPercentUser(params)
	return string.format("%5.2f",params.TotalPercent)
end

local graphx = SCREEN_WIDTH -- Location of graph, graph is aligned to right.
local graphy = SCREEN_HEIGHT-80 -- Location of scoregraph bottom (aka: 0% line)
local graphheight = 300 -- scoregraph height (aka: height from 0% to max)
local graphwidth = 100+40 -- width of scoregraph, minimum of 100 recommended to avoid overlapping text.

local currentbarx = graphx-10
local currentbarwidth = graphwidth*0.2

local pacemakerbarx = graphx-23
local pacemakerbarwidth = graphwidth*0.2

local bestcorebarx = graphx-10
local bestcorebarwidth = graphwidth*0.2

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

local isEnable = true -- playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GraphBestScore

if isEnable then
	currentbarx = graphx-10
	currentbarwidth = graphwidth*0.2

	pacemakerbarx = graphx-23
	pacemakerbarwidth = graphwidth*0.2
end

P1Fail = false

-- copy+paste galore
local t = Def.ActorFrame {

	----------------
	-- Judgecount --
	----------------

	-- ehh it's removed because there already a judgecount in 'til death

	-----------------------------------------
	-- ScoreGraph / Ghost Score / AvgScore --
	-----------------------------------------

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
				if graphmode == "DP" then
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
				if graphmode == "DP" then
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
				if graphmode == "DP" then
					self:settext('Rank AAA Pass');
						--self:visible(true);
				else
					self:visible(true)
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if graphmode == "DP" and playedgrade['playedAAA'] == false then
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
				if graphmode == "DP" then
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
				if graphmode == "DP" then
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
				if graphmode == "DP" then
					self:settext('Rank AA Pass');
						--self:visible(true);
				else
					self:visible(true)
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if graphmode == "DP" and playedgrade['playedAA'] == false then
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
				if graphmode == "DP" then
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
				if graphmode == "DP" then
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
				if graphmode == "DP" then
					self:settext('Rank A Pass');
						--self:visible(true);
				else
					self:visible(true)
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if graphmode == "DP" and playedgrade['playedA'] == false then
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
				if graphmode == "DP" then
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
				if graphmode == "DP" then
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
				if graphmode == "DP" then
					self:settext('Rank B Pass');
					--self:visible(true);
				else
					self:visible(true)
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if graphmode == "DP" and playedgrade['playedB'] == false then
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
				if graphmode == "DP" then
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
				if graphmode == "DP" then
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
				if graphmode == "DP" then
					self:settext('Rank C Pass');
						--self:visible(true);
				else
					self:visible(true)
				end;
			end;
			JudgmentMessageCommand=function(self, params)
				if graphmode == "DP" and playedgrade['playedC'] == false then
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
		LoadFont("Common Normal") .. { -- TargetScore
			Name="TargetScore";
			InitCommand=function(self)
				self:x(pacemakerbarx-graphwidth*0.3):y(graphy+10):zoom(0.45):diffuse(color("#ff9999"))
			end;
			BeginCommand=function(self)
					self:settext('%0')
			end;
			JudgmentMessageCommand=function(self, params)
				local score = (-(params.WifeDifferential-params.CurWifeScore ))*(params.TotalPercent/(100*params.CurWifeScore))

				self:settext('%'..string.format("%5.2f",score * 100))
				self:visible(true)
			end;
		};
		Def.Quad{ --CurrentScoreBar
			Name="CurrentScoreBar";
			InitCommand=function(self)
				self:x(currentbarx-graphwidth*0.7):y(graphy):zoomx(currentbarwidth):diffuse(color("#99ccff")):vertalign(bottom):visible(true):diffuseshift():effectcolor1(color("0.5625,0.75,1,0.5")):effectcolor2(color("0.5625,0.75,1,0.4")):effectperiod(2)
			end;
			JudgmentMessageCommand=function(self, params)
				local score = (params.TotalPercent/100*(graphheight-1))+1
				if score >= 1 then
					self:zoomtoheight(score);
					self:visible(true);
				end
			end;
		};
		LoadFont("Common Normal") .. { -- CurrentScore
			Name="CurrentScore";
			InitCommand=function(self)
				self:x(currentbarx-graphwidth*0.7):y(graphy+10):zoom(0.45):diffuse(color("#99ccff"))
			end;
			BeginCommand=function(self)
				self:settext('%0')
			end;
			JudgmentMessageCommand=function(self, params)
				if params.TotalPercent >= 1 then
					self:settext('%'..string.format("%5.2f",params.TotalPercent))
					self:visible(true)
				end
			end;
		};
		Def.Quad{ -- best score graph
			Name="BestScoreBar";
			InitCommand=function(self)
				self:x(bestcorebarx-graphwidth*0.1):y(graphy):zoomx(currentbarwidth):diffuse(color("#008000")):vertalign(bottom):visible(true):diffuseshift():effectcolor1(color("0,250,154,0.3")):effectcolor2(color("0,250,154,0.3")):effectperiod(2)
			end;
			BeginCommand=function(self)
				local score = GetDisplayScore()

				if score then
					local truescore = (score:GetWifeScore() * 10000) / 100 / 100

					self:zoomtoheight((truescore*(graphheight-1))+1);
					self:visible(true)
				end
			end
		};
		LoadFont("Common Normal") .. { -- Bestscore score
			InitCommand=function(self) 
				self:x(bestcorebarx-graphwidth*0.1):y(graphy+10):zoom(0.45):diffuse(color("#008000"))
			end;
			BeginCommand=function(self)
				local score = GetDisplayScore()

				if (score) then
					self:settext('%'..tostring(math.floor((score:GetWifeScore() * 10000) / 100)))
				end
			end
		};
		LoadFont("Common Normal") .. { -- GraphType (Target)
			InitCommand=function(self)
				self:x(graphx-graphwidth/2):y(graphy+25):zoom(0.45):diffuse(color("#ff9999"))
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
	};
};

local PMdisplay = themeConfig:get_data().PMDisplay

if PMdisplay == "1" then
	return Def.ActorFrame {}
else
	return t
end

