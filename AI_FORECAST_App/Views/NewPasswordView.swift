//
//  NewPasswordView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 08/07/2025.
//

import SwiftUI
import Supabase

struct NewPasswordView: View {
    @Binding var authState: AuthState

    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String = ""
    @State private var successMessage: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Set a New Password")) {
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm Password", text: $confirmPassword)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                if !successMessage.isEmpty {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.footnote)
                }

                Section {
                    Button(action: {
                        Task { await resetPassword() }
                    }) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Update Password")
                        }
                    }
                    .disabled(isLoading || newPassword.isEmpty || confirmPassword.isEmpty)
                }
            }
            .navigationTitle("Reset Password")
            .navigationBarItems(leading: Button("Cancel") {
                authState = .signIn
            })
        }
    }

    private func resetPassword() async {
        errorMessage = ""
        successMessage = ""

        guard newPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true

        do {
            try await client.auth.update(
                user: UserAttributes(password: newPassword)
            )
            successMessage = "✅ Password updated. You can now sign in."
            
            // Wait briefly so the user sees the success message
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            authState = .signIn

        } catch {
            errorMessage = "Failed to reset password: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

// #if DEBUG
struct NewPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NewPasswordView(authState: .constant(.signIn))
    }
}
//#endif


