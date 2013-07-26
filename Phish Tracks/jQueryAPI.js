function success(payload) {
	return JSON.stringify({
		success: true,
		data: payload
	});
}

function error(payload) {
	return JSON.stringify({
		success: false,
		data: payload
	});
}

NativeBridge.call("ready");
