extends Control

var _default_url = "wss://127.0.0.1:8081"

var _client = WebSocketClient.new()

func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")


func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)


func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	_client.get_peer(1).put_packet("Test packet".to_utf8())


func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	print("Got data from server: ", _client.get_peer(1).get_packet().get_string_from_utf8())


func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()


func _connect(url):
	print("Trying to connect to URL: ", url)
	# Initiate connection to the given URL.
	var err = _client.connect_to_url(url, ["lws-mirror-protocol"])
	if err != OK:
		print("Unable to connect")
		set_process(false)


func _get_current_url():
	if $ControlBaseContainer/GridContainer/CustomServerCheckBox.is_pressed():
		var url = $ControlBaseContainer/GridContainer/ServerAddressInput.text
		if not url.begins_with("wss://"):
			url = "wss://" + url
		$ControlBaseContainer/GridContainer/ServerAddressInput.set_text(url)
		return url
	return _default_url


func _on_RegisterButton_pressed():
	_connect(_get_current_url())
	# TODO: register


func _on_LoginButton_pressed():
	_connect(_get_current_url())
	# TODO: login


func _on_CustomServerCheckBox_toggled(button_pressed):
	if button_pressed:
		$ControlBaseContainer/GridContainer/ServerAddressInput.show()
		$ControlBaseContainer/GridContainer/ServerAddressLabel.show()
	else:
		$ControlBaseContainer/GridContainer/ServerAddressInput.hide()
		$ControlBaseContainer/GridContainer/ServerAddressLabel.hide()
