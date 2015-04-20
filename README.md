Rabbit4MT4
==========

This project contains some examples to work with Metatrader 4 (MT4 build >= 500) and RabbitMQ.


Install
-------
* Install Erlang (OTP 17.0)
* Install RabbitMQ (3.3.1)
* Install Visual Studio 2013
* Install Python (Anaconda Python or Enthought Python)
* Open `Rabbit4mt4.sln`
* Install missing packages

	https://www.nuget.org/packages/UnmanagedExports
	
	To install Unmanaged Exports (DllExport for .Net), run the following command in the Package Manager Console
	
	`PM> Install-Package UnmanagedExports`

* Build the "Rabbit4mt4" project it should create unmanaged DLL into `output\bin` folder.

* Put files from `testUnmanagedDLL\testUnmanagedDLL\bin\Debug\` to `<MQL4_directory>\Libraries`

* Also copy files from `testUnmanagedDLL\DllExport\` to `<MQL4_directory>\Libraries`

* Copy scripts, EA as provided in `Rabbit4mt4\emit\MQL4` in directory to respective MQL4 folders.

* Attach the `rabbit4mt4_ticks_emit` EA to EURUSD chart

* Run Python script `receive\Python\receive_ticks.py` (just click on `receive_ticks.bat`)

* You will need before install some package such a `pika`

	`$ pip install pika`

* Incoming ticks should be displayed in terminal console.

Video
-----
Some videos to show this project in action

* Realtime Metatrader 5 DOM (orderbook) plot with Python, Pandas, PyQtGraph and RabbitMQ

	https://www.youtube.com/watch?v=4CnowC3UH4s
	
* Metatrader 4 JSON RPC with RabbitMQ and MySQL

	https://www.youtube.com/watch?v=2CFt9tGjD8M

Done
----
* SendTick

	`mt4_demo01_123456.event.ticks.eurusd`

* SendMessage

	send message (JSON) from MT4 to RabbitMQ

	`mt4_demo01_123456.event.message`

* SendMessage example with bid / ask

* SendMessage example with an indicator value

* JSON message creation - see dom_toolbox.mqh

	is used to cleanly generate JSON message

* Plot of DOM (orderbook) from MT5 with Python, Pandas, Qt (PySide) and PyQtGraph

	see `receive\Python\receive_dom_plot_pyqtgraph`

	parse JSON and pretty print dict

* Dictionary (map) - see hashmap http://www.lordy.co.nf/mql4/

	HashMap is an in memory key/value store

	can be used to store in memory MAE, MFE of each opened trades

	can be used to store opened orders to see if they are modified (SL, TP...)

* JSON parser http://www.lordy.co.nf/mql4/

    can be used to parse JSON RPC request on MQL side


ToDo
----

* Python receive
	logging to file (`logging.config`)
	
* DOM from MT5 (MQL5) (Alpari UK)
	compress data
	use `JSON_List` instead of `JSON_Dictv
	separate bids and asks
	remove 1 and 2 (type = bid or ask)

* OrderReceived / OrderModified / OrderClosed

	EA to send message when new order, order modified or order closed
	
		see `rabbit4mt4_orders_events.mqh` (master)
		
		`mt4_demo01_123456.events.orders.received`
		
		`mt4_demo01_123456.events.orders.modified`
		
		`mt4_demo01_123456.events.orders.closed`

* OrderSend / OrderModify / OrderClose

	JSON RPC? (return ticket - )

	generate a random number to be sure that return is about your request (slave)
	
	(this part will be hard)
	
* Get account information AccountBalance Equity ... History (`MODE_TRADE` and `MODE_HISTORY`) using JSON RPC request

* Trade copier MT4

	MT4 master (send message to RabbitMQ such as `OrderReceived` / `OrderModified` / `OrderClosed`)

	MT4 slave (receive message)
	
	(maybe) a script between (?)

* JForex master

* JForex slave
	
* Security

	limit access for a given user

* JSON parser use an other implementation than ydrol's implementation

	see https://www.mql5.com/en/forum/28928
