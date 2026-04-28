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
| **Shop** | Магазин: id, name, location, imageURL, workHours. |
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
│   ├── DTO/             # Сетевые DTO
│   │   ├── ItemDTO.swift
│   │   └── ShopDTO.swift
│   ├── Models/          # Доменные модели
│   │   ├── Client.swift
│   │   ├── ClientContext.swift
│   │   ├── Item.swift
│   │   └── Shop.swift
│   ├── NetworkClients/  # HTTP-клиент
│   │   ├── NetworkClient.swift
│   │   └── URLNetworkClient.swift
│   └── Services/        # Контракты и реализации сервисов
│       ├── ContextService.swift
│       ├── ImageLoader.swift
│       ├── LoginService.swift
│       ├── LocalContextService.swift
│       ├── LocalLoginService.swift
│       ├── LocalShopLoader.swift
│       ├── NetworkShopService.swift
│       ├── PaymentService.swift
│       ├── ShopAPIConfiguration.swift
│       ├── ShopEndpoint.swift
│       └── ShopService.swift
├── ViewModels/          # Presentation-слой: контракт View ↔ ViewModel
│   ├── CartViewModel.swift
│   ├── LoginViewModel.swift
│   ├── ShopCellViewModel.swift
│   ├── ShopCatalogViewModel.swift
│   └── ShopViewModel.swift
├── AppRouter.swift
├── AppDelegate.swift
├── CartViewController.swift
├── CatalogViewController.swift
├── FeaturesViewController.swift
├── LocalAppRouter.swift
├── LoginViewController.swift
├── SceneDelegate.swift
├── ShopDetailsViewController.swift
├── ShopCollectionViewCell.swift
├── ShopViewController.swift
├── ShopsListManager.swift
└── ViewController.swift
```

---

## Лабораторная 4

### Используемое API

- Используется локальный `json-server`: `http://localhost:3000`
- Endpoint для списка магазинов: `GET /shops`
- Полный URL: `http://localhost:3000/shops`

### Пример ответа

API возвращает объект с ключом `shops` в `db.json`, а endpoint `GET /shops` отдаёт корневой массив магазинов. У каждого магазина есть вложенный массив `products`.

Пример одного элемента ответа:

```json
{
  "id": "1",
  "name": "Цветочный Рай",
  "avatar_url": "https://picsum.photos/seed/shop1/300/200",
  "city": "Москва",
  "street": "ул. Тверская, 15",
  "rating": 4.8,
  "work_hours": "09:00 - 21:00",
  "phone": "+7 (495) 123-45-67",
  "products": [
    {
      "id": "1",
      "name": "Роза красная",
      "avatar": "https://picsum.photos/seed/rose1/200/200",
      "price": "150.00",
      "quantity": 45
    }
  ]
}
```

Локальный fallback для отладки использует тот же формат JSON в файле `lab_swift/Resources/shops.json`.

### Поля ProductCellViewModel

Для товара используются такие поля, подготовленные из `ItemDTO`:

- `id`
- `name`
- `avatarURL`
- `price`
- `quantity`

Во view слой DTO напрямую не передаются: данные сначала декодируются в `ShopDTO` и `ItemDTO`, затем маппятся в доменные модели `Shop` и `Item`.

### Как проверить

1. Поднять локальный сервер:
   - `json-server --watch db.json --port 3000`
2. Запустить приложение.
3. Авторизоваться через экран логина.
4. После успешного входа открывается каталог магазинов, где `ShopCatalogViewModel.loadShops()` вызывает `ShopService.getShops()`.
5. Для проверки товаров магазина можно вызвать `ShopService.getItems(shopID:)`.
6. Если сервер недоступен, `NetworkShopService` автоматически переключается на локальный файл `lab_swift/Resources/shops.json`.

---

## Лабораторная 5

Для экрана списка используется `UICollectionView`.


После авторизации открывается экран списка магазинов.

Ячейка строится не от DTO, а от отдельной presentation-модели `ShopCellViewModel` и показывает:

- название магазина;
- картинку по `imageURL`;
- статус `Открыто` / `Закрыто`.

Для картинок используется отдельный загрузчик на `URLSession` с `URLCache`. При переиспользовании ячейки загрузка отменяется в `prepareForReuse`, а изображение сбрасывается на плейсхолдер.

### Как открыть экран списка

1. Запустить `json-server --watch db.json --port 3000` при необходимости.
2. Запустить приложение.
3. Если сессии ещё нет, ввести логин и пароль на экране входа.
4. После успешной авторизации откроется экран `Магазины`.

Если пользователь уже был авторизован ранее, экран списка откроется сразу при старте приложения.

### Как увидеть состояния экрана

- `loading`: открыть экран списка после входа, пока выполняется `loadShops()`.
- `content`: появляется после успешной загрузки магазинов.
- `empty`: ввести в поиск строку, по которой нет совпадений.
- `error`: временно указать недоступный `SHOP_API_BASE_URL` в `Info.plist` и одновременно сделать недоступным локальный fallback `lab_swift/Resources/shops.json`, чтобы загрузка не смогла завершиться ни из сети, ни из локального файла.

### Фильтрация

На экране есть поиск по названию магазина. Фильтрация выполняется на уровне `ShopCatalogViewModel` по уже загруженным данным и не делает новый сетевой запрос.

---

## Лабораторная 6 — Дизайн-система

В проект добавлена мини дизайн-система и применена на экранах авторизации, каталога и деталей магазина.

### Где лежит дизайн-система

```
lab_swift/DesignSystem/
├── Theme/
│   ├── DS.swift
│   ├── DSPalette.swift
│   ├── DSTypography.swift
│   ├── DSSpacing.swift
│   └── DSIconSize.swift
└── Components/
    ├── DSButton.swift
    ├── DSTextField.swift
    ├── DSLoadingView.swift
    ├── DSError.swift
    └── DSEmptyView.swift
```

### Токены

- **Colors / Palette** (`DSPalette`):
  - `background`, `surface`, `primary`, `onPrimary`, `secondary`
  - `textPrimary`, `textSecondary`
  - `error`, `errorText`
  - `border`, `separator`
  - `statusPositive`, `statusNegative`
  - `iconMuted`
- **Typography** (`DSTypography`):
  - `largeTitle`, `title`, `headline`, `body`, `bodyMedium`, `caption`, `captionMedium`, `button`, `fieldTitle`
- **Spacing / Radius** (`DSSpacing`):
  - `xs/s/m/l/xl`
  - `cornerRadiusSmall/Medium/Large`
  - `controlHeight`
- **Icon sizes** (`DSIconSize`):
  - `small`, `medium`, `large`

### Реализованные компоненты

- `DSButton`:
  - стили `primary` / `secondary`
  - disabled state
  - loading state (`setLoading`)
- `DSTextField`:
  - заголовок, placeholder, ошибка
  - disabled/secure
  - конфигурация через `Model`
- `DSLoadingView`:
  - индикатор + текст
  - конфигурация через `Model`
- `DSErrorView`:
  - иконка + текст + retry-кнопка
  - конфигурация через `Model`
- `DSEmptyView`:
  - иконка + заголовок + описание
  - конфигурация через `Model`

### Применение на экранах

- **LoginViewController**:
  - `DSTextField` (логин/пароль)
  - `DSButton` (вход, loading)
  - токены палитры/типографики/отступов
- **CatalogViewController**:
  - `DSLoadingView`, `DSErrorView`, `DSEmptyView`
  - токены палитры
  - переключение темы из navigation bar
- **ShopCollectionViewCell**:
  - стили через DS-токены
  - конфиг через `configure(with:)` + VM
  - корректный reuse и обновление темы
- **ShopDetailsViewController**:
  - типографика, палитра и отступы через DS
  - обновление при смене темы

### Темизация (D1)

- Поддерживаются две темы:
  - `warm`
  - `dark`
- Текущая тема хранится в `UserDefaults` и применяется через `DS.applyTheme(...)`.
- Переключение темы доступно через кнопку **«Тема»** в navigation bar:
  - на экране входа
  - на экране каталога
  - на экране деталей магазина

### Дополнительные задания

- **D1 (темизация)** — выполнено.
- **D4 (валидируемые поля формы)** — выполнено (`DSTextField` + модель конфигурации + ошибка под полем).
- **D5 (DS для списка)** — выполнено (`ShopCollectionViewCell` + `configure(with:)` + reuse).
- **D2 (стиль иконок/изображений)** — частично выполнено:
  - размеры (`DSIconSize`) и tint (`iconMuted`) централизованы.

### Как проверить состояния

1. Запустить приложение.
2. Авторизоваться (или использовать сохранённую сессию) и открыть каталог.
3. Проверить состояния каталога:
   - `loading`: при первоначальной загрузке списка
   - `content`: после успешной загрузки
   - `empty`: ввести в поиск строку без совпадений
   - `error`: сделать недоступными и сеть, и локальный fallback, затем нажать retry
4. Проверить тему:
   - нажать **«Тема»** в navigation bar и переключить `warm`/`dark`
   - убедиться, что цвета экранов и ячеек обновляются.

