//
//  FavoritesViewController.swift
//  СookBook
//
//  Created by Dmitriy Babichev on 28.02.2023.
//

import UIKit

final class FavoritesViewController: UIViewController {

    // MARK: - properties
    var databaseManager = DatabaseManager()
    let networkManager = NetworkManager()

    private let tableView = UITableView()
    private var cellObjects = [RecipeData.RecipeDescription]()

    // MARK: - life cycle funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        configure()
        setConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        updateData()
        getRecipes()
    }

    override func viewDidDisappear(_ animated: Bool) {
        cellObjects.removeAll()
    }


    // MARK: - flow funcs
    private func getRecipes() {
        // TODO: check if recipe id already exist in the collection before querying
        if !databaseManager.savedRecipes.isEmpty {
            for recipe in databaseManager.savedRecipes {
                networkManager.searchRecipeById(by: Int(recipe.recipeID)) { [self] data in
                        cellObjects.append(data)
                        updateData()
                }
            }
        } else {
            print("Saved recipes collection is empty")
        }
    }

    private func updateData() {
        databaseManager.fetchRecipes()

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    private func configure() {
        configureViews()
        configureTableView()
    }

    private func addSubViews() {
        view.addSubview(tableView)
    }

    private func configureViews() {
        view.backgroundColor = .white
        if let tabBarItem = self.tabBarController?.tabBar.items?[1] {
            tabBarItem.selectedImage = UIImage(systemName: "heart.fill")
        }
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(FavoritesTableViewCell.self, forCellReuseIdentifier: FavoritesTableViewCell.identifier)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

    // MARK: - UITableViewDataSource
extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellObjects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoritesTableViewCell.identifier, for: indexPath) as? FavoritesTableViewCell else {
            return UITableViewCell()
        }

        let data = cellObjects[indexPath.row]
        cell.configure(title: data.title, imageName: "recipe-1")

        return cell
    }
}

// MARK: - UITableViewDelegate
extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        250
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipeVC = RecipeViewController()
        // TODO: Pass data to the next VC
        present(recipeVC, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [self] (_, _, completionHandler) in
            databaseManager.deleteRecipe(databaseManager.savedRecipes[indexPath.row])
            cellObjects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateData()
            completionHandler(true)
        }

        deleteAction.image = UIImage(systemName: "trash")?.withTintColor(.systemPink, renderingMode: .alwaysOriginal)
        deleteAction.backgroundColor = .white
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}
