//
//  ImageFeedzUITests.swift
//  ImageFeedzUITests
//
//  Created by Игорь Полунин on 24.03.2023.
//

import XCTest

final class ImageFeedzUITests: XCTestCase {

    private let app = XCUIApplication() // переменная приложения
        
        override func setUpWithError() throws {
            continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
            
            app.launch() // запускаем приложение перед каждым тестом
        }
        
        func testAuth() throws { // тестируем сценарий авторизации
                 
                /*
                  У приложения мы получаем список кнопок на экране и получаем нужную кнопку по тексту на ней
                  Далее вызываем функцию tap() для нажатия на этот элемент
                */
            
            let authenticateButton = app.buttons["Authenticate"]
         
            XCTAssertTrue(authenticateButton.waitForExistence(timeout: 5))
            authenticateButton.tap()

            let webView = app.webViews["UnsplashWebView"] //вернет нужный вебвью по идентифаеру
            XCTAssertTrue(webView.waitForExistence(timeout: 5)) //ждем 5 сек пока вебвью не появится
            
            let loginTextField = webView.descendants(matching: .textField).element// найдет поле для ввода логина
            XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
            loginTextField.tap()
            
            loginTextField.typeText(" ")
            sleep(3)
            let doneButton = app.buttons["Done"]
            doneButton.tap()
            
            sleep(3)
             //поможет скрыть клавиатуру после ввода текста
            
            let passwordTextField = webView.descendants(matching: .secureTextField).element //найдет поле ввода пароля
            XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
           
            passwordTextField.tap()

            passwordTextField.typeText(" ")
            sleep(3)
            
            webView.swipeUp()
            
            webView.buttons["Login"].tap()
            
          let tablesQuery = app.tables // вернёт таблицы на экран
            
            
           
            
            let cell = tablesQuery.children(matching: .cell).element(boundBy: 0) // вернёт ячейку по индексу 0
           XCTAssertTrue(cell.waitForExistence(timeout: 5))//подождёт появления ячейки на экране в течение 5 секунд.
           
            
        }
        
        func testFeed() throws {
            // тестируем сценарий ленты
            // Подождать, пока открывается и загружается экран ленты
                // Сделать жест «смахивания» вверх по экрану для его скролла
                // Поставить лайк в ячейке верхней картинки
                // Отменить лайк в ячейке верхней картинки
                // Нажать на верхнюю ячейку
                // Подождать, пока картинка открывается на весь экран
                // Увеличить картинку
                // Уменьшить картинку
                // Вернуться на экран ленты
            
            let tablesQuery = app.tables
            let cell = tablesQuery.children(matching: .cell).element(boundBy: 0) // берем ячейку по индексу 0
            XCTAssertTrue(cell.waitForExistence(timeout: 5))//подождёт появления ячейки на экране в течение 5 секунд.
            cell.swipeUp() // Сделать жест «смахивания» вверх по экрану для его скролла
            
            sleep(2)
            
            let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1) // выбираем верхнюю первую ячейку=картинку
            cellToLike.buttons["likeOff"].tap()
            sleep(2)
            cellToLike.buttons["likeOn"].tap()
            
            sleep(2)
            
            cellToLike.tap()
            sleep(2)
            let image = app.scrollViews.images.element(boundBy: 0)
            image.pinch(withScale: 3, velocity: 1)
            image.pinch(withScale: 0.5, velocity: -1)
            let navBackButtonWhiteButton = app.buttons["NavBackButtonWhite"]
            navBackButtonWhiteButton.tap()
            
        }
        
        func testProfile() throws {
            // тестируем сценарий профиля
            // Подождать, пока открывается и загружается экран ленты
                // Перейти на экран профиля
                // Проверить, что на нём отображаются ваши персональные данные
                // Нажать кнопку логаута
                // Проверить, что открылся экран авторизации
            sleep(3)
            app.tabBars.buttons.element(boundBy: 1).tap()
            XCTAssertTrue(app.staticTexts[" "].exists)
            XCTAssertTrue(app.staticTexts[" "].exists)
            
            app.buttons["logoutButton"].tap()
            sleep(3)
            app.alerts["Пока,пока!"].scrollViews.otherElements.buttons["Да"].tap()
        }
    
    
}
