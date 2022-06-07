import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iot_device_flutter/iot_center_client_dart.dart';
import 'package:iot_device_flutter/main.dart';
import 'package:iot_device_flutter/sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';

const iotCenterSharedPreferencesKey = "iot-center";
const defaultCenterUrl = "";

/// replace localhost with 10.0.2.2 for android devices
String fixLocalhost(String? url) {
  url ??= "http://localhost:5000";
  if (defaultTargetPlatform == TargetPlatform.android &&
      url.startsWith("http://localhost")) {
    return url.replaceAll("/localhost", "/10.0.2.2");
  }
  return url;
}

class HomePage extends StatefulWidget {
  const HomePage(
      {Key? key,
      required this.title,
      required this.client,
      this.saveClient,
      required this.sensors})
      : super(key: key);

  final String title;
  final IotCenterClient client;
  final Future Function(IotCenterClient client)? saveClient;
  final List<SensorInfo> sensors;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final urlController = TextEditingController();
  late final IotCenterClient client;

  connectClient() async {
    await client.configure();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    client = widget.client;

    urlController.text = client.iotCenterUrl;
    urlController.addListener(() {
      setState(() {
        client.disconnect();
        client.iotCenterUrl = urlController.text;
      });
      saveClient(client);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          Text(client.clientID),
          Text(client.clientConfig.influxUrl),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: urlController,
              ),
              TextButton(
                child: !client.connected
                    ? const Text("Connect")
                    : const Text("Connected"),
                onPressed: !client.connected ? connectClient : null,
              ),
            ],
          ),
          ...widget.sensors
              .map((SensorInfo sensor) => SwitchListTile(
                    // value: con.sensorIsWriting(sensor),
                    // onChanged: onChanged(sensor),
                    title: Text(sensor.name),
                    value: true,
                    onChanged: null,
                  ))
              .toList(),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
