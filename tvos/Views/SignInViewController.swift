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
import EtoileKit
import CoreImage.CIFilterBuiltins

struct SignInViewController: View {
    // State variables for the view
    @State var page: SigninPage = .instance
    
    // State variables for the form
    // Instance URL (ex. https://demo.jellyfin.org)
    @State var instance = ""
    // Quick Connect code (if available)
    @State var code = ""
    // Username and password for manual sign in
    @State var username = ""
    @State var password = ""
    // QR code for Quick Connect
    @State var qrCode: UIImage? = nil
    // Error state
    @State var isError = false
    // Done state
    @Binding var done: Bool
    
    // Only for use in development, defined in the ContentView
    @Binding var showDevSheet: Bool
    
    // QR code generator setup
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    // Generate a QR code from a string
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    var body: some View {
        VStack {

            if page == .instance {
                Section {
                    Image("EtoileIcon")
                        .resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width: 300, height: 300, alignment: .topLeading)
                             .cornerRadius(20)
                             .padding(.all)
                             
                        .accessibilityIdentifier("logo")
                        .accessibilityLabel("Etoile Logo")
                        .accessibilityValue("Etoile Logo")
                    Text("Welcome to Etoile")
                        .font(.title)
                        .accessibilityIdentifier("welcome")
                    
                    Text("Get lost in your music, where the stars are the limit.")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .italic()
                        .accessibilityIdentifier("description")
                }
                .transition(.scale)
            }
            

                if page == .instance {
                    VStack {
                        
                        
                        Section {
                            TextField("Instance url", text: $instance)
                                .accessibilityIdentifier("instanceUrl")
                            
                            
                            
                            Button(action: {
                                Task {
                                    let keychain = SimpleKeychain(service: "etoile")
                                    // if not starting with protocol, add it
                                    if !instance.starts(with: "http") {
                                        instance = "http://" + instance
                                    }
                                    // Saving the info!
                                    guard let instanceSafe = URL(string: instance) else { return
                                    }
                                    try keychain.set(instanceSafe.absoluteString ?? "", forKey: "instance")
                                    // Create a QuickConnect object with a JellyfinClient
                                    let configuration = await JellyfinClient.Configuration(url: instanceSafe, client: "Etoile", deviceName: "TV", deviceID: UUID().uuidString, version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                                    let client = JellyfinClient(configuration: configuration)
                                    
                                    let quickConnect = QuickConnect(client: client)
                                    
                                    let quickConnectState = Task {
                                        // Listen to QuickConnect states with async/await or Combine
                                        for await state in quickConnect.$state.values {
                                            switch state {
                                            case let .polling(code: code):
                                                print(code)
                                                await MainActor.run {
                                                    withAnimation {
                                                        self.page = .key
                                                    }
                                                    self.code = code
                                                    self.qrCode = generateQRCode(from: "\(instance)/web/#/quickconnect?code=\(code)")
                                                    
                                                    print("Created QR code")
                                                }
                                            case let .authenticated(secret: secret):
                                                // Sign in with the Quick Connect secret
                                                do {
                                                    try await client.signIn(quickConnectSecret: secret)
                                                    await MainActor.run {
                                                        do {
                                                            // Saving the info!
                                                            try keychain.set(client.accessToken ?? "", forKey: "token")
                                                            withAnimation {
                                                                page = .pull
                                                            }
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
                            })
                            {
                                Text("Next")
                            }
                            .disabled(instance.isEmpty)
                            
                            .accessibilityIdentifier("next")
                        
                            
                        }
                        
                        #if DEBUG
                        Button {
                            showDevSheet = true
                        } label: {
                            Image (systemName:"gear")
                            Text ("Developer Settings")
                        }
                        #endif
                        
                    }
                    .transition(.scale)
                } else if page == .key {
                    HStack {
                        VStack(spacing: 20) {
                            Image(systemName: "key")
                                .font(.title)
                            
                            Text("Sign in")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("You are signing into \(instance)")
                                .multilineTextAlignment(.center)
                                .font(.subheadline)
                                .accessibilityIdentifier("instance")
                            
                            Button {
                                withAnimation {
                                    page = .instance
                                }
                            } label: {
                                Text("Change instance")
                            }
                            .accessibilityIdentifier("changeInstance")
                            .padding(.bottom)
                            
                            
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
                                        try await signInModel.signIn(deviceName: UIDevice.current.name, username: username, password: password, instance: instanceUrl, callBack: { token in
                                            do {
                                                Logger().info("Signed in")
                                                // If we did, save it in keychain
                                                try keychain.set(token, forKey: "token")
                                                await MainActor.run {
                                                    // Then move view controllers
                                                    withAnimation {
                                                        page = .pull
                                                    }
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
                            #if DEBUG
                            Button {
                                showDevSheet = true
                            } label: {
                                Image (systemName:"gear")
                                Text ("Developer Settings")
                            }
                            #endif
                        }
                        VStack {
                            Image(systemName: "person.badge.key")
                                .font(.title)
                                .foregroundColor(
                                    code.isEmpty ? .red : .primary
                                )
                            
                            Text("Quick Connect")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if code.isEmpty {
                                Text("This instance does not support Quick Connect or has it disabled.")
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("Scan this QR code")
                                
                                ZStack {
                                    Image(uiImage: qrCode ?? UIImage())
                                        .interpolation(.none)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
//                                        .frame(width: 200, height: 200)
                                        .accessibilityIdentifier("qrCode")
                                }
                                
                                Text("Or use your quick connect code:")
                                Text(code)
                                    .accessibilityIdentifier("quickConnect")
                            }
                        }
                        .padding()
//                        .background(Color(.etoileBackground()))
//                        .cornerRadius(20)
                    }
                    .alert("Error signing in", isPresented: $isError) {
                        Button("OK", role: .cancel) { }
                    }
                    .transition(.scale)
                    
                } else if page == .pull {
                    FullFetchLibraryView(callback: {
                        done = true
                    })
                    .transition(.scale)
                }
            }
        .onAppear {
            do {
                let keychain = SimpleKeychain(service: "etoile")
                let instanceAsString = try keychain.string(forKey: "instance")
                
                // If we have an instance, prefill it
                if let instance = URL(string: instanceAsString) {
                    self.instance = instance.absoluteString
                }
               
            } catch {
                Logger().info("Error prefilling last instance")
            }
        }
       

    }

}

enum SigninPage {
    case instance, key, pull
}
