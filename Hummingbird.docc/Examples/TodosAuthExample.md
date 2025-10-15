# Todos with Authentication Example

Example combining Authentication with CRUD operations using fluent-kit

> The source code for this example can be found [here](https://github.com/hummingbird-project/hummingbird-examples/tree/main/todos-auth-fluent)

This example starts with a standard username/password login. There is a link to a signup screen where you can enter your name, email and password. When you return to the login screen you can use your email and password to access the main page. On the main page is a text box and a "Add Todo" button. Whenever the button is pressed the contents of the text box is added as a Todo, which is then displayed in the list above. Each Todo can then be flagged as complete or deleted.

## Database

The example uses an SQLite database stored in a file. It then uses [Fluent](https://github.com/Vapor/fluent-kit) to interact with that database. Fluent is a database ORM developed by the Vapor team. While Vapor is also a web framework, the Fluent ORM works with any web framework including Hummingbird. We have built a supporting package ``HummingbirdFluent`` that helps integrate Fluent into Hummingbird projects.

This example creates two tables
- Table `users` with fields `id`, `name`, `email`, `password`
- Table `todos` with fields `id`, `title`, `owner_id`, `completed` and `url`

The migrations to create these can be found in the [Migrations folder](https://github.com/hummingbird-project/hummingbird-examples/tree/main/todos-auth-fluent/Sources/App/Migrations). The first time you run this example you should run it with the `--migrate` parameter to perform the database migrations.

## Walkthrough

The example has three controllers
- [`UserController`](https://github.com/hummingbird-project/hummingbird-examples/tree/main/todos-auth-fluent/Sources/App/Controllers/UserController.swift): API for creating, login and logout of users.
- [`TodoController`](https://github.com/hummingbird-project/hummingbird-examples/tree/main/todos-auth-fluent/Sources/App/Controllers/TodoController.swift): API for creating, accessing, updating, listing and deleting Todos.
- [`WebController`](https://github.com/hummingbird-project/hummingbird-examples/tree/main/todos-auth-fluent/Sources/App/Controllers/WebController.swift): Provides dynamically generated webpages.

## Authentication

For authentication purposes the example uses ``/HummingbirdBasicAuth/BasicAuthenticator`` to provide a standard username/password login and ``/HummingbirdAuth/SessionAuthenticator`` for authenticating based off a session id. Both of these require a repository type that defines how to access a user based off either a username or session identifier. The example contains a [`UserRepository`](https://github.com/hummingbird-project/hummingbird-examples/tree/main/todos-auth-fluent/Sources/App/Repositories/UserRepository.swift) that conforms to the relevant protocols (``/HummingbirdBasicAuth/UserPasswordRepository`` and ``/HummingbirdAuth/UserSessionRepository``) needed for it to be used with these authenticator middleware.

To use the `SessionAuthenticator` we also need to add the ``/HummingbirdAuth/SessionMiddleware``. This extracts session id from the request and responds with `set-cookie` headers if the session needs updated. The session middleware converts the session id into the data associated with the session, in this case a user id. This id is then converted by the authenticator middleware into a `User`.

## UserController

The `UserController` has four endpoints
- `POST /api/users`: Creates a new user. This is only used in tests as user creation is done using Form POST.
- `POST /api/users/login`: Creates a session for the user. The user is provided by the `BasicAuthenticator` middleware. Again this is only used in tests.
- `POST /api/users/logout`: Clears the session for the current user. The user is provided by the `SessionAuthenticator` middleware.
- `GET /api/user`: Returns the ID of the currently logged in user. Again the user is provided by the `SessionAuthenticator` middleware.

## TodoController

The `TodoController` provides the API for the CRUD operations to create, read, update and delete todos. The operations are all done using the Fluent ORM. All endpoints include the `SessionAuthenticator` middleware. The endpoints are all inside a group which transforms the application `RequestContext` [`AppRequestContext`](https://github.com/hummingbird-project/hummingbird-examples/blob/main/todos-auth-fluent/Sources/App/RequestContext.swift) into a new [`TodoContext`](https://github.com/hummingbird-project/hummingbird-examples/blob/4db5c2d840eb93aba19737e9e080f6f293683423/todos-auth-fluent/Sources/App/Controllers/TodoController.swift#L25) which requires an Identity (logged in user). If the context doesn't have an identity then the transformation throws an HTTP unauthorized error. Now all routes using this `TodoContext` are guaranteed to have a logged in user.

## WebController

The `WebController` uses ``Mustache`` to render HTML. The mustache template library is loaded in `buildApplication` and passed to the `WebController` on creation. The login, signup, error and home pages are generated using mustache temlates. The templates can be found in a subfolder of the [Resources](https://github.com/hummingbird-project/hummingbird-examples/tree/main/todos-auth-fluent/Sources/App/Resources/templates) folder.

The `WebController` has six endpoints
- `GET /login`: Login webpage.
- `POST /login`: Performs login using HTML form POST.
- `GET /signup`: Sign up webpage
- `POST /signup`: Creates a new user using HTML form POST.
- `GET /`: Home page displaying todo list. This route has the additional `SessionAuthenticator` and `RedirectMiddleware` applied to it.

The `WebController` also includes a couple of additional middleware. A [`RedirectMiddleware`](https://github.com/hummingbird-project/hummingbird-examples/blob/4db5c2d840eb93aba19737e9e080f6f293683423/todos-auth-fluent/Sources/App/Controllers/WebController.swift#L22) which will return a redirect response to the login page if the user tries to access the home page while not authenticated and an [`ErrorMiddleware`](https://github.com/hummingbird-project/hummingbird-examples/blob/main/todos-auth-fluent/Sources/App/Middleware/ErrorPageMiddleware.swift) that returns a web page displaying any errors caught while accessing any of the web pages.

