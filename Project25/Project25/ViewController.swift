//
//  ViewController.swift
//  Project25
//
//  Created by Usama Fouad on 01/02/2021.
//

import MultipeerConnectivity
import UIKit

class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate {
    

    var images = [UIImage]()
    
    // MCPeerID: identifies each user uniquely in a session.
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    // MCSession: The manager class that handles all multipeer connectivity.
    var mcSession: MCSession?
    
    // MCAdvertiserAssistant | MCNearbyServiceAdvertiser: Used when creating a session, telling others that we exist and handling invitations.
    var mcAdvertiserAssistant: MCNearbyServiceAdvertiser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Selfi Camera"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        
        // Our peer ID is used to create the session, along with the encryption option of .required to ensure that any data transferred is kept safe.
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }
    
    func startHosting(action: UIAlertAction) {
        mcAdvertiserAssistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "hws-project25")
        mcAdvertiserAssistant?.delegate = self
        mcAdvertiserAssistant?.startAdvertisingPeer()
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let ac = UIAlertController(title: "Project25", message: "'\(peerID.displayName)' wants to connect", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak self] _ in
            invitationHandler(true, self?.mcSession)
        }))
        ac.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: { _ in
            invitationHandler(false, nil)
        }))
        present(ac, animated: true)
    }
    
    func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        // MCBrowserViewController: Used when looking for sessions, showing users who is nearby and letting them join.
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        
        return cell
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        
        images.insert(image, at: 0)
        collectionView.reloadData()
        
        // 1. Check if we have an active session we can use.
        guard let mcSession = mcSession else { return }
        
        // 2. Check if there are any peers to send to.
        if mcSession.connectedPeers.count > 0 {
            // 3. Convert the new image to a Data object.
            if let imageData = image.pngData() {
                do {
                    // 4. Send it to all peers, ensuring it gets delivered.
                    // The code to ensure data gets sent intact to all peers, as opposed to having some parts lost in the ether, is just to use transmission mode .reliable – nothing more.
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch {
                    // 5. Show an error message if there's a problem.
                    let ac = UIAlertController(title: "Send Error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
    }
    
    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Send Text message", style: .default, handler: promptForTextMessage))
        ac.addAction(UIAlertAction(title: "Show connected peers", style: .default, handler: showConnectedPeers))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func promptForTextMessage(action: UIAlertAction) {
        let ac = UIAlertController(title: "Enter Text message", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Send", style: .default) { [weak self, weak ac] _ in
            guard let message = ac?.textFields?[0].text else { return }
            self?.send(message)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func send(_ message: String) {
        guard let mcSession = mcSession else { return }
        
        if mcSession.connectedPeers.count > 0 {
            let textData = Data(message.utf8)
            do {
                try mcSession.send(textData, toPeers: mcSession.connectedPeers, with: .reliable)
            } catch {
                let ac = UIAlertController(title: "Send Error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        }
    }
    
    func showConnectedPeers(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        
        let ac = UIAlertController(title: "Connected peers", message: nil, preferredStyle: .actionSheet)
        
        for peer in mcSession.connectedPeers {
            ac.addAction(UIAlertAction(title: "\(peer.displayName)", style: .default))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        // When this method is called, you'll be told what peer changed state, and what their new state is. There are only three possible session states: not connected, connecting, and connected.
        case .connected:
            showStatusAlert(peerName: peerID.displayName, isConnected: true)
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            showStatusAlert(peerName: peerID.displayName, isConnected: false)
            print("Not Connected: \(peerID.displayName)")
        @unknown default:
            print("Unkown state recieved: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Once the data arrives at each peer, the method session(_:didReceive:fromPeer:) will get called with that data, at which point we can create a UIImage from it and add it to our images array. There is one catch: when you receive data it might not be on the main thread, and you never manipulate user interfaces anywhere but the main thread
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data) {
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
            } else {
                let textMessage = String(decoding: data, as: UTF8.self)
                DispatchQueue.main.async { [weak self] in
                    let ac = UIAlertController(title: "Message from \(peerID.displayName)", message: textMessage, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self?.present(ac, animated: true)
                }
            }
        }
    }
    
    func showStatusAlert(peerName: String, isConnected: Bool) {
        let connectedStr = isConnected ? "connected" : "disconnected"
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "\(peerName) has \(connectedStr)", message: nil, preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            self?.present(ac, animated: true)
        }
    }


}

