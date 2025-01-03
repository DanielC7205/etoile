//
//  DeveloperView.swift
//  etoile.EtoileTvOS
//
//  Created by Daniel Cuevas on 12/27/24.
//

import SwiftUI
import SimpleKeychain
import Cache

struct DeveloperView: View {
    @State var alertText: String = ""
    @State var instanceURL: String = ""
    
    var body: some View {
        Form {
            Section(header: HStack {
                Image(systemName: "hammer.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                Text("Developer Settings")
                    .font(.title)
                    .bold()
            }) {
                Text("These settings are to make development easier. They should not be used in production.")
                    .padding()
            }
            
            Section(header: Text("Set default instance URL").font(.headline).padding()) {
                TextField("Instance URL", text: $instanceURL)
                    .padding()
                
                Button {
                    let keychain = SimpleKeychain(service: "etoile")
                    do {
                        try keychain.set(instanceURL, forKey: "instance")
                        alertText = "Instance URL set to \"\(instanceURL)\" successfully"
                    } catch {
                        alertText = "Error setting instance URL: \(error.localizedDescription)"
                    }
                } label: {
                    Text("Set Instance URL")
                }
            }

            
            Section(header: Text("Keychain Debug").font(.headline).padding()) {
                Button {
                    let keychain = SimpleKeychain(service: "etoile")
                    do {
                        let instanceAsString = try keychain.string(forKey: "instance")
                        let token = try keychain.string(forKey: "token")
                        print("Instance: \(instanceAsString)")
                        print("Token: \(token)")
                    } catch {
                        alertText = "Error getting login details"
                        print("Error getting login details")
                    }
                } label: {
                    Text("Print Keychain")
                }
                Button(role: .destructive) {
                    let keychain = SimpleKeychain(service: "etoile")
                    do {
                        try keychain.deleteAll()
                    } catch {
                        alertText = "Error deleting keychain: \(error.localizedDescription)"
                        print("Error deleting keychain: \(error.localizedDescription)")
                    }
                } label: {
                    Text("Delete Keychain")
                }
            }
            
        }
        .alert(isPresented: .constant(alertText != ""), content: {
            Alert(title: Text("Alert"), message: Text(alertText), dismissButton: .default(Text("Ok")))
        })
        .onAppear {
            do {
                let keychain = SimpleKeychain(service: "etoile")
                let instanceAsString = try keychain.string(forKey: "instance")
                
                if let instance = URL(string: instanceAsString) {
                    self.instanceURL = instance.absoluteString
                }
            } catch {
                print("Error getting login details")
            }
        }
    }
}

#Preview {
    DeveloperView()
}
