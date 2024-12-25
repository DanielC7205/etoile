//
//  SignInViewController.swift
//  tvos
//
//  Created by Juliette Bernheisel on 8/29/24.
//

import SwiftUI
import JellyfinAPI
import OSLog
import SimpleKeychain

struct SignInViewController: View {
    
    
    @State var page: SigninPage = .instance
    @State var instance = ""
    @State var code = ""
    @State var username = ""
    @State var password = ""
    @State var isError = false
    @Binding var done: Bool
    
    var body: some View {
        if page == .instance {
            VStack {
                Text("Welcome to Etoile")
                    .accessibilityIdentifier("welcome")
                TextField("Instance url", text: $instance)
                    .accessibilityIdentifier("instanceUrl")
                Button(action: {
                    Task {
                        let keychain = SimpleKeychain(service: "etoile")
                        // Saving the info!
                        guard let instanceSafe = URL(string: instance) else { return }
                        try keychain.set(instanceSafe.absoluteString ?? "", forKey: "instance")
                        // Create a QuickConnect object with a JellyfinClient
                        let configuration = await JellyfinClient.Configuration(url: instanceSafe, client: "Etoile", deviceName: "TV", deviceID: UUID().uuidString, version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                        let client = JellyfinClient(configuration: configuration)
                        
                        let quickConnect = QuickConnect(client: client, pollInterval: 1, maxPolls: 120)
                        
                        let quickConnectState = Task {
                            // Listen to QuickConnect states with async/await or Combine
                            for await state in quickConnect.$state.values {
                                switch state {
                                case let .polling(code: code):
                                    print(code)
                                    await MainActor.run {
                                        self.page = .key
                                        self.code = code
                                    }
                                case let .authenticated(secret: secret):
                                    // Sign in with the Quick Connect secret
                                    do {
                                        try await client.signIn(quickConnectSecret: secret)
                                        await MainActor.run {
                                            do {
                                                // Saving the info!
                                                try keychain.set(client.accessToken ?? "", forKey: "token")
                                                    // Then move view controllers
                                                    page = .pull

                                            } catch {
                                                Logger().error("Error writing login to keychain \(error)")
                                            }
                                        }
                                    } catch {
                                        Logger().error("Error signing in \(error)")
                                    }
                                default:
                                    print("")
                                }
                            }
                        }
                        
                        // Start the Quick Connect authorization flow
                        quickConnect.start()
                    }
                }) {
                    Text("Next")
                }
                .accessibilityIdentifier("next")
            }
        } else if page == .key {
            HStack {
                VStack {
                    TextField("Username", text: $username)
                        .accessibilityIdentifier("username")
                    SecureField("Password", text: $password)
                        .accessibilityIdentifier("password")
                    Button {
                        Task {
                            do {
                                guard let instanceUrl = URL(string: instance) else { return }
                                
                                let keychain = SimpleKeychain(service: "etoile")
                                // Saving the info!
                                try keychain.set(username, forKey: "username")
                                try keychain.set(password, forKey: "password")
                                
                                let signInModel = SignInModel()
                                try await signInModel.signIn(deviceName: "Watch", username: username, password: password, instance: instanceUrl, callBack: { token in
                                    do {
                                        Logger().info("Signed in")
                                        // If we did, save it in keychain
                                        try keychain.set(token, forKey: "token")
                                        await MainActor.run {
                                            // Then move view controllers
                                            page = .pull
                                        }
                                        
                                    } catch {
                                        isError = true
                                        Logger().error("\(#file):\(#line) > error logging in \n details: \(error) \n =========")
                                    }
                                    
                                })
                            } catch {
                                isError = true
                            }
                        }
                        
                    } label: {
                        Text("Sign in")
                    }
                    .accessibilityIdentifier("submit")
                }
                VStack {
                    Text("Or use your quick connect code:")
                    Text(code)
                        .accessibilityIdentifier("quickConnect")
                }
            }
            .alert("Error signing in", isPresented: $isError) {
                Button("OK", role: .cancel) { }
            }
            
        } else if page == .pull {
            FullFetchLibraryView(callback: {
                done = true
            })
        }
    }
}

enum SigninPage {
    case instance, key, pull
}
