//
//  Session.swift
//  BonjourSample
//
//  Created by Chris Eidhof on 10.02.22.
//

import Foundation
import MultipeerConnectivity

/// A multipeer session that automatically connects to anything it finds.
public final class MultipeerSession<Message: Codable>: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    @Published public var connected = false
    
    private let serviceType = "objcio-dqs"
    private let peerID = MCPeerID(displayName: ProcessInfo.processInfo.hostName)

    let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    
    public private(set) var receiveStream: AsyncStream<Message>! = nil
    private var onReceive: ((Data) -> ())?
    
    deinit {
        session.disconnect()
    }
    
    public override init() {
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        
        super.init()
        
        receiveStream = AsyncStream<Message> { cont in
            self.onReceive = { data in
                let value = try! JSONDecoder().decode(Message.self, from: data)
                cont.yield(value)
            }
        }
        
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        
        browser.startBrowsingForPeers()
        advertiser.startAdvertisingPeer()
    }
    
    public func send(_ message: Message) throws {
        guard !session.connectedPeers.isEmpty else { return }
        let data = try JSONEncoder().encode(message)
        try session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    // Browser delegate
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer")
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    // Advertiser delegate
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
    
    // Session delegate
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        fatalError()
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        onReceive?(data)
    }
    
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected")
        case .connecting:
            print("Connecting")
        case .notConnected:
            print("Not connected")
        default:
            print("Unknown")
        }
        DispatchQueue.main.async {
            self.connected = !session.connectedPeers.isEmpty
        }
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        fatalError()
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        fatalError()
    }
}
