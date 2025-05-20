import SwiftUI

struct NewsView: View {
    @State private var newsArticles: [NewsArticle] = [
        NewsArticle(title: "Новина 1", source: "Джерело 1", imageUrl: "https://example.com/image1.jpg", url: "https://example.com/1"),
        NewsArticle(title: "Новина 2", source: "Джерело 2", imageUrl: "https://example.com/image2.jpg", url: "https://example.com/2"),
        NewsArticle(title: "Новина 3", source: "Джерело 3", imageUrl: "https://example.com/image3.jpg", url: "https://example.com/3")
    ]
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            List(newsArticles) { article in
                NavigationLink(destination: NewsDetailView(article: article)) {
                    HStack {
                        AsyncImage(url: URL(string: article.imageUrl ?? "")) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading) {
                            Text(article.title)
                                .font(.headline)
                                .lineLimit(2)

                            Text(article.source)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Новини")
            .onAppear {
                // Замість fetchNews() додайте власну логіку або API для завантаження новин
            }
        }
    }
}

// Модель новин
struct NewsArticle: Identifiable, Codable {
    let id = UUID()
    let title: String
    let source: String
    let imageUrl: String?
    let url: String

    enum CodingKeys: String, CodingKey {
        case title, source, url
        case imageUrl = "image"
    }
}

struct NewsResponse: Codable {
    let data: [NewsArticle]
}

// Детальний перегляд новини
struct NewsDetailView: View {
    let article: NewsArticle

    var body: some View {
        VStack {
            if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
            }

            Text(article.title)
                .font(.title2)
                .fontWeight(.bold)
                .padding()

            Button(action: {
                if let url = URL(string: article.url) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Читати далі")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Деталі новини")
    }
}
