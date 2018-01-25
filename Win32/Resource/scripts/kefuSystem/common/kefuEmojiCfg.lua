
local Emoji = {}

--emoji开始的unicode值
Emoji.StartIdx = 0x1F201


Emoji.Name = {
	"一脸懵逼",
	"不开心",
	"亲亲",
	"亲亲2",
	"亲亲3",
	"亲亲4",
	"受伤",
	"可爱",
	"可爱2",
	"吐舌头",
	"吐舌头2",
	"吐舌头3",
	"咧嘴",
	"哦",
	"哦2",
	"哭",
	"哭笑不得",
	"哼",
	"嘻嘻",
	"嘿嘿",
	"困",
	"困2",
	"墨镜",
	"大笑",
	"天使",
	"害怕",
	"小恶魔",
	"开心",
	"开心2",
	"开心3",
	"怒",
	"怒2",
	"怒3",
	"感冒",
	"扮鬼",
	"拍手",
	"无奈",
	"无奈2",
	"无奈3",
	"无奈地笑",
	"无表情",
	"无语",
	"无语2",
	"无语3",
	"无语4",
	"无语5",
	"无语6",
	"晕",
	"晕2",
	"汗",
	"汗2",
	"温馨",
	"爱心脸",
	"白脸",
	"眨眼",
	"翻白眼",
	"肚子疼",
	"胜利",
	"见钱眼开",
	"见鬼了",
	"鄙视脸",
	"难过2",
	"馋",
	"黑脸",
	"鼻涕",
	"拜托",
	"爱心",
	"赞",
	"亲亲猫",
	"侧脸猫",
	"哭笑不得猫",
	"嘿嘿猫",
	"大笑猫",
	"开心猫",
	"惊讶猫",
	"色眯眯猫",
	"鼻涕猫",
	"兔子",
	"小鸡",
	"熊",
	"熊猫",
	"狗",
	"狗2",
	"猪",
	"猫",
	"猴子",
	"老虎",
	"老鼠",
	"青蛙",
	"马",
}

Emoji.Num = #Emoji.Name
Emoji.NameToId = {}

for i, v in ipairs(Emoji.Name) do
	v = string.format("e%s", v)
	Emoji.NameToId[v] = Emoji.StartIdx + i - 1
end

return Emoji