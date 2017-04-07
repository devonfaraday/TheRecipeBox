//
//  sampleCode.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 4/4/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation


/*
 
 func toggleSubscriptionTo(messageNamed message: Message,
 completion: @escaping ((_ success: Bool, _ isSubscribed: Bool, _ error: Error?) -> Void) = { _,_,_ in }) {
 
 guard let subscriptionID = message.cloudKitRecordID?.recordName else {
 completion(false, false, nil)
 return
 }
 
 cloudKitManager.fetchSubscription(subscriptionID) { (subscription, error) in
 
 
 if subscription != nil {
 self.removeSubscriptionTo(messageNamed: message) { (success, error) in
 message.score -= 1
 completion(success, false, error)
 }
 } else {
 self.addSubscriptionTo(messageNamed: message, alertBody: "Someone commented on a message you voted for! 👍") { (success, error) in
 message.score += 1
 completion(success, true, error)
 }
 }
 
 */



/*
 
 self.addSubscriptionTo(messagesForChat: chat, alertBody: "New 💬 on a chat! 🙏 ") { (success, error) in
 if let error = error {
 NSLog("Unable to save comment subscription: \(error)")
 }
 chat.messages.append(message)
 completion?(chat)
 }
 
 */
