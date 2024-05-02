-- Copyright (c) 2024 Joshua 'Kkthnx' Russell
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer.
--
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
-- ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
-- ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- Addon Name: BubbleColorizer

local TextureUVs = {
	"TopLeftCorner",
	"TopRightCorner",
	"BottomLeftCorner",
	"BottomRightCorner",
	"TopEdge",
	"BottomEdge",
	"LeftEdge",
	"RightEdge",
}

local BubbleColorizer = CreateFrame("Frame")

function BubbleColorizer:FormatBubbles(frame, fontString)
	local r, g, b, a = fontString:GetTextColor()
	for _, edge in ipairs(TextureUVs) do
		frame[edge]:SetVertexColor(r, g, b, a)
	end
	frame.Tail:SetVertexColor(r, g, b, a)
	frame.Tail:SetTexture("")
end

function BubbleColorizer:IterateChatBubbles(callback)
	for _, chatBubbleObj in ipairs(C_ChatBubbles.GetAllChatBubbles(false)) do
		local chatBubble = chatBubbleObj:GetChildren()
		if chatBubble and chatBubble.String and chatBubble.String:GetObjectType() == "FontString" then
			if type(callback) == "function" then
				callback(self, chatBubble, chatBubble.String)
			end
		end
	end
end

local BUBBLE_SCAN_THROTTLE = 0.1

function BubbleColorizer:OnModuleEnable()
	self.update = self.update or CreateFrame("Frame")
	self.throttle = BUBBLE_SCAN_THROTTLE

	self.update:SetScript("OnUpdate", function(frame, elapsed)
		self.throttle = self.throttle - elapsed
		if frame:IsShown() and self.throttle < 0 then
			self.throttle = BUBBLE_SCAN_THROTTLE
			self:IterateChatBubbles(self.FormatBubbles)
		end
	end)

	-- Restore defaults
	for _, chatBubbleObj in ipairs(C_ChatBubbles.GetAllChatBubbles(false)) do
		local chatBubble = chatBubbleObj:GetChildren()
		if chatBubble and chatBubble.String and chatBubble.String:GetObjectType() == "FontString" then
			self:FormatBubbles(chatBubble, chatBubble.String)
		end
	end
end

BubbleColorizer:OnModuleEnable()
