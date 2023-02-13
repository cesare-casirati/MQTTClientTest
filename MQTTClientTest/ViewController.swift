//
//  ViewController.swift
//  MQTTClientTest
//
//  Created by mac on 23/01/23.
//

import UIKit

import CocoaMQTT

class ViewController: UIViewController {
        
    // costante con il dominio del broker di test
    let defaultHost = "broker-cn.emqx.io"

    // creazione dell'uistanza dell'oggetto MQTT, è una variabile
    // è un 'optional'
    var mqtt: CocoaMQTT?
    
    func mqttSetting() {

        // crea un identificativo del client univoco
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        
        // imposta le caretteristiche del collegamento al broker
        mqtt = CocoaMQTT(clientID: clientID, host: defaultHost, port: 1883)
        mqtt!.logLevel = .debug
        mqtt!.username = ""
        mqtt!.password = ""
        mqtt!.willMessage = CocoaMQTTMessage(topic: "/will", string: "dieout")
        mqtt!.keepAlive = 60

        // connette il client al broker
        _ = mqtt!.connect()
        
    }
    
    @IBOutlet var inputMessage: UITextField!
    
    // collega il pulsante di invio
    @IBOutlet var sendButton: UIButton!
        
    // definisce l'azione del pulsante: invio di un messaggio MQTT
    // testo in formato JSON
    // payload = data e ora attuali
    // topic   = "2023/4G/command"
    @IBAction func sendMessage() {
        
        // crea un testo per il messaggio da inviare
        //let message = getCurrentDateAndTime()
        let message = inputMessage.text!
        
        inputMessage.resignFirstResponder()

        // è un messaggio in formato JSON
        let publishProperties = MqttPublishProperties()
        publishProperties.contentType = "JSON"

        // definisco un topic per il messaggio
        let topic = "2023/4G/command"
        mqtt!.publish(topic, withString: message, qos: .qos1)
        
        }

    // disconnette il client dal broker
    func mqttDisconnect() {
        
        mqtt!.disconnect()
        
    }

    // restituisce data e ora attuali in formato stringa
    func getCurrentDateAndTime() -> String {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .long
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
        
    }
     
    // aggiorna il metodo da eseguire al caricamento del viewController
    override func viewDidLoad() {
        
        // eredita il metodo originale
        super.viewDidLoad()
        
        inputMessage.returnKeyType = .done
        inputMessage.becomeFirstResponder()
        inputMessage.delegate = self
        
        // al caricamento del ViewController si collega al broker
        mqttSetting()
        
    }
    
    // aggiorna il metodo da eseguire all'eliminazione del viewController
    override func viewDidDisappear(_ animated: Bool) {
        
        // eredita il metodo originale
        super.viewDidDisappear(animated)
        
        // alla dismisisone del viewController si scollega dal broker
        mqttDisconnect()
        
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
