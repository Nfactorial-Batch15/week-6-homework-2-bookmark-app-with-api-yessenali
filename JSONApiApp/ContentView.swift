//
//  ContentView.swift
//  JSONApiApp
//
//  Created by Yessenali Zhanaidar on 28.01.2022.
//

import SwiftUI

struct LinkModel: Decodable {
    var link: String
    var name: String
}

struct ContentView: View {
    @State var models: [LinkModel] = []
    @State var error = ""
    var body: some View {
        ZStack{
        List(models, id: \.name) { model in
            
            HStack {
                Text("\(model.name)")
                Text("\(error)")
                Spacer()
                Image("Group")
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: model.link)!)
                }
            }
        }
        
        }.onAppear {
            testingRequest { models, error in
                if let error = error {
                    self.error = error.localizedDescription
                }
                
                if let models = models {
                    self.models = models
                    }
                }
            }
    }
}

func testingRequest(completion: @escaping([LinkModel]?, Error?) -> Void ) {
    var linkModels: [LinkModel] = []
    let Url = String(format: "https://api.nobelprize.org/2.1/laureates")
    guard let serviceUrl = URL(string: Url) else { return }
    let request = URLRequest(url: serviceUrl)
    
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print(error)
        }
        if response != nil {
            
        }
        if let data = data {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let laureates = json?["laureates"] as? [[String: AnyObject]] {
                    
                    for laureate in laureates {
                        let array = laureate["links"] as! [[String: Any]]
                        let title = array[1]["title"] as! String
                        let wikiData = laureate["wikidata"] as! [String: Any]
                        let url = wikiData["url"] as! String
                        let linkModel = LinkModel(link: url, name: title)
                        linkModels.append(linkModel)
                    }
                    completion(linkModels, nil)
                }
            } catch {
                print(error)
                completion(nil, error)
            }
        }
    }.resume()
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

