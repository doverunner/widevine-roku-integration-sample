' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

'*******************************************************************************
'#
'# Copyright 2017 INKA ENTWORKS. All Rights Reserved.
'#
'# This project is based on a ROKU SAMPLE APP, hero-grid-channel.zip
'# You can get the base code at https://github.com/rokudev/sample-channels/
'#
'*******************************************************************************

sub main()
	screen = CreateObject("roSGScreen")
	m.port = CreateObject("roMessagePort")
	screen.setMessagePort(m.port)
	scene = screen.CreateScene("SplashScene")
	screen.show()

	while(true)
		msg = wait(0, m.port)
		msgType = type(msg)
		if msgType = "roSGScreenEvent"
			if msg.isScreenClosed() then return
		end if
	end while
end sub
 