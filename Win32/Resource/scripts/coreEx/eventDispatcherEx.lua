--扩充
Event.Socket        = Event.End;-- Socket

Event.Message       = Event.Socket + 1;

Event.ConsoleSocket = Event.Message + 1;-- 单机

--MixedTen-add
Event.ConnectTimeout= Event.ConsoleSocket + 1;

Event.onEventResume	= Event.ConnectTimeout + 1; --相当于android 的resume

Event.onEventPause	= Event.onEventResume + 1; --相当于android 的pause

-- Event.End           = Event.onEventPause + 1;

