import SwiftUI

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""  // Для підтвердження пароля
    @State private var isRegistering = false
    @State private var errorMessage: String? = nil  // Для відображення помилки

    var body: some View {
        VStack {
            Text(isRegistering ? "Реєстрація" : "Вхід")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            TextField("Логін", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Пароль", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if isRegistering {
                SecureField("Підтвердіть пароль", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: isRegistering ? register : login) {
                Text(isRegistering ? "Зареєструватися" : "Увійти")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Button(action: { isRegistering.toggle() }) {
                Text(isRegistering ? "Вже маєте акаунт? Увійдіть" : "Немає акаунту? Зареєструйтеся")
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }

    func login() {
        // Тут потрібно додати реальну перевірку користувача, наприклад, через Firebase
        if !username.isEmpty && !password.isEmpty {
            isLoggedIn = true  // При успішному вході
        } else {
            errorMessage = "Будь ласка, введіть логін і пароль"
        }
    }

    func register() {
        // Перевірка, чи співпадають паролі
        if password != confirmPassword {
            errorMessage = "Паролі не співпадають"
            return
        }

        // Тут можна додавати логіку для реєстрації через API
        if !username.isEmpty && !password.isEmpty {
            isLoggedIn = true  // Після успішної реєстрації
        } else {
            errorMessage = "Будь ласка, заповніть всі поля"
        }
    }
}

#Preview {
    LoginView()
}
