//
//  ContextService.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 06.03.2026.
//

protocol ContextService{
    //todo: mb change bool
    func setContext(context: ClientContext) -> Bool;
    //to save anonymus cart
    func getCart() -> [Item]
    func addItem(item:Item) -> Result<Void,Error> //result to get alarms if something is bad
    func deleteItem(item:Item) -> Result<Void,Error>
    
}
