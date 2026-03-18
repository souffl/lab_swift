# Приложение доставки цветов

Лабораторная работа: проектирование и скелет приложения для доставки цветов (каталог магазинов, товары, корзина, авторизация, оплата).

---

## Архитектура

Используется **MVVM** (Model – View – ViewModel).

Никогда не пробовала эту архитектуру, хочу попробовать. Плюс binding казался интересной темкой, которую надо попробовать

---

## Модули и ответственности

| Модуль | Ответственность |
|--------|-----------------|
| **Login** | Вход по логину/паролю, обновление сессии в контексте при успехе. |
| **Shop Catalog** | Список магазинов, выбор магазина для перехода к каталогу товаров. |
| **Shop** | Товары одного магазина, добавление в корзину. |
| **Cart** | Корзина (просмотр, изменение количества, удаление), оплата; при анониме — редирект на авторизацию. |

---

## Use cases

1. **Анонимный пользователь**: просматривает магазины → добавляет/убирает товары в корзине → нажимает «Оплатить» → перенаправляется на экран авторизации.
2. **Возврат авторизованного пользователя**: пользователь уже входил, закрыл приложение; при новом запуске авторизация не требуется, контекст (сессия и корзина) подгружается.
3. **Оплата авторизованным пользователем**: пользователь авторизован → добавляет товары в корзину → переходит в корзину → удаляет часть товаров → нажимает «Оплатить» → завершение сценария (успешная оплата или обработка ошибки).

---

## Экраны: вход, выход, состояния, сценарии

### 1. Авторизация (Login)

- **Вход**: нет (экран открывается по навигации, например из корзины при нажатии «Оплатить» анонимом).
- **Выход**:
  - успешный вход → закрытие экрана / возврат в корзину;
  - ошибка → отображение сообщения (неверные данные, сеть и т.д.).
- **Состояния UI**: initial (поля пустые), loading (идёт запрос), content (результат: успех или ошибка).
- **Сценарии**:
  1. Пользователь вводит логин и пароль, нажимает «Войти» → запрос к LoginService → успех → обновление контекста (сессия authenticated), закрытие экрана.
  2. Неверные данные → отображение ошибки «Неверный логин или пароль».
  3. Ошибка сети/сервера → отображение соответствующего сообщения.

---

### 2. Каталог магазинов (Shop Catalog)

- **Вход**: нет (стартовый экран или корень навигации после входа).
- **Выход**: выбор магазина → переход на экран магазина с переданным `Shop`.
- **Состояния UI**: initial, loading (загрузка списка), content (список магазинов), error (ошибка загрузки, опционально).
- **Сценарии**:
  1. При появлении экрана загружается список магазинов (loadShops).
  2. Пользователь нажимает на магазин → событие onShopSelected(shop) → навигация на экран магазина с этим shop.
  3. (Опционально) Ошибка загрузки → onLoadFailed(message).

---

### 3. Магазин (Shop)

- **Вход**: выбранный магазин (`Shop`) — id, название, адрес; экран открывается из каталога.
- **Выход**: добавление товара в корзину (успех/ошибка через колбэки); возврат назад в каталог.
- **Состояния UI**: initial, content (список товаров), сообщение об ошибке добавления в корзину (если есть).
- **Сценарии**:
  1. При появлении загружаются товары магазина (getItems по shop.id).
  2. Пользователь нажимает «В корзину» у товара → addItem(item) → при успехе обновление UI/тост; при ошибке onAddToCartFailed(message).
  3. Возврат в каталог (кнопка «Назад»).

---

### 4. Корзина (Cart)

- **Вход**: нет (переход по кнопке «Корзина» из приложения).
- **Выход**:
  - обновление корзины (onCartUpdated);
  - «Оплатить» при анониме → onNeedLogin (переход на экран авторизации);
  - успешная оплата → onSuccessPayment;
  - ошибка оплаты → onFailPayment(error).
- **Состояния UI**: initial, content (список позиций и итоговая сумма), loading (идёт оплата), success / error (результат оплаты).
- **Сценарии**:
  1. При появлении отображаются товары корзины и сумма (getCart, totalPrice).
  2. Удаление позиции: deleteItem(item) → при успехе onCartUpdated.
  3. Увеличение/уменьшение количества: increaseItemCount(item) / decreaseItemCount(item) → при успехе onCartUpdated.
  4. Нажатие «Оплатить» при анонимной сессии → onNeedLogin → показ экрана авторизации.
  5. Нажатие «Оплатить» при авторизованной сессии → payOrder() → при успехе onSuccessPayment; при ошибке onFailPayment(error).

---

## Доменные модели

| Модель | Описание |
|--------|----------|
| **Client** | Пользователь: id, login, password (для ответа/хранилища; пароль не отдаётся во View). |
| **ClientContext** | Текущий контекст сессии: session (SessionState), cart ([Item]). |
| **SessionState** | enum: anonymous \| authenticated(clientID: Int). |
| **Shop** | Магазин: id, name, location. |
| **Item** | Товар: id, shopID, cost (Decimal), name. |

Дополнительные типы в контрактах сервисов:

- **AuthResult**: success(clientID) \| invalidCredentials \| clientNotFound \| failure(LoginError).
- **LoginError**: networkUnavailable \| serverUnavailable \| unknown.
- **IssueResult** (ShopService): success(item) \| outOfStock \| itemNotFound.

---

## Ключевые протоколы и контракты

### View ↔ ViewModel

- Связь через **публичный API ViewModel**: методы (login, getCart, payOrder, addItem, deleteItem, loadShops, selectShop и т.д.) и опциональные замыкания (onLoginSucceeded, onNeedLogin, onShopSelected, onCartUpdated и т.д.). View вызывает методы и подписывается на колбэки; в контрактах нет UIKit.

### Presentation ↔ Domain (ViewModel ↔ Services)

- **LoginViewModel** → `LoginService`, `ContextService`
- **ShopCatalogViewModel** → `ShopService`
- **ShopViewModel** → `ShopService`, `ContextService`
- **CartViewModel** → `ContextService`, `PaymentService`

### Domain ↔ Data (протоколы сервисов)

| Протокол | Назначение |
|----------|------------|
| **LoginService** | login(username:password:) → AuthResult |
| **ContextService** | getContext/setContext, getCart, addItem, deleteItem |
| **ShopService** | getShops(), getItems(shopID:), findItem, hasItem, issueItem |
| **PaymentService** | pay(amount: Double) → Result<Void, Error> |

### Router / Navigator

Навигация (открытие экранов авторизации, каталога, магазина, корзины) выносится в отдельный контракт (протокол Router/Navigator); реализация создаёт ViewController’ы и ViewModel’ы и выполняет push/present. В домене и во ViewModel навигации нет, только вызов колбэков (например, onNeedLogin, onShopSelected).

---

## Структура проекта

```
lab_swift/
├── Core/
│   ├── Models/          # Доменные модели и DTO
│   │   ├── Client.swift
│   │   ├── ClientContext.swift
│   │   ├── Item.swift
│   │   └── Shop.swift
│   └── Services/        # Протоколы сервисов (контракты Domain ↔ Data)
│       ├── ContextService.swift
│       ├── LoginService.swift
│       ├── PaymentService.swift
│       └── ShopService.swift
├── ViewModels/          # Presentation-слой: контракт View ↔ ViewModel
│   ├── LoginViewModel.swift
│   ├── ShopCatalogViewModel.swift
│   ├── ShopViewModel.swift
│   └── CartViewModel.swift
├── ViewControllers/     # View (экран за экраном) — дописать
├── Router/              # Навигация — дописать
├── AppDelegate.swift
├── SceneDelegate.swift
└── README.md
```
