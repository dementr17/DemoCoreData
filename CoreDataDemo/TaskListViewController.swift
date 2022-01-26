//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by brubru on 24.01.2022.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let context = StorageManager.shared.persistentContainer.viewContext
    
    private let cellID = "task"
    //id ячейки

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        //фон вью
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        //регистрируем ячейку по индексу
        setupNavigationBar()
        //настраиваем навигейшн бар
        StorageManager.shared.fetchTask(context: context)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StorageManager.shared.fetchTask(context: context)
        //загружаем данные из CoreData и обновляем экран
        //вызывывается при выгрузке экрана из памяти
        tableView.reloadData()
    }
 
    private func setupNavigationBar() {
        title = "Task List"
        //текст заголовка
        navigationController?.navigationBar.prefersLargeTitles = true
        //вроде бы большой заголовок
        
        let navBarAppearence = UINavigationBarAppearance()
        //экземпляр настроек
        navBarAppearence.configureWithOpaqueBackground()
        navBarAppearence.titleTextAttributes = [.foregroundColor: UIColor.white]
        //задаем цвет текста для заголовка, когда при прокрутке бар сжимается
        navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        //задаем цвет текста для большого заголовка
        
        navBarAppearence.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        //цвет для нав бара
        
        navigationController?.navigationBar.standardAppearance = navBarAppearence
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
        //применяем настройки навбара
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        //настройки кнопки навбара (тип, где срабатывает, по какому методу)
        
        navigationController?.navigationBar.tintColor = .white
        //ее цвет
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?")
        //вызов алерта при нажатии на кнопку +, передача в алерт заголовка и описания
    }
    
   
}

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        StorageManager.shared.taskList.count
        //количество ячеек равно количеству элементов массива
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        //инициализируем ячейку через идентификатор
        let task = StorageManager.shared.taskList[indexPath.row]
        //берем элемент из массива
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    //свайп по ячейке
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { deleteAction, TaskListViewController, comletion in
    
            StorageManager.shared.deleteTask(context: self.context, indexPath: indexPath)
            
            let cellIndex = IndexPath(row: indexPath.row, section: 0)
            tableView.deleteRows(at: [cellIndex], with: .automatic)
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { editAction, TaskListViewController, comletion in
           
            let task = StorageManager.shared.taskList[indexPath.row]

            guard let tf = task.name else { return }
            let index = indexPath.row

            self.showAlert1(with: "asa", and: "sdsd", tf: tf, index: index)
            
            comletion(true)
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        editAction.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
}

// MARK: AlertController
extension TaskListViewController {
    
    private func showAlert(with title: String, and message: String, tf: String = "", index: Int = 0, parametr: Bool = true) {
        //алерт принимает заголовок и сообщение
        let index = index
        let parametr = parametr
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            //передаем значение из текстового поля в task если оно не пустое по нажатию на сейв
            self.save(task, index: index, parametr: parametr)
            //в метод передаем task
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.text = tf
            textField.placeholder = "New Task"
        }
        //настраиваем алерт: кнопки и текстовое поле с подсказкой
        present(alert, animated: true)
        //вызов алерта
    }
    private func save(_ taskName: String, index: Int, parametr: Bool) {
        let index = index
        let parametr = parametr
        
        var cellIndex: IndexPath!
        StorageManager.shared.addTask(taskName, context: context)
        let taskList = StorageManager.shared.taskList
        
        if parametr == true {
            cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        } else {
            cellIndex = IndexPath(row: index, section: 0)
        }
        
        tableView.insertRows(at: [cellIndex], with: .automatic)
        //теперь добавляем ячейку в конец таблицы по массиву индексов
    }
    
    private func showAlert1(with title: String, and message: String, tf: String = "", index: Int = 0) {
        //алерт принимает заголовок и сообщение
        let index = index
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            //передаем значение из текстового поля в task если оно не пустое по нажатию на сейв
            self.save1(task, index: index)
            //в метод передаем task
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.text = tf
            textField.placeholder = "New Task"
        }
        //настраиваем алерт: кнопки и текстовое поле с подсказкой
        present(alert, animated: true)
        //вызов алерта
    }
    private func save1(_ taskName: String, index: Int) {
        let index = index
        
        var cellIndex = IndexPath(row: index + 1, section: 0)
        StorageManager.shared.editTask(taskName, context: context, indexPath: cellIndex)
//        let taskList = StorageManager.shared.taskList
        tableView.insertRows(at: [cellIndex], with: .automatic)
        cellIndex.row +=  1
        tableView.deleteRows(at: [cellIndex], with: .automatic)
    }
}
