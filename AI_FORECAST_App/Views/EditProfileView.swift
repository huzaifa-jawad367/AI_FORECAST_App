//
//  EditProfileView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 14/03/2025.
//

import SwiftUI

struct EditProfileView: View {
    @State private var username: String = "Current Username"
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var isShowingActionSheet = false
    
    // New state variables for password reset fields
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: Profile Picture Section
                Section(header: Text("Profile Picture")) {
                    HStack {
                        Spacer()
                        ZStack(alignment: .bottomTrailing) {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: 100, height: 100)
                            }
                            
                            Button(action: {
                                isShowingActionSheet = true
                            }, label: {
                                Image(systemName: "camera.fill")
                                    .padding(8)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            })
                            .actionSheet(isPresented: $isShowingActionSheet) {
                                ActionSheet(title: Text("Select Photo"), buttons: [
                                    .default(Text("Photo Library")) {
                                        imageSource = .photoLibrary
                                        isShowingImagePicker = true
                                    },
                                    .default(Text("Camera")) {
                                        imageSource = .camera
                                        isShowingImagePicker = true
                                    },
                                    .cancel()
                                ])
                            }
                        }
                        Spacer()
                    }
                }
                
                // MARK: Username Section
                Section(header: Text("Username")) {
                    TextField("Enter your username", text: Binding(
                        get: { viewModel.currentUser?.username ?? "" },
                        set: { newUsername in
                            viewModel.currentUser?.username = newUsername
                        }
                    ))
                    .autocapitalization(.none)
                }
                
                // MARK: Reset Password Section
                Section(header: Text("Reset Password")) {
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm New Password", text: $confirmNewPassword)
                    Button(action: {
                        resetPassword()
                    }) {
                        Text("Reset Password")
                            .foregroundColor(.red)
                    }
                }
                
                // MARK: Save Changes Section
                Section {
                    Button(action: {
                        updateProfile()
                    }) {
                        Text("Save Changes")
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: imageSource)
            }
            .task {
                await loadUserProfileIfSignedIn()
            }
        }
    }
    
    /// Loads the user profile asynchronously and prints the username.
    func loadUserProfileIfSignedIn() async {
        guard let supabaseUser = sessionManager.user else {
            print("No session user found.")
            return
        }
        
        do {
            let profile = try await viewModel.fetchUserProfile(userID: supabaseUser.id.uuidString)
            viewModel.currentUser = profile
            if let currentUsername = viewModel.currentUser?.username {
                username = currentUsername
                print("Retrieved current user with username: \(currentUsername)")
            } else {
                print("User profile loaded, but username is missing.")
            }
        } catch {
            print("Error fetching profile: \(error.localizedDescription)")
        }
    }
    
    /// Dummy implementation for resetting the password.
    /// TODO: Replace this dummy implementation with a call to viewModel.resetPassword(newPassword:) when available.
    func resetPassword() {
        guard !newPassword.isEmpty else {
            print("New password is empty.")
            return
        }
        
        guard newPassword == confirmNewPassword else {
            print("Passwords do not match.")
            return
        }
        
        // Dummy reset password implementation.
        print("Dummy password reset successful. (Replace with actual implementation)")
        // Clear the fields after successful reset
        newPassword = ""
        confirmNewPassword = ""
    }
    
    func updateProfile() {
        print("Profile updated with username: \(username)")
        // Add any additional update logic, such as uploading the selected image, here.
    }
}



struct ResetPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter your email")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button("Reset Password") {
                        // Add password reset logic here
                        print("Password reset for \(email)")
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Reset Password")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// A simple ImagePicker to wrap UIImagePickerController
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


#Preview {
    EditProfileView()
}
