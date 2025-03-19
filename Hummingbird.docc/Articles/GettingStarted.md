# Getting Started with Hummingbird

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Create a new project on GitHub or an app locally from a starter template.

## Overview

The Hummingbird project provides multiple entry points for getting started.

1. Create your own project that uses Hummingbird from a [starting template](https://github.com/hummingbird-project/template) to jump right in.
2. For a walk-through, explore and follow along the [Build a Todos Application](https://docs.hummingbird.codes/2.0/tutorials/todos) tutorial.
3. Take some time to explore the [Hummingbird Examples](https://github.com/hummingbird-project/hummingbird-examples/), individual projects that use common patterns.

### Creating a project locally

Clone the starting template to your local machine:

    git clone https://github.com/hummingbird-project/template

Run the configure script provided to create a new folder and project inside:

    ./template/configure.sh MyNewProject

Change into the new project directory:

    cd MyNewProject

Then run your app:

    swift run App

The starting template is also designed so that you can create a new GitHub repository from it.

### Create using GitHub template

- Sign in to GitHub.
- Navigate to [https://github.com/hummingbird-project/template](https://github.com/hummingbird-project/template).
- Click "Use this template" and create your new repository.
- Clone the repository to a codespace or your local machine.
- Run the configuration script (`./configure.sh`) to configure your new project.

### Next Steps

Follow our TODO's application to get started with the framework: <doc:Todos>
