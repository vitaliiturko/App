import SwiftUI
import PhotosUI

struct ProfileView: View {
    @State private var username: String = "Ім'я користувача"
    @State private var email: String = "email@example.com"
    @State private var isEditing: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = UIImage(named: "profile_photo")

    var body: some View {
        VStack(spacing: 20) {
            // 🔙 Кнопка повернення в меню
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Назад до меню")
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding(.horizontal)

            // 📸 Фото профілю
            ZStack(alignment: .bottomTrailing) {
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Image(systemName: "camera.fill")
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .onChange(of: selectedPhoto) { newItem in
                    loadImage(from: newItem)
                }
            }

            // 📝 Редагування імені та email
            if isEditing {
                TextField("Ім'я", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .keyboardType(.emailAddress)
            } else {
                Text(username)
                    .font(.title)
                    .fontWeight(.bold)

                Text(email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // 🔵 Кнопка редагування / збереження
            Button(action: {
                isEditing.toggle()
            }) {
                Text(isEditing ? "Зберегти" : "Редагувати профіль")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isEditing ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
    }

    // 📷 Завантаження фото профілю
    private func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                profileImage = image
            }
        }
    }
}

#Preview {
    ProfileView()
}
