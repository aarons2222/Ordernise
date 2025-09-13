//
//  SubscriptionManager.swift
//  Ordernise
//
//  Created by Aaron Strickland on 26/08/2025.
//

import SwiftUI
import StoreKit
internal import Combine

/// Subscription status enumeration
enum SubscriptionStatus {
    case unknown
    case notSubscribed
    case subscribed(productId: String, expirationDate: Date?)
    case expired
    case pending
    case revoked
}

/// Product information for subscriptions
struct SubscriptionProduct {
    let id: String
    let displayName: String
    let description: String
    let price: String
    let period: String
    let product: Product
}

@MainActor
class SubscriptionManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var subscriptionStatus: SubscriptionStatus = .unknown
    @Published var availableProducts: [SubscriptionProduct] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Constants
    static let shared = SubscriptionManager()
    
    private let productIDs: [String] = ["ordernisemonthly", "orderniseannual"]
    private let subscriptionGroupID = "21764785"
    
    // MARK: - Private Properties
    private var updateTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var isSubscribed: Bool {
        switch subscriptionStatus {
        case .subscribed:
            return true
        default:
            return false
        }
    }
    
    var hasActiveSubscription: Bool {
        switch subscriptionStatus {
        case .subscribed(_, let expirationDate):
            if let expirationDate = expirationDate {
                return expirationDate > Date()
            }
            return true
        default:
            return false
        }
    }
    
    var currentProductId: String? {
        switch subscriptionStatus {
        case .subscribed(let productId, _):
            return productId
        default:
            return nil
        }
    }
    
    // MARK: - Initialization
    private init() {
        // Start listening for transaction updates
        startTransactionListener()
        
        // Load products and check status on init
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
    }
    
    // MARK: - Public Methods
    
    /// Load available subscription products
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let storeProducts = try await Product.products(for: productIDs)
            
            availableProducts = storeProducts.compactMap { product in
                guard product.type == .autoRenewable else { return nil }
                
                return SubscriptionProduct(
                    id: product.id,
                    displayName: product.displayName,
                    description: product.description,
                    price: product.displayPrice,
                    period: formatSubscriptionPeriod(product.subscription?.subscriptionPeriod),
                    product: product
                )
            }.sorted { $0.id < $1.id }
            
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("Failed to load products: \(error)")
        }
        
        isLoading = false
    }
    
    /// Check current subscription status
    func checkSubscriptionStatus() async {
        do {
            let statuses = try await Product.SubscriptionInfo.status(for: subscriptionGroupID)
            await updateSubscriptionStatus(from: statuses)
            
            print("Subscription Status: \(statuses)")
        } catch {
            errorMessage = "Failed to check subscription status: \(error.localizedDescription)"
            print("Failed to check subscription status: \(error)")
            subscriptionStatus = .unknown
        }
    }
    
    /// Purchase a subscription product
    func purchaseProduct(_ product: Product) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await checkSubscriptionStatus()
                isLoading = false
                return true
                
            case .userCancelled:
                isLoading = false
                return false
                
            case .pending:
                subscriptionStatus = .pending
                isLoading = false
                return false
                
            @unknown default:
                errorMessage = "Unknown purchase result"
                isLoading = false
                return false
            }
            
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            print("Purchase failed: \(error)")
            isLoading = false
            return false
        }
    }
    
    /// Restore purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            print("Failed to restore purchases: \(error)")
        }
        
        isLoading = false
    }
    
    /// Get product by ID
    func getProduct(for productId: String) -> SubscriptionProduct? {
        return availableProducts.first { $0.id == productId }
    }
    
    // MARK: - Private Methods
    
    private func startTransactionListener() {
        updateTask = Task(priority: .background) {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    await checkSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private func updateSubscriptionStatus(from statuses: [Product.SubscriptionInfo.Status]) async {
        guard !statuses.isEmpty else {
            subscriptionStatus = .notSubscribed
            return
        }
        
        // Find the active subscription
        let activeSubscription = statuses.first { status in
            switch status.state {
            case .subscribed, .inGracePeriod, .inBillingRetryPeriod:
                return true
            default:
                return false
            }
        }
        
        if let active = activeSubscription {
            do {
                let transaction = try checkVerified(active.transaction)
                // Get the actual expiration date from the transaction
                let expirationDate = transaction.expirationDate
                
                subscriptionStatus = .subscribed(
                    productId: transaction.productID,
                    expirationDate: expirationDate
                )
            } catch {
                print("Failed to verify active subscription transaction: \(error)")
                subscriptionStatus = .unknown
            }
        } else {
            // Check if any subscription is expired or revoked
            let hasExpired = statuses.contains { status in
                switch status.state {
                case .expired:
                    return true
                default:
                    return false
                }
            }
            
            let hasRevoked = statuses.contains { status in
                switch status.state {
                case .revoked:
                    return true
                default:
                    return false
                }
            }
            
            if hasRevoked {
                subscriptionStatus = .revoked
            } else if hasExpired {
                subscriptionStatus = .expired
            } else {
                subscriptionStatus = .notSubscribed
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.unverifiedTransaction
        case .verified(let safe):
            return safe
        }
    }
    
    private func formatSubscriptionPeriod(_ period: Product.SubscriptionPeriod?) -> String {
        guard let period = period else { return "" }
        
        switch period.unit {

        case .month:
            return period.value == 1 ? "Monthly" : "\(period.value) months"
        case .year:
            return period.value == 1 ? "Yearly" : "\(period.value) years"
        @unknown default:
            return "Unknown"
        }
    }
    
    deinit {
        updateTask?.cancel()
    }
}

// MARK: - Subscription Errors
enum SubscriptionError: LocalizedError {
    case unverifiedTransaction
    case productNotFound
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .unverifiedTransaction:
            return "Transaction could not be verified"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}

// MARK: - Subscription Status Extensions
extension SubscriptionStatus {
    var displayText: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .notSubscribed:
            return "Not Subscribed"
        case .subscribed(let productId, _):
            return "Subscribed (\(productId))"
        case .expired:
            return "Expired"
        case .pending:
            return "Pending"
        case .revoked:
            return "Revoked"
        }
    }
}
