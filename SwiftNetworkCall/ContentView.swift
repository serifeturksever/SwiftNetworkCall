//
//  ContentView.swift
//  SwiftNetworkCall
//
//  Created by Şerife Türksever on 24.07.2023.
//

import SwiftUI


struct ContentView: View {
    @State private var user: GithubUser?

    var body: some View {
        VStack(spacing: 20){
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")){ image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width:120, height:120)
            
            Text(user?.login ?? "Login Placeholder")
                .bold()
                .font(.title3)
            
            Text(user?.bio ?? "Bio Placeholder")
                .padding()
            Spacer()
        }
        .padding()
        .task {
            do{
                user = try await getUser()
            } catch GHError.invalidURL {
                print("invalid URl")
            } catch GHError.invalidResponse {
                print("invalid Response")
            }catch GHError.invalidData {
                print("invalid Data")
            }catch {
                print("unexpected error")
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct GithubUser: Codable {
    var login: String
    var avatarUrl: String
    var bio: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

func getUser() async throws -> GithubUser{
    let endpoint: String = "https://api.github.com/users/BurhanDundar"
    
    guard let url = URL(string: endpoint) else {throw GHError.invalidURL }
    
    let (data,response) = try await URLSession.shared.data(from: url)
    
    guard let response = response as? HTTPURLResponse,response.statusCode == 200 else{throw GHError.invalidResponse}
    
    do{
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(GithubUser.self, from: data)
    }catch{
        throw GHError.invalidData
    }
}


