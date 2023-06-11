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
            button.accessibilityIdentifier = "Authenticate"
            XCTAssertTrue(authenticateButton.waitForExistence(timeout: 10))
            authenticateButton.tap()

            let webView = app.webViews["UnsplashWebView"] //вернет нужный вебвью по идентифаеру
            XCTAssertTrue(webView.waitForExistence(timeout: 5)) //ждем 5 сек пока вебвью не появится
            
            let loginTextField = webView.descendants(matching: .textField).element// найдет поле для ввода логина
            XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
            loginTextField.tap()
            loginTextField.typeText("garry.818@yandex.ru")
            webView.swipeUp() //поможет скрыть клавиатуру после ввода текста
            
            let passwordTextField = webView.descendants(matching: .secureTextField).element //найдет поле ввода пароля
            XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
            passwordTextField.tap()
            passwordTextField.typeText("Unsplash-sprint10")
            webView.swipeUp()
            
            
            let tablesQuery = app.tables // вернёт таблицы на экран
            tablesQuery.buttons["Login"].tap()
            
           
            
            let cell = tablesQuery.children(matching: .cell).element(boundBy: 0) // вернёт ячейку по индексу 0
            XCTAssertTrue(cell.waitForExistence(timeout: 5))//подождёт появления ячейки на экране в течение 5 секунд.
           
            print(app.debugDescription)
        }
        
        func testFeed() throws {
            // тестируем сценарий ленты
        }
        
        func testProfile() throws {
            // тестируем сценарий профиля
        }
}
