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
        let task = Task(context: context)
        task.name = taskName
        taskList.append(task)
        saveTask(context: context)
    }
    
    func deleteTask(context: NSManagedObjectContext, indexPath: IndexPath) {
        
        let fetchRequest = Task.fetchRequest()
        
        if let result = try? context.fetch(fetchRequest) {
            for object in result {
                let task = taskList[indexPath.row]
                if object == task {
                    context.delete(object)
                }
            }
        }
            taskList.remove(at: indexPath.row)
            saveTask(context: context)
    }
    
    func editTask(_ taskName: String, context: NSManagedObjectContext, indexPath: IndexPath) {
        let task = Task(context: context)
        task.name = taskName

        taskList[indexPath.row] = task
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
