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
    @EnvironmentObject var sessionManager: SessionManager // <-- Add this line
    
    var body: some View {
        Form {
            // MARK: Profile Picture Section
            Section(header: Text("Profile Picture")) {
                HStack {
                    Spacer()
                    ZStack(alignment: .bottomTrailing) {
                        // Display the selected image or a placeholder
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
                        
                        // Button to trigger photo selection action sheet
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
                TextField("Enter your username", text: $username)
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
        .onAppear {
            Task {
                await fetchProfilePicture()
            }
        }
    }
    
    func updateProfile() {
        print("Profile updated with username: \(username)")

        // Convert selected image to JPEG data
        if let image = selectedImage {
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                print("✅ Successfully converted image to JPEG. Size: \(jpegData.count) bytes")
                Task {
                    await uploadToSupabase(jpegData)
                }
            } else {
                print("❌ Failed to convert image to JPEG.")
            }
        } else {
            print("ℹ️ No profile image selected.")
        }
    }

    // Uploads the image data to Supabase Storage in the 'profile-pics' bucket
    func uploadToSupabase(_ data: Data) async {
        guard let user = sessionManager.user else {
            print("❌ No user signed in.")
            return
        }
        let userId = user.id.uuidString.lowercased()
        let fileId = UUID().uuidString
        let filename = "\(fileId).jpg"
        let path = "\(userId)/\(filename)"
        
        do {
            print("STEP 1: Starting upload to Supabase Storage")
            // Upload the JPEG data
            try await client.storage
                .from("profile-pics")
                .upload(
                    path: path,
                    file: data
                )
            print("STEP 2: ✅ Uploaded to Supabase at path: \(path)")
            
            // 1️⃣ Retrieve the public URL after upload
            print("STEP 3: Attempting to get public URL")
            let publicUrl = try client.storage
                .from("profile-pics")
                .getPublicURL(path: path)
            print("STEP 4: 🖼 Public URL: \(publicUrl)")

            // Update the user's profile with the new avatar URL
            print("STEP 5: Attempting to update user profile in database")
            let res = try await client.database
                .from("users")
                .update([                       // ← no `values:` label
                    "profile_picture_url": publicUrl.absoluteString
                ])
                .eq("id", value: userId)       // ← no `column:` label, keep `value:` only on second arg
                .execute()
            print("STEP 6: Database update response received")
            guard res.status == 200 || res.status == 204 else {
                print("STEP 7: Unexpected HTTP status code: \(res.status)")
                return
            }
            print("STEP 8: Profile picture URL updated successfully.")

        } catch {
            print("❌ Failed to upload or update: \(error.localizedDescription)")
        }
    }

    func fetchProfilePicture() async {
        guard let user = sessionManager.user else { return }
        let userId = user.id.uuidString.lowercased()
        do {
            // Fetch the user's profile from Supabase
            let response = try await client.database
                .from("users")
                .select("profile_picture_url")
                .eq("id", value: userId)
                .single()
                .execute()
            
            struct ProfilePicResponse: Decodable {
                let profile_picture_url: String?
            }
            let profile = try JSONDecoder().decode(ProfilePicResponse.self, from: response.data)
            if let urlString = profile.profile_picture_url, let url = URL(string: urlString) {
                // Download the image data
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    // Update on main thread
                    await MainActor.run {
                        self.selectedImage = image
                    }
                }
            }
        } catch {
            print("Failed to fetch profile picture: \(error.localizedDescription)")
        }
    }
}

struct ResetPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter your email")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    Button("Reset Password") {
                        handleResetPassword()
                    }
                }
            }
            .navigationTitle("Reset Password")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Password Reset"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func handleResetPassword() {
        guard !email.isEmpty else {
            alertMessage = "Please enter your email."
            showingAlert = true
            return
        }
        guard email.isEmailValid() else {
            alertMessage = "Please enter a valid email address."
            showingAlert = true
            return
        }
        Task {
            do {
                print("🔗 Sending reset password link to \(email)")
                try await client.auth.resetPasswordForEmail(email, redirectTo: URL(string: "myapp://reset-password"))
                alertMessage = "A password reset link has been sent to your email."
                showingAlert = true
                // Dismiss after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                alertMessage = "Failed to send reset email: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
}

// extension String {
//     func isEmailValid() -> Bool {
//         let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//         let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
//         return emailPredicate.evaluate(with: self)
//     }
// }

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
