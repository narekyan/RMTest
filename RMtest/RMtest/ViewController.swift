//
//  ViewController.swift
//  RMtest
//
//  Created by Narek on 20.02.22.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    private lazy var viewModel: IViewModel = { ViewModelFactory.getViewModel(Context.baseUrl) }()
    private var cancelables = Set<AnyCancellable>()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        getItems()
        
    }
    
    private func getItems() {
        viewModel.getNextItems().sink { completion in
            switch completion {
            case .failure(let error):
                print("Error \(error.localizedDescription)")
            case .finished:
                self.tableView.reloadData()
            }
        } receiveValue: { _ in
        }.store(in: &cancelables)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = "\(viewModel.items[indexPath.row].name) \nLocation: \(viewModel.items[indexPath.row].location?.name ?? "")"
        viewModel.getImage(indexPath.row).sink { image in
            cell.imageView?.image = image ?? UIImage(named: "default")
        }.store(in: &cancelables)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.items.count - 1 {
            getItems()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
}
