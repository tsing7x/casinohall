local FacebookFriend = class(require('app.data.headData'))

addProperty(FacebookFriend, "id", "")
addProperty(FacebookFriend, "nickname", "")
addProperty(FacebookFriend, "money", "")
-- addProperty(FacebookFriend, "url", "")
addProperty(FacebookFriend, "check", false)
addProperty(FacebookFriend, "urlMd5", "")

addProperty(FacebookFriend, "headUrl", "")

return FacebookFriend