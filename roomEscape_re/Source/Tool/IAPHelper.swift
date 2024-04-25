//
//  IAPHelper.swift
//  locallage
//
//  Created by hoonKim on 2020/08/10.
//  Copyright © 2020 DongSeok. All rights reserved.
//
import UIKit
import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void
public typealias ProductsPayCompletionHandler = (_ success: Bool) -> Void

extension Notification.Name {
  static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
}


open class IAPHelper: NSObject {
  private let productIdentifiers: Set<ProductIdentifier>
  private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
  private var productsRequest: SKProductsRequest?
  private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
  private var productsPayHandler: ProductsPayCompletionHandler?
  private var productsRestoreHandler: ProductsPayCompletionHandler?
  
  public init(productIds: Set<ProductIdentifier>) {
    productIdentifiers = productIds
    for productIdentifier in productIds {
      let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
      
      if purchased {
        purchasedProductIdentifiers.insert(productIdentifier)
        print("Previously purchased: \(productIdentifier)")
      } else {
        print("Not purchased: \(productIdentifier)")
      }
    }
    
    super.init()
    SKPaymentQueue.default().add(self)
  }
}

extension IAPHelper {
  public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
    productsRequest?.cancel()
    productsRequestCompletionHandler = completionHandler
    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    productsRequest!.delegate = self
    productsRequest!.start()
  }
  
  public func buyProduct(_ product: SKProduct,_ handler :@escaping ProductsPayCompletionHandler) {
    productsPayHandler = handler
    print("Buying \(product.productIdentifier)...")
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }
  
  public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
    return purchasedProductIdentifiers.contains(productIdentifier)
  }
  
  public class func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments()
  }
  
  public func restorePurchases() {
//    productsRestoreHandler = handler
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
}

extension IAPHelper: SKProductsRequestDelegate {
  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    print("Loaded list of products...")
    let products = response.products
    print("produt: \(products)")
    productsRequestCompletionHandler?(true, products)
    clearRequestAndHandler()
    
    for p in products {
      print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.intValue)")
    }
  }
  
  public func request(_ request: SKRequest, didFailWithError error: Error) {
    print("Failed to load list of products.")
    print("Error: \(error.localizedDescription)")
    productsRequestCompletionHandler?(false, nil)
    clearRequestAndHandler()
  }
  
  private func clearRequestAndHandler() {
    productsRequest = nil
    productsRequestCompletionHandler = nil
  }
}

extension IAPHelper: SKPaymentTransactionObserver {
  public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      print(transaction.transactionState)
      switch (transaction.transactionState) {
      case .purchased:
        complete(transaction: transaction)
        break
      case .failed:
        fail(transaction: transaction)
        break
      case .restored:
        restore(transaction: transaction)
        break
      case .deferred:
        break
      case .purchasing:
//        complete(transaction: transaction)
        break
      @unknown default:
        fatalError()
      }
    }
  }
  
  private func complete(transaction: SKPaymentTransaction){
    print("complete... \(transaction.payment.productIdentifier)")
//    deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
    productsPayHandler?(true)
  }
  
//  private func alreadyPurchase(transaction: SKPaymentTransaction){
//    print("alreadyPurchase... \(transaction.payment.productIdentifier)")
//    deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
//    SKPaymentQueue.default().finishTransaction(transaction)
//    productsPayHandler?(true)
//  }
  
  private func restore(transaction: SKPaymentTransaction) {
    guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
    print("restore... \(productIdentifier)")
//    deliverPurchaseNotificationFor(identifier: productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
    productsRestoreHandler?(true)
  }
  
  private func fail(transaction: SKPaymentTransaction) {
    print("fail...")
    
    if let transactionError = transaction.error as NSError?,
       let localizedDescription = transaction.error?.localizedDescription,
       transactionError.code != SKError.paymentCancelled.rawValue {
      print("Transaction Error: \(localizedDescription)")
    }
    
    SKPaymentQueue.default().finishTransaction(transaction)
    productsPayHandler?(false)
    productsRestoreHandler?(false)
  }
  
  private func deliverPurchaseNotificationFor(identifier: String?) {
    guard let identifier = identifier else { return }
    
    purchasedProductIdentifiers.insert(identifier)
    UserDefaults.standard.set(true, forKey: identifier)
    NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: identifier)
  }

  func receiptValidation(_ validation: @escaping (Bool) -> Void) {
    let verifyReceiptURL = "https://sandbox.itunes.apple.com/verifyReceipt"
    let receiptFileURL = Bundle.main.appStoreReceiptURL
    let receiptData = NSData(contentsOf: receiptFileURL!)
    let recieptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    let jsonDict: [String: AnyObject] = [
        "receipt-data" : recieptString as AnyObject, "password" : "b9ad3754777b45729793e45b26053fc2" as AnyObject]
    do {
      let requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
      let storeURL = URL(string: verifyReceiptURL)!
      var storeRequest = URLRequest(url: storeURL)
      storeRequest.httpMethod = "POST"
      storeRequest.httpBody = requestData
      let session = URLSession(configuration: URLSessionConfiguration.default)
      let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in

        do {
          if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary{
            print("Response :",jsonResponse)
            if let date = self?.getExpirationDateFromResponse(jsonResponse) {
              print(date)
              // 마지막 구매 receipt의 expires_date와 현재 날짜와 비교하여 확인
              validation(date > Date())
            }
          }
        } catch let parseError {
          print(parseError)
          validation(false)
        }
      })
      task.resume()
    } catch let parseError {
      print(parseError)
      validation(false)
    }
  }

  func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {

    if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {

      let lastReceipt = receiptInfo.firstObject as! NSDictionary
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"

      if let expiresDate = lastReceipt["expires_date"] as? String {
        return formatter.date(from: expiresDate)
      }

      return nil
    }
    else {
      return nil
    }
  }
}
