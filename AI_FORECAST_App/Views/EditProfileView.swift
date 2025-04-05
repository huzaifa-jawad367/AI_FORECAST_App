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
    @State private var isShowingPasswordReset = false
    
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
                
                // MARK: Password Reset Section
                Section {
                    Button(action: {
                        isShowingPasswordReset = true
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
            // Present the ImagePicker when needed
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: imageSource)
            }
            // Present the ResetPasswordView modally
            .sheet(isPresented: $isShowingPasswordReset) {
                ResetPasswordView()
            }
            // Use a .task modifier to load the current user when the view appears
            .task {
                await loadUserProfileIfSignedIn()
            }
        }
    }
    
    /// Asynchronously loads the user profile if a session exists and prints the current username.
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
    
    func updateProfile() {
        print("Profile updated with username: \(username)")
        // Add additional update logic such as image uploading if needed
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
