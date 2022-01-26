//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Дмитрий Чепанов on 25.01.2022.
//

import Foundation
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    var taskList: [Task] = []
    
    private init() {}
   
    func saveTask(context: NSManagedObjectContext) {
        do {
            try context.save()
            //если все нормально то вызываем свойство save
        } catch let error {
            print(error)
        }
    }
    
    func fetchTask(context: NSManagedObjectContext) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try context.fetch(fetchRequest)
        } catch {
           print("Faild to fetch data", error)
        }
    }
    
    func addTask(_ taskName: String, context: NSManagedObjectContext){
        //Task это сущность в файле CoreDataDemo, в котором описана модель данных. В нашем случае это какбы структура с оинм параметром name типа string
        let task = Task(context: context)
        //инициализируем экземляр через параметр контекст
        task.name = taskName
        //переданный в метод save task присваиваем параметру экземпляра
        taskList.append(task)
        //добавляем в массив элемент
        saveTask(context: context)
    }
    
    func deleteTask(context: NSManagedObjectContext, indexPath: IndexPath) {
        
        let fetchRequest = Task.fetchRequest()
        
        if let result = try? context.fetch(fetchRequest) {
            for object in result {
                //Please check before delete operation
                let task = taskList[indexPath.row]
                if object == task {
                    context.delete(object)
                }
            }
        }
            //перед удалением получаем данные
            taskList.remove(at: indexPath.row)
            //удаляем данные из массива
//            print("Posle ", taskList.count)
            saveTask(context: context)
    }
    
    func editTask(_ taskName: String, context: NSManagedObjectContext, indexPath: IndexPath) {
        let task = Task(context: context)
        //инициализируем экземляр через параметр контекст
        task.name = taskName
        //переданный в метод save task присваиваем параметру экземпляра

        taskList[indexPath.row] = task
        
        //добавляем в массив элемент
        saveTask(context: context)
    }
    
    // MARK: - Core Data stack

    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
